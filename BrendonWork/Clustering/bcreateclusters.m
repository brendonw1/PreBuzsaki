function E = createclusters(G, E, cluster_sizes, varargin)
% E = CREATECLUSTERS(G, E, CLUSTER_SIZES)
% Cluster the intensity plots of  all the neurons.  Attempt to cluster
% via kmeans and  using a range of  sizes.   cluster_sizes is an array  of
% sizes to attempt to cluster.  We will compute the silhouette test in
% order to know.
%
% Variable arguments are: 
% 'debug': 1 for yes, 0 for no. 
% 
% 'start': The _time_ in minutes demarking the beginning of the data
% used to cluster.
% 
% 'start_idx': Simply give the first index to cluster on.
%
% 'stop': The _time_ in minutes demarking the end of the data used to
% cluster.
%
% 'stop_idx': Simply give the last index to cluster on.
%
% 'distancefun':  Specify the distance measure used in the
% clustering.  This is the same parameter as in kmeans.

%
% (C) 2004 David C. Sussillo.  All rights reserved.

if (max(cluster_sizes) >= E.numRealNeurons)
    disp('Not clustering, too few neurons for max cluster size..');
    return;
end

type = 'normal';
start_idx = 1;
stop_idx = G.numImagesProcess;
debug = 0;
start_time = 0;				% minutes
stop_time = G.numImagesProcess/G.fs/60;	% minutes
distancefun = 'correlation';
nargs = length(varargin);
% Fix a bug that I've had previously.
if (isfield(E, 'nFilter'))
    flen = E.nFilter
else    
    flen = 10;
end
for i = 1:2:nargs
    switch varargin{i},
     case 'start'
      start_time = varargin{i+1};
      start_idx = floor(start_time*G.fs*60+1) - G.movie_start_idx;
     case 'stop'
      stop_time = varargin{i+1};
      stop_idx = floor(stop_time*G.fs*60) - G.movie_start_idx      
     case 'start_idx'
      start_idx = varargin{i+1};
     case 'stop_idx'
      stop_idx = varargin{i+1};
     case 'distancefun'
      distancefun = varargin{i+1};
     case 'debug'
      debug = varargin{i+1};
     case 'type'
      type = varargin{i+1};
     case 'filterlen'
      flen = varargin{i+1};
    end
end





% Iterate through all the potential cluster sizes to find the
% cluster that has the smallest silhouette.  Presumably this is a
% good measure of the clustering.
potential_clusters = zeros(E.numRealNeurons, length(cluster_sizes));
silhouettes = zeros(E.numRealNeurons, length(cluster_sizes));
idx = 1;

flen=0;%%added by B
intensitymap = reshape([E.realNeurons.intensityclean], ...
		       G.numImagesProcess-(flen), E.numRealNeurons)';
if (start_idx ~= 1 | stop_idx ~= G.numImagesProcess)
    intensitymap = intensitymap(:,start_idx:stop_idx);
end
if (debug)
    size(intensitymap)    
    figure; imagesc(intensitymap);
    pause;
end

switch(type)
 case 'diff'
  intensitymap = diff(intensitymap,1,2);
 case 'normal'
  1;
end
  

for i = cluster_sizes
    % Cluster the neurons and place the number in each neuron.
    potential_clusters(:,idx) = kmeans(intensitymap, i, ...
				     'distance', distancefun, ...
				     'display', 'notify', ...
				     'maxiter', 50, ...
				     'replicates', 30, ...
				     'emptyaction', 'singleton',...
				     'start', 'sample');
    s = silhouette(intensitymap, ...
		   potential_clusters(:,idx), ...
		   distancefun);
    disp(['Cluster size ' num2str(i) ' has silhouette mean ' num2str(mean(s)) ...
	  '.']);
    silhouettes(:,idx) = s;
    idx = idx + 1;
    
end
% Figure out how well each cluster size did and pick the winner.
smeans = mean(silhouettes,1);
sargmax = find(smeans == max(smeans));
n = cluster_sizes(sargmax(1));
clusters = potential_clusters(:,sargmax(1));

if (debug)
    plot(cluster_sizes,smeans);   
end

disp(['Cluster size ' num2str(n) ' had maximal silhouette' ...
      ' value: ' num2str(smeans(sargmax(1))) '.'])

% Generate the colors.
clustercolor = rand(n,3);
niters = ceil(log(n+1)/log(3));
i = 1;
for x = 2:niters
    if (i > n)
	break;
    end
    for y = 1:niters
	if (i > n)
	    break;
	end
	for z = 1:niters
	    if (i > n)
		break;
	    end
	    clustercolor(i,:) = [(y-1)/(niters-1) (x-1)/(niters-1) (z-1)/(niters-1)];
	    i = i+1;
	end
    end
end


%E.clusterIdxs = clusters;
E.numClusters = n;
for i = 1:E.numRealNeurons
    E.realNeurons(i).cluster = clusters(i);
end

% Assign the colors to the neurons based on their cluster number.
for i = 1:E.numRealNeurons
    E.realNeurons(i).color = clustercolor(E.realNeurons(i).cluster,:);
end

E.clusterColor = clustercolor;

if (isfield(E, 'clusters'))
    E = rmfield(E, 'clusters');
end

E = genclusterstats(G,E);

%mymin = min([E.realNeurons.intensityclean]);
%mymax = max([E.realNeurons.intensityclean]);
%len = length(E.realNeurons(1).intensityclean);
%E.clustermeanintensities = zeros(E.numClusters, len);
%for i = 1:E.numClusters
%    cluster_idxs = find([E.realNeurons.cluster] == i);
%    ncluster = length(cluster_idxs);

%    fs = reshape([E.realNeurons(cluster_idxs).intensityclean], ...
%		 len, ncluster)';
%    fsnorm = (fs-mymin)/(mymax-mymin);
%    % Generate an id, if there isn't one already.
%    E.clusters(i).id = i;
%    % Create a cluster intensity map.    
%    E.clusters(i).intensityMap = fs;
%    % Create the cluster intensity map in color.
%    E.clusters(i).intensityMapColor(:,:,1) = ...
%	(fsnorm)*clustercolor(i, 1);;    
%    E.clusters(i).intensityMapColor(:,:,2) = ...
%	(fsnorm)*clustercolor(i, 2);;    
%    E.clusters(i).intensityMapColor(:,:,3) = ...
%	(fsnorm)*clustercolor(i, 3);;    
%    E.clusters(i).meanIntensity = mean(fs,1);
%    E.clusters(i).stdIntensity = std(fs,1);
    
%    % Setup the cluster information.
%    color = E.realNeurons(cluster_idxs(1)).color;
%    E.clusters(i).nNeurons = ncluster;
%    E.clusters(i).neurons = cluster_idxs;
    
%    centroids = reshape([E.realNeurons(cluster_idxs).Centroid], ...
%		       2, E.clusters(i).nNeurons)';    
%    E.clusters(i).color = color;
%    E.clusters(i).locMean = mean(centroids,1); % location mean.

%    E.clusters(i).locCov = cov(centroids); % ellipse of one std.
%end