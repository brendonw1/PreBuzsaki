function [result, data, param] = ct_em(data, handles, clustered_contour_ids,cluster_size, options)

% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.exp;

replicates = 1;
maxiter = 50;
quality = 'll';
num_contours = size(data, 1);

% Cluster the contours and place the number in each neuron.
[clustermaxidx, clustermtx, means, sigmas, priors, quality] = ...
    fuzzykmeans(data', cluster_size, ...
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
% Mahalanobis distance since we are using a covariance matrix.
param = [];
result.cluster.v = means';
resutl.cluster.P = sigmas;
result.data.f = clustermtx';
dists = zeros(num_contours, cluster_size);
for i = 1:cluster_size
    dmm = data - repmat(means(:,i)', num_contours, 1);
    norm_mat = pinv(sigmas(:,:,i));
    dists(:,i) = sum(dmm*norm_mat.*dmm,2);
    dists = sqrt(dists);
end
result.data.d = dists;
