function [nclusters, clusters] = ...
    ct_neuron_or_glia_in_epilepsy(data, handles, clustered_contour_ids,cluster_sizes, options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.exp;

% An example of a classifier instead of a cluster technique.  This
% routine attempts to seperate glia from neurons based on the
% kinetics.  it uses a HMM to attempt this and it does a very poor
% job.
type = classifycell(data);
for j = 1:length(type)
    switch type(j)
     case {'n'}
      clusters(j) = 1;
     case {'g'}
      clusters(j) = 2;
     case {'l'}
      clusters(j) = 3;
     case {'-'}
      clusters(j) = 4;
     otherwise
      disp(type(j))
    end
end
n = length(unique(clusters));