function handles = delete_contour_handles(handles, varargin)
% function handles = delete_contour_handles(handles)
% Delete the handles if so desired, and if they are valid.

ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
nargs = length(varargin);
if (nargs > 0)
    for i = 1:2:nargs
        switch varargin{i}
         case 'ridx'
          ridx = varargin{i+1};
         case 'midx'
          midx = varargin{i+1};
         case 'color'
          cl = varargin{i+1};
        end
    end
end

% Delete the handles that are valid, and then null out the handle
% array.
nregions = handles.exp.numRegions;
if strcmp(ridx, 'all')
    regions_to_delete = 1:nregions;
else
    regions_to_delete = ridx;
end

face = handles.guiOptions.face;
for ridx = regions_to_delete
    hands = face.handl{ridx}{midx};
    if ~isempty(hands)	
        valid_handles = hands(find(ishandle(hands)));
        if ~isempty(valid_handles)	   
            delete(valid_handles);
        end
        face.handl{ridx}{midx} = [];
    end       
end
handles.guiOptions.face = face;