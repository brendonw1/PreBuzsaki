function [clustermaxidx, clustermtx, means, sigma, priors, cluster_quality] = ...
    fuzzykmeans(data, nc, varargin)

% function [clustermaxidx, clustermtx, means, sigma, priors, cluster_quality] 
%   = fuzzykmeans(data, nc, varargin)
%
% data(:, t) is the t'th data point
% nc is the number of clusters
cov_type = 'diag';
max_iter = 30;
replicates = 1;
do_loglikelihood = 1;
do_most_worst_point = 0;
nargs = length(varargin);
if (nargs)
    for i = 1:2:nargs
	switch varargin{i},
	 case 'quality'
	  if (strcmp(varargin{i+1}, 'worst'))
	      do_most_worst_point = 1;
	      do_loglikelihood = 0;
	  end
	 case 'replicates'
	  replicates = varargin{i+1};
	 case 'max_iter'
	  max_iter = varargin{i+1};
	 case 'cov_type'
	  cov_type = varargin{i+1};
	end	
    end
end


ndata = size(data, 2);
dim = size(data,1);
clustermtxs = zeros(nc, ndata, replicates);
evaluations = zeros(1, replicates);
maxs = zeros(1, ndata);
%cov_prior = repmat(0.01*eye(dim), [1 1 nc]);
for r = 1:replicates
    [means, sigma, priors] = mixgauss_em(data, nc, ...
					 'cov_type', cov_type, ...
					... % 'cov_prior', cov_prior, ...
					 'method', 'kmeans', ...
					 'max_iter', max_iter);

    % Now that we have the means and covariances we can get the
    % probability of the points for each and store them in a
    % matrix.
    for c = 1:nc
	for d = 1:ndata
	    % In log space.
	    clustermtxs(c, d, r) = ...
		gaussian_prob(data(:,d), means(:,c), sigma(:,:,c),1);
	end	
    end
    
    % Now we assess how good the EM was.
    if (do_loglikelihood)
	% Evaulate the log-likelihood of the data given the model.
	% p(X|theta)
	evaluations(r) = sum(sum(clustermtxs(:,:,r)));
	disp(['Log-likelihood of model given the data: ' ...
	      num2str(evaluations(r)) '.']);
    elseif (do_most_worst_point)	% minimum worst data.
	% Get the maximum cluster value for each point to determine
        % the most worst data point by comparing these maxima.
	for d = 1:ndata
	    if (do_most_worst_point)
		m = max(clustermtxs(:, d, r)); % get best cluster
		    maxs(d) = m;
	    end
	end
	% Take the log probability for the worst clusterd point as
        % judged by how poorly the closest Gaussian fits it.
	evaluations(r) = min(maxs);
	worst_point_id = find(maxs == evaluations(r));
	worst_point_id = worst_point_id(1);
	worst_point_ids(r) = worst_point_id;
	disp(['Worst point in replicate: ' num2str(r) ' is ' ...
	      num2str(worst_point_id) ' with log-likelihood: ' ...
	      num2str(evaluations(r)) '.']);
    end
end

    disp(['Average evaluation for ' num2str(nc) ' clusters: ' ...
	 num2str(mean(evaluations)) '.']);

% Judge the replicates by taking the best evaluatoin, be it
% log-likelihood or worst point.
max_evaluations = max(evaluations)
max_idx = find(evaluations == max_evaluations);
max_idx = max_idx(1)		% Take earlier replicates.

clustermtx = clustermtxs(:,:,max_idx);
% take out of log-space and get the posterior probability
% P(Ni|x) = p(x|Ni)*p(Ni)/p(x)
% Hmm... multiplying by the priors gives conditional probabilities
% less than one.  I must be missing something for now I'll take it out.
for j = 1:ndata
    log_evidence = logsumexp(clustermtx(:,j));
%    clustermtx(:,j) =
%    exp(clustermtx(:,j)-log_evidence+log(priors));
    clustermtx(:,j) = exp(clustermtx(:,j)-log_evidence);
end
maxes = max(clustermtx);
for j = 1:ndata
    cmidxs = find(clustermtx(:,j) == maxes(j));
    clustermaxidx(j) = cmidxs(1);
end
cluster_quality = max_evaluations;