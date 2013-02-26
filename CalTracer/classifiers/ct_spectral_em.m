function [result, data, param] = ct_spectral_em(data, handles, clustered_contour_ids,cluster_size, options)

% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.exp;
num_contours = size(data, 1);
sigma = 10;
smoothing_constant = 0;

%S = S_from_points(score(:,1:nscores)', sigma, smoothing_constant, 0);
% old.
%S = S_from_points(data', sigma, smoothing_constant, 0);
%clusters = cluster_spectral_general(S, cluster_size, 'njw','ward');

% New.
exp_mult_factor = -0.5/(sigma*sigma); 
%num_vectors = size(points,2);
A = squareform(pdist(data)); % need to transpose it pdist expects row vectors
A = exp(exp_mult_factor*A);

% The NJW algorithm
% Compute Laplacian L=D^-1/2 A D^-1/2
D = diag(sum(A));
Dsqrt = sqrt(D);
L = Dsqrt\A/Dsqrt;
% Above presription for L is faster, though not the direct formula.  The two
% incantations are equivalent.
%Dsqrtinv = D^(-1/2);
%L = Dsqrtinv*A*Dsqrtinv;
% the top k EV
opts.disp = 0;
Ldiff = L-L';
if max(max(abs(Ldiff))) < 1e-20 % the matrix is symm
    [v d] = eigs(L, cluster_size, 'la', opts);
else
    [v d] = eigs(L, cluster_size,'lr',opts);
end
dk = diag(d);  % top cluster_sizes work of eigenvalues.
X = v; 

% normalize along 2nd dimension to make rows have unit length.
n = size(X,1);
ss = sqrt(sum(X.^2, 2));   % normalize
Y = zeros(size(X,1),size(X,2));
for i=1:n
    if ss(i) == 0 
        1; %Y(i,:) = 0;
    else
        Y(i,:) = X(i,:)/ss(i);
    end
end

% 
% % Data
% data_s.X = Y;
% %parameters
% param.c = cluster_size;
% param.m = 2;
% param.e = 1e-6;
% param.ro = ones(1, param.c);
% param.val = 3;
% %clustering
% result = FCMclust(data_s, param);
% return;
data = Y;

% Now run EM on the data.
replicates = 1;
maxiter = 50;
quality = 'll';
num_contours = size(data, 1);

% Cluster the contours and place the number in each neuron.
[clustermaxidx, clustermtx, means, sigmas, priors, quality] = ...
    fuzzykmeans(Y', cluster_size, ...
		'replicates', replicates, ...
		'cov_type', 'full', ...
		'method', 'kmeans', ...
		'quality', quality, ...
		'max_iter', maxiter);

for j = 1:num_contours
    m = max(clustermtx(:,j));
    cluster_num = find(clustermtx(:,j) == m);
end

% If we are computing distances, then they should be in context of the
% Mahalanobis distance since we are using a covariance matrix and
% fuzzykmeans (EM).  Also, we compute distances on the Laplacian,
% since these will be the accurate distance measures.  
param = [];
result.cluster.v = means';
result.cluster.P = sigmas;
result.data.f = clustermtx';
dists = zeros(num_contours, cluster_size);
for i = 1:cluster_size
    dmm = Y - repmat(means(:,i)', num_contours, 1);
    norm_mat = pinv(sigmas(:,:,i));
    dists(:,i) = sum(dmm*norm_mat.*dmm,2);
    dists = sqrt(dists);
end
result.data.d = dists;
 


