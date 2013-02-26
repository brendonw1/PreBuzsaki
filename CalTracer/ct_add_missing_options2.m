function app_data = ct_add_missing_options2(appdata, exp)
% Sometimes we need exp to fill in the app_data correctly.  This
% happens for setting defaults for missing partitions data.  This
% assumes that exp is reasonably filled out.
app_data = appdata;
if (~isfield(appdata, 'partitions'))
    % Can we do this without the exp.partitions? -DCS:2005/08/19
    for pidx = 1:exp.numPartitions
	numclusters = exp.partitions(pidx).numClusters;
	app_data.partitions(pidx) = newpartition_appdata(numclusters);
    end
end

for i = 1:exp.numPartitions
   if (~isfield(app_data.partitions(i), 'displayedContours'))
       app_data.partitions(i).displayedContours = [];
   end
end