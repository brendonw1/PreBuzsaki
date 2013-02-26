function [result, data, param] = ct_GKclust(data, handles,clustered_contour_ids,cluster_sizes, options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.exp;
num_contours = size(data, 1);
data_s.X = data;

%parameters
param.c = cluster_sizes(1);
param.m = 2;
param.e = 1e-6;
param.ro = ones(1, param.c);
param.val = 3;

%clustering
result = GKclust(data_s, param);
