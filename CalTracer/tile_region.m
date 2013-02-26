function handles = tile_region(handles)
% function handles = tile_region(handles)
%
% For the current mask and the current region, tile the region with
% contours irrespective of any actual cells.  This is useful examining
% the flow of activity across a slice in the neuropil.


% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
% Get the data from the uicontrols to find the cells.
ridx = handles.appData.currentRegionIdx;


face = handles.guiOptions.face;
face.isAdjusted(ridx) = 0;
face.isDetected(ridx) = 1;

handles.exp.regions.contours{ridx}{midx} = [];
% Get the top 'Cutoff' or threshold percent.
fimage = handles.exp.tcImage(midx).filteredImage;
width = handles.exp.tcImage(midx).nX;
height = handles.exp.tcImage(midx).nY;


% BP.
if (face.minArea(ridx) < 1)
    errordlg(['The min area, which is used for the tile side length,' ...
	      ' must be greater than one.']);
    return;
end

side_pixels = handles.face.tileSide(ridx);


% Tile the entire image and then use inpolygon to toss out the tiles
% that are not in the current region.
cn = [];
current_x = 1;
while current_x <= width
    current_y = 1;
    while current_y <= height
        if (current_x+side_pixels <= width & current_y+side_pixels <= height)
            coords = [current_x current_y; ...                    % upper left
                current_x+side_pixels current_y; ...           % upper right
                current_x+side_pixels current_y+side_pixels; ...  % lower right
                current_x current_y+side_pixels];              % lower left
            cn{end+1} = coords;
        end
        current_y = current_y + side_pixels;
    end
    current_x = current_x + side_pixels;
end

reg_coords = handles.exp.regions.coords;
names = handles.exp.regions.name;

% Get the centers and area of our tiles.
centr = [];
areas = [];
for c = 1:length(cn)
    centr(c,:) = create_centroid(cn{c});
    areas(c) = polyarea(cn{c}(:,1), cn{c}(:,2));
end



% Find those polygons in the right region (used for border clean-up).
in = inpolygon(centr(:,1), centr(:,2),...
	       reg_coords{ridx}(:,1), reg_coords{ridx}(:,2));
% Find those polygons in other regions.  It can happen that contours
% are in two regions, in so far as one region can be nested in
% another.
for r = 1:handles.exp.numRegions
    if (polyarea(reg_coords{r}(:,1), reg_coords{r}(:,2)) ...
	< polyarea(reg_coords{ridx}(:,1), reg_coords{ridx}(:,2)));
	in_other = inpolygon(centr(:,1), centr(:,2), ...
			  reg_coords{r}(:,1),reg_coords{r}(:,2));
	in_other_idxs = find(in_other);
	in(in_other_idxs) = 0;
    end
end    
        
f = find(in);
cntemp = [];
for c = 1:length(f)
    cntemp{c} = cn{f(c)};
end
centrtemp = centr(f,:);
areastemp = areas(f);
handles.exp.regions.contours{ridx}{midx} = cntemp;

% Save the rest of the work.
handles.guiOptions.face = face;

