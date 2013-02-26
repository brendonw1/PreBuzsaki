function [result, data, param] = ct_GGclust(data, handles, clustered_contour_ids,cluster_sizes, param)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.exp;

num_contours = size(data, 1);
data_s.X = data;

%parameters
param.c = cluster_sizes(1);
param.m = 2;
param.e = 1e-4;
param.val = 1;

%clustering
result = FCMclust(data_s,param);
param.c=result.data.f;
result = GGclust(data_s,param);

