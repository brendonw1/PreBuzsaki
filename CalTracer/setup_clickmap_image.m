function handles = setup_clickmap_image(handles)
% Setup the click map image axis.
midx = get_mask_idx(handles, 'tcImage');
ncontours = length(handles.exp.contours);
contourLines = handles.exp.contourLines;
ratio = handles.exp.tcImage(midx).nY/handles.exp.tcImage(midx).nX;
handles.guiOptions.face.clickMap = ...
    axes('position', [0.00 0.40+(0.50-ratio*0.50) 0.50 ratio*0.55]);
h = imagesc(handles.exp.tcImage(midx).image);
colormap(handles.exp.tcImage(midx).colorMap);
title('Cluster Map');

% Create the patches over the contours.  These ids set in UserData
% always stay the same. -DCS:2005/06/03
hold on;
cl = handles.exp.regions.cl;
cridx = handles.exp.contourRegionIdx;
cnt = zeros(1,ncontours);
for c = 1:ncontours
    cnt(c) = patch(contourLines{c}([1:end 1],1), contourLines{c}([1:end 1],2),[0 0 0]);
    set(cnt(c), 'edgecolor', cl(cridx(c),:));
    set(cnt(c), 'UserData', c);
    set(cnt(c), 'Clipping', 'off');
    set(cnt(c), 'ButtonDownFcn','caltracer(''contour_buttondown_callback'',gcbo,guidata(gcbo))');

end
handles.guiOptions.face.cnt = cnt;
% Plot the clickmap.  Could be in another function... -DCS:2005/03/23
axis equal;
imagesize = size(handles.exp.tcImage(midx).image);
xlim([0 imagesize(2)]);
ylim([0 imagesize(1)]);
set(handles.guiOptions.face.clickMap, 'ydir','reverse');
box on;
set(handles.guiOptions.face.clickMap, 'color',[0 0 0]);
set(handles.guiOptions.face.clickMap, 'xtick',[],'ytick',[]);
