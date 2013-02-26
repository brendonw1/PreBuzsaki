function handles=delete_high_pi_contours(handles);
% function delete_high_pi_contours(handles);
% Finds cells that have previously been found to above the specified pi
% limit and deletes them from the stored contours.

% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
% Ridx is the region currently being processed.
ridx = handles.appData.currentRegionIdx;
nhandlr = length(handles.guiOptions.face.handl{ridx}{midx});
handlr = handles.guiOptions.face.handl{ridx}{midx};
cnr = handles.exp.regions.contours{ridx}{midx};
tc_image = handles.exp.tcImage(midx).image;
clr = handles.exp.regions.cl(ridx,:);
filtered_image = handles.exp.tcImage(midx).filteredImage;
wd = zeros(1,length(handlr));
% The linewidth is the way the GUI detects for bad contours.
for c = 1:nhandlr
    wd(c)= get(handlr(c),'linewidth');
end
f = find(wd==2);

handles.exp.regions.contours{ridx}{midx}(f)=[];%delete those contours

handles = draw_cell_contours(handles, 'ridx', 'all');
