function handles = create_region(handles)
% function handles = create_region(handles)
% create a region by creating the border for the region using
% mouse, selections and store it.  Redraw the region widget.

% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
uiset(handles, 'regions', 'bord_add', 'foreground',[1 0 0]);

nx = handles.exp.tcImage(midx).nX;
ny = handles.exp.tcImage(midx).nY;


[x, y, h] = draw_region(nx, nx, 'tag', 'regionborder', 'enclosedspace', 1);

handles.exp.regions.bord{length(handles.exp.regions.bord)+1} = [];
handles.exp.regions.bord{end} = [get(h,'xdata')' get(h,'ydata')'];
        
handles.exp.regions.bhand(end+1) = h;

uiset(handles, 'regions', 'bord_add', 'foreground',[0 0 0]);

handles = determine_regions(handles);
