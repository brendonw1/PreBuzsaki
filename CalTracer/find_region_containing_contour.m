function region_idxs = find_region_containing_contour(handles, contours)
% function ridx = find_region_containing_contour(handles, contours)
% For a list of contours, determine which region they belong to.
nregions = handles.exp.numRegions;
ncontours = length(contours);
region_idxs = ones(1,ncontours);%if cannot find region... go into region 1, so 
for c = 1:ncontours
    for r = 1:nregions
        centr = create_centroid(contours{c});
        rborder = handles.exp.regions.coords{r};
        if inpolygon(centr(1),centr(2), rborder(:,1), rborder(:,2));
            region_idxs(c) = r;
            %break;
            %%% This is a little insidious here, basically a
                %working bug/hack.  Since the first region has regions
                %inside of it, by leaving out the 'break' statement we
                %pick up the most inclusive region for the cell contour.
                %However, I don't know what will happen if one defines
                %regions within one another after that. -DCS:2005/04/06
        end
    end
end

num_no_region = length(find(region_idxs == 0));

if (num_no_region)
    warndlg([num2str(num_no_region) ' contours did not find a' ...
	     ' region when loaded.  They will be put in to region #1.']);
end
