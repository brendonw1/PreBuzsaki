function handles = draw_region_widget(handles, varargin)
% This function draws the axes on the right which has a small
% version of the time collapsed image, for use with regions.

% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
lidx = get_label_idx(handles, 'regions');
ax = handles.uigroup{lidx}.regax;
do_draw_title = 0;
button_down_fnc = 'caltracer(''regionmap_buttondown_callback'',gcbo,guidata(gcbo))'; 
nargs = length(varargin);
map_color = [1 0 0];
if (nargs > 0)
    for i = 1:2:nargs
        switch varargin{i}
             case 'midx'
              midx = varargin{i+1};
             case 'axes'
              ax = varargin{i+1};
             case 'dotitle'
              do_draw_title = varargin{i+1};
             case 'mapcolor'
              map_color = varargin{i+1};
             case 'buttondownfnc'
              button_down_fnc = varargin{i+1};
        end
    end
end

% Plot the region widget on the right side of the GUI.
axes(ax);
delete(get(handles.uigroup{lidx}.regax,'children'));

if isfield(handles.appData,'mainTcImageWidget');
    if ishandle(handles.appData.mainTcImageWidget)
        delete(handles.appData.mainTcImageWidget);
    end
end
handles.appData.mainTcImageWidget = imagesc(handles.exp.tcImage(midx).image);

% imagesc(handles.exp.tcImage(midx).image);
colormap(handles.exp.tcImage(midx).colorMap);
lidx = get_label_idx(handles, 'regions');
%handles.uigroup{lidx}.regax = regax;	% save so we can delete later.
hold on;
reg = handles.exp.regions.coords;
reglen = length(handles.exp.regions.coords); % cell array length
                                             % (e.g. 4)
cl = hsv(reglen);
for r = 1:reglen
    ph(r) = patch(reg{r}(:,1),reg{r}(:,2), [0 0 0]);
    set(ph(r), 'Clipping', 'off');
    set(ph(r), 'FaceColor', 'none');
    %set(ph(r), 'FaceColor', cl(r,:));
    %set(ph(r), 'FaceAlpha', 0.2);
    set(ph(r), 'EdgeColor', cl(r,:));
    set(ph(r), 'ButtonDownFcn', button_down_fnc);
    set(ph(r), 'UserData', [r midx]);
end
set(ax, 'xtick', [], 'ytick', [], 'ydir', 'reverse');
axis equal;
axis tight;
if (do_draw_title)
    title(texlabel(handles.exp.tcImage(midx).title, 'literal'), ...
	  'BackgroundColor', map_color)
end
%box on;

%handles.guiOptions.face.regionMap(midx).axes = regax;
%handles.guiOptions.face.regionMap(midx).regionPatchH = ph;

