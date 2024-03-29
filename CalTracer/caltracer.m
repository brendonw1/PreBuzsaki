function varargout = caltracer(varargin)
% Launch internally with callbacks.
is_even = mod(nargin,2) == 0;
if (is_even == 1)
    ct_OpeningFcn(varargin{:});
elseif (nargin == 0)
    ct_OpeningFcn([]);
elseif (nargin == 3)
    feval(varargin{1}, varargin{2}, varargin{3});
end



%%
% ct_OpeningFcn
function hObject = ct_OpeningFcn(varargin)
% Setup some variables that will be used throughout the application.
% Add your appData defaults to ct_add_missing_options!!!
% -DCS:2005/06/03
handles.appData = ct_add_missing_options([]);
[handles.exp handles.appdata] = ct_add_missing_options_exp([], handles.appData);
handles.appData = ct_add_missing_options2(handles.appData, handles.exp);
%handles = set_new_mask_idx(handles, 'tcImage');
handles.appData.currentMaskIdx = get_mask_idx(handles, 'tcImage');
                                
handles.exp.regions.bord = [];
handles.exp.regions.bhand = [];                                 

handles.clPosH = {};
handles.clBordH = {};
handles.contourOrderH = {};

[hObject, handles] = ct_createGUI(handles);
try%let user set some initial defaults by creating the function below that will
       %take handles and change some values in it
    handles=ct_InitialCreationPreferences(handles);
end
    
for a=1:length(varargin);
    switch lower(varargin{a})
        case 'inputfilename'
            handles.appData.currentImageInputType = 'inputfilename';
            handles = open_image(handles,[],varargin{a+1});
            handles.app_data.currentImageInputType = 'file';%reset to default
            hObject=handles.fig;%for consistency with rest of program
            guidata(hObject,handles);
            break
        case 'inputimage'
            handles.appData.currentImageInputType = 'inputarg';
            handles.exp.tcImage.image=varargin{a+1};
            handles = open_image(handles);
            handles.app_data.currentImageInputType = 'file';%reset to default
            hObject=handles.fig;%for consistency with rest of program
            guidata(hObject,handles);
            break
    end
end
guidata(hObject,handles);
%%
% ct_ClosingFcn
function ct_ClosingFcn(hObject, handles)

sem = findobj ('label', 'Save Experiment');%get ahold of the Save Experiment Menu
sem = sem(1);
sem = strcmpi ('on', get(sem,'Enable'));%if it's been made active (ie can save)
if sem%then ask user if wants to save
    if ~handles.appData.didSaveExperiment%if not saved since opening
        button = questdlg('Would you like to save before quitting?','Save Experiment');
        switch button
            case 'Cancel'%don't close
                return
            case []
                return
            case 'Yes'
                save_experiment_callback(hObject, handles)
        %     case 'No'
        end
    end
end
    
delete(handles.fig);
% if strcmp(get(hObject, 'Type'), 'uimenu')
%     p = get(hObject, 'Parent');
%     delete(get(p, 'Parent'));
% else    
%     delete(hObject);			% hObject is the figure.
% end


%%
% ct_createGUI
function [hObject, handles] = ct_createGUI(handles)
% Setup the GUI, this means defining every widget that will be
% used, ever. So naturally, the Visible property is off for most of
% these uicontrols.
opengl neverselect;

%to make figure size work for all screens
screensize=get(0,'ScreenSize');
screensize=screensize(3:4);
taskbarheight=35;%pixels (true for all screens?)
figtoolbarheight=79;%pixels (true for all screens?)
vertpix=taskbarheight+figtoolbarheight;%to subtract from height of fig
proportion=(screensize(2)-vertpix)/screensize(2);

handles.fig = figure('Name', ...
		     [handles.appData.title ' ' num2str(handles.appData.versionNum,'%6g')],...
		     'NumberTitle','off',...
		     'MenuBar','none',...
		     'ToolBar', 'figure', ...
		     'doublebuffer','on',...
		     'closerequestfcn','caltracer(''ct_ClosingFcn'',gcbo,guidata(gcbo))',...
		     'Resize', 'on', ...
             'units','pixels',...
             'position',[5 taskbarheight screensize(1)*proportion screensize(2)-vertpix]);
% 		     'units','normalized',...
% 		     'position',[0.05 0.05 0.90 0.90]);
%		     'position',[0 .08/3 1 2.86/3]);

%set(handles.fig, 'renderer','opengl'); 
hObject = handles.fig;



handles.uimenuLabels = {'File', 'Preferences', 'Export', 'Contours', 'Preprocessing', 'Clustering', 'Functions'};
% Setup menu and menu group.
midx = get_menu_label_idx(handles, 'File');
handles.menugroup{midx}.file = uimenu('Label', 'File');
% Add the menu items.

uimenu(handles.menugroup{midx}.file, ...
       'Label', 'Open Experiment', ...
       'Callback', 'caltracer(''open_experiment_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{midx}.file, ...
       'Label', 'Save Experiment', ...
       'Enable', 'off', ...
       'Callback', 'caltracer(''save_experiment_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{midx}.file, ...
       'Label', 'New CalTracer', ...
       'Enable', 'on', ...
       'Callback', 'caltracer(''new_ct_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{midx}.file, ...
       'Label', 'Quit', ...
       'Callback', 'caltracer(''ct_ClosingFcn'', gcbo, guidata(gcbo))');

% Setup preferences menu.
midx = get_menu_label_idx(handles, 'Preferences');
handles.menugroup{midx}.preferences = uimenu('Label', 'Preferences');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Long Raster', ...
       'Callback', 'caltracer(''long_raster_callback'', gcbo, guidata(gcbo))', ...
       'Checked', 'on', ...
       'Enable', 'off');
% uimenu(handles.menugroup{midx}.preferences, ...
%        'Label', 'Use contour slider', ...
%        'Callback', 'caltracer(''use_contour_slider_callback'',gcbo,guidata(gcbo))',...
%        'Checked', 'off', ...
%        'Enable', 'off');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Display centroids on selected (pixels)', ...
       'Callback', 'caltracer(''display_centroids_on_selection_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Display ids on all contours', ...
       'Callback', 'caltracer(''display_ids_on_all_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Display ids on selected contours', ...
       'Callback', 'caltracer(''display_ids_on_selected_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Show ordering line', ...
       'Callback', 'caltracer(''show_ordering_line_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.preferences, ...
       'Label', 'Show contour ordering', ...
       'Callback', 'caltracer(''show_contour_ordering_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');

% Setup menu and menu group.
midx = get_menu_label_idx(handles, 'Export');
handles.menugroup{midx}.export = ...
    uimenu('Label', 'Export', ...
	   'Enable', 'on');
% Add the menu items.
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Copy axis as metafile to clipboard', ...
       'Enable', 'On', ...
       'Callback', 'caltracer(''copy_axis_as_meta_to_clipboard_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Copy axis to new figure', ...
       'Enable', 'On', ...
       'Callback', 'caltracer(''copy_axis_to_new_figure_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Export contours', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer(''export_contours_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Export contours to file', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer(''export_contours_to_file_callback'', gcbo, guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Export traces', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer(''export_traces_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
       'Label', 'Export active cell traces', ...
       'Enable', 'Off', ...
       'Callback', 'caltracer(''export_active_cell_traces_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
    'Label', 'All centroids to vnt file', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer(''all_centroids_to_vnt_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
    'Label', 'All centroids to vnt file (more than once)', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer(''all_centroids_to_vnt_repeat_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
    'Label', 'All centroids to vnt file (more than one pulse per target)', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer(''all_centroids_to_vnt_pulses_callback'',gcbo,guidata(gcbo))');
uimenu(handles.menugroup{midx}.export, ...
    'Label', 'Active cells to vnt file', ...
    'Enable', 'Off', ...
    'Callback', 'caltracer(''active_cells_to_vnt_callback'',gcbo,guidata(gcbo))');



% Setup menu and menu group.
midx = get_menu_label_idx(handles, 'Preprocessing');
handles.menugroup{midx}.preprocessing = ...
    uimenu('Label', 'Preprocessing', ...
	   'Enable', 'On');
% Add the menu items.
uimenu(handles.menugroup{midx}.preprocessing, ...
       'Label', 'Preprocessing Options', ...
       'Callback', 'caltracer(''preprocessing_options_callback'', gcbo, guidata(gcbo))',...
       'Enable', 'off');


% Setup menu and menu group.
midx = get_menu_label_idx(handles, 'Contours');
handles.menugroup{midx}.contours = ...
    uimenu('Label', 'Contours', ...
	   'Enable', 'On');
% Add the menu items.
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Tile Region', ...
       'Callback', 'caltracer(''tile_region_callback'', gcbo, guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Tile region with rectangles',...
       'Callback', ...
       'caltracer(''tile_region_with_rectangles_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Randomize contour order',...
       'Callback', ...
       'caltracer(''randomize_contour_order_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Keep only brightest contours',...
       'Callback', ...
       'caltracer(''keep_only_brightest_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Keep random contours',...
       'Callback', ...
       'caltracer(''keep_random_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Keep last contours',...
       'Callback', ...
       'caltracer(''keep_last_contours_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Keep last contours & randomize order',...
       'Callback', ...
       'caltracer(''keep_last_contours_randomize_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Convert contours to parallel image',...
       'Callback', ...
       'caltracer(''convert_contours_to_parallel_image_callback'',gcbo, guidata(gcbo))',...
       'Enable', 'off');   
uimenu(handles.menugroup{midx}.contours, ...
   'Label', 'Make all contours active', ...
   'Callback', 'caltracer(''make_all_contours_active_callback'',gcbo,guidata(gcbo))',...
   'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Highlight contours by order', ...
       'Callback','caltracer(''highlight_contours_by_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Highlight contours by order (in partition)', ...
       'Callback','caltracer(''highlight_contours_by_order_in_partition_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Highlight contours by cluster id', ...
       'Callback','caltracer(''highlight_contours_by_cluster_id_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Connect highlighted contours in order', ...
       'Callback', 'caltracer(''connect_highlighted_contours_in_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Plot highlighted contours', ...
       'Callback', 'caltracer(''plot_highlighted_contours_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.contours, ...
       'Label', 'Turn active contours off', ...
       'Callback', 'caltracer(''turn_active_contours_off_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');

% Setup menu and menu group.
midx = get_menu_label_idx(handles, 'Clustering');
handles.menugroup{midx}.clustering = ...
    uimenu('Label', 'Clustering', ...
	   'Enable', 'On');
% Add the menu items.
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Highlight all clusters', ...
       'Callback', 'caltracer(''highlight_all_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Unhighlight all clusters', ...
       'Callback', 'caltracer(''unhighlight_all_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Merge highlighted clusters', ...
       'Callback', 'caltracer(''merge_highlighted_clusters_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Delete clusters by id', ...
       'Callback', 'caltracer(''delete_clusters_by_id_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Delete clusters by size', ...
       'Callback', 'caltracer(''delete_clusters_by_size_callback'',gcbo,guidata(gcbo))', ...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Delete contours by order', ...
       'Callback','caltracer(''delete_contours_by_order_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');
uimenu(handles.menugroup{midx}.clustering, ...
       'Label', 'Order clusters by intensity peak', ...
       'Callback', 'caltracer(''order_clusters_by_intensity_peak_callback'',gcbo,guidata(gcbo))',...
       'Enable', 'off');

      
% Setup the Functions group.
midx = get_menu_label_idx(handles, 'Functions');
handles.menugroup{midx}.functions = uimenu('Label', 'Functions');
% Add the menu items.


% In the case of the functions menu, the menu items are functions that
% are created by individual users.  As such, the directory is read at
% the opening of the epo program and the menu is loaded with all the
% functions that are prefaced with 'ct_'.  The functions are then
% enabled during the signals part of the program, where program
% control is passed to the called function upon user menu selection.
% -DCS:2005/08/02
[st, function_names] = readdir(handles, 'signalfunctions');
for i = 1:length(st)
   uimenu(handles.menugroup{midx}.functions, ...
       'Label', st{i}, ...
       'Enable', 'off', ...
       'UserData', function_names{i}, ...
       'Callback', 'caltracer(''signal_functions_callback'',gcbo,guidata(gcbo))');
end
% Sort of a hack because there should be a general mechanism for
% functions that don't disturb the handles and can be enabed earlier.
% This simply measures the distanre on the axis. -DCS:2005/08/11
handles = menuset(handles, 'functions','functions','measure_distance','Enable','on');


% The GUI flow goes basicall in this order, too:
% logo->image->...->filterimage->detectcells->...
handles.uigroupLabels = ...
    {'logo', 'image', 'resolution', 'regions', 'filterimage', ...
     'filterimagebadpixels','detectcells', 'consolidatemaps', 'halos',...
     'signals'};

%%%y
lidx = get_label_idx(handles, 'logo');
handles.uigroup{lidx}.logoim = axes('position',[0.25 0.3 0.4 0.4]);
%handles.uigroup{lidx}.logoim = imagesc(handles.appData.logo);
handles.uigroup{lidx}.logoname = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',[handles.appData.title ' ' num2str(handles.appData.versionNum,4)],...
	      'Position',[.25 .7 .4 .05], ...
	      'HorizontalAlignment','left', ...
	      'FontSize',18, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'foregroundcolor',[1 0 0]);
handles.uigroup{lidx}.myname1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',{'by David Sussillo, Dmitry Aronov';'& Brendon Watson'}, ...
	      'Position',[.25 .2 .4 .05], ...
	      'HorizontalAlignment','center', ...
	      'FontSize',14, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'foregroundcolor',[1 0 0]);
% handles.uigroup{lidx}.myname2 = ...
%     uicontrol('Style','text', ...
% 	      'Units','normalized', ...
% 	      'String',' Dmitriy Aronov (da2006@columbia.edu)', ...
% 	      'Position',[.25 .17 .40 .05], ...
% 	      'HorizontalAlignment','center', ...
% 	      'FontSize',14, ...
% 	      'FontWeight','Bold', ...
% 	      'BackgroundColor',[.8 .8 .8], ...
% 	      'foregroundcolor',[1 0 0]);

% GUI widgets.
lidx = get_label_idx(handles, 'image');
handles.uigroup{lidx}.imgax = ...
    axes('position', [0.02 0.02 0.82 0.94], ...
	 'Visible', 'off');
handles.uigroup{lidx}.textstring1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Image', ...
	      'Position',[.87 .955 .11 0.03], ...
	      'FontSize', 12, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.bopenimage = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Open', ...
	      'Position',[.87 .91 .05 .03], ...
	      'FontSize',9, ...
	      'Callback','caltracer(''open_image_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.bopenimageas = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Open As', ...
	      'Position',[.93 .91 .05 .03], ...
	      'FontSize',9, ...
	      'Callback','caltracer(''open_image_as_callback'',gcbo,guidata(gcbo))');
% handles.uigroup{lidx}.bzoom = ...
%     uicontrol('Style','pushbutton', ...
% 	      'Units','normalized', ...
% 	      'String','Zoom', ...
% 	      'Position', [.93 .91 .05 .03], ...
% 	      'FontSize', 9, ...
% 	      'Callback','zoom on', ...	%%% Should change?
% 	      'Enable','off');
handles.uigroup{lidx}.textstring2 = ...
    uicontrol('Style','text', ...
	      'units','normalized', ...
	      'string','Brightness', ...
	      'position',[.87 .88 .11 .02], ...
	      'FontSize',9, ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.bbright = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[.87 .86 .11 .02], ...
	      'Min',0, ...
	      'Max',1, ...
	      'Sliderstep',[.01 .05], ...
	      'Value',1/3, ...
	      'Enable','off', ...
	      'Callback','caltracer(''adjust_contrast_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.textstring3 = ...
    uicontrol('Style','text', ...
	      'units','normalized', ...
	      'string','Contrast', ...
	      'position',[.87 .83 .11 .02], ...
	      'FontSize',9, ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.bcontrast = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[.87 .81 .11 .02], ...
	      'Min',0, ...
	      'Max',1, ...
	      'Sliderstep',[.01 .05], ...
	      'Value',1/3, ...
	      'Enable','off', ...
	      'Callback', 'caltracer(''adjust_contrast_callback'',gcbo, guidata(gcbo))');

lidx = get_label_idx(handles, 'resolution');
handles.uigroup{lidx}.res_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Resolution', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txlabsr = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Spatial (�m/pixel)', ...
	      'Position',[.87 .715 .11 0.02], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.inptsr = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','1', ...
	      'Position',[.87 .715-0.0275 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment', 'left', ...
	      'enable', 'off');
handles.uigroup{lidx}.txlabtr = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Temporal (sec/frame)', ...
	      'Position',[.87 .715-0.0275-0.025 .11 0.02], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.inpttr = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','1', ...
	      'Position',[.87 .715-2*0.0275-0.025 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left', ...
	      'Enable','off');
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','off', ...
	      'Callback','caltracer(''setup_regions_callback'',gcbo,guidata(gcbo))');
%%%?

%Region widgets, complete with callback functions.
lidx = get_label_idx(handles, 'regions');
handles.uigroup{lidx}.regax = ...
    axes('position',[0.87 0.64 0.11 0.10], ...
	 'Visible', 'Off');
handles.uigroup{lidx}.bord_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized',...
	      'String','Regions', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'Off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.bord_add = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.90 .595 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...
	      'Enable','on', ...
	      'Callback','caltracer(''create_region_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.bord_delete = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.90 .555 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...
	      'Enable','off', ...
	      'Callback','caltracer(''delete_region_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','on', ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer(''name_regions'',gcbo,guidata(gcbo))');

% Image filtering functions.
lidx = get_label_idx(handles, 'filterimage');
handles.uigroup{lidx}.det_tx1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Image filter', ...
	      'Position',[.87 .60 .11 0.02], ...
	      'FontSize',9,...
	      'FontWeight','Bold',...
          'HorizontalAlignment','left', ...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpfilters = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .5725 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.det_loc = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Filter', ...
	      'Position',[.87 .535 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer(''ct_filter_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.det_view = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','View', ...
	      'Position',[.93 .535 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'Off', ...	     
	      'Callback','caltracer(''view_filtered_image'',gcbo,guidata(gcbo))',...
	      'enable','off');

% Image filtering functions.
lidx = get_label_idx(handles, 'filterimagebadpixels');      
handles.uigroup{lidx}.badpixtitle = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Remove for filtering', ...
	      'Position',[.87 .4925 .11 0.02], ...
	      'FontSize',9,...
	      'FontWeight','Bold',...
          'HorizontalAlignment','left', ...
	      'Visible', 'Off', ...	     
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.leftcolslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Left Columns', ...
	      'Position',[.87 .4625 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer(''view_filtered_image'',gcbo,guidata(gcbo))');      
handles.uigroup{lidx}.leftcols = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .46 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','leftcols',...
          'Callback','caltracer(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 
handles.uigroup{lidx}.rightcolslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Right Columns', ...
	      'Position',[.87 .4325 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);   
handles.uigroup{lidx}.rightcols = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .43 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','rightcols',...
          'Callback','caltracer(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 
handles.uigroup{lidx}.upperrowslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Upper Rows', ...
	      'Position',[.87 .4025 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.upperrows = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .40 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','upperrows',...
          'Callback','caltracer(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 
handles.uigroup{lidx}.lowerrowslabel = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Lower Rows', ...
	      'Position',[.87 .3725 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.lowerrows = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','0', ...
	      'Position',[.95 .37 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left',...
          'tag','lowerrows',...
          'Callback','caltracer(''show_save_bad_pixels_callback'',gcbo,guidata(gcbo))'); 
      

% The widgets that really detect the cells, not filter.
lidx = get_label_idx(handles, 'detectcells');
%widgets actually novel to this group
handles.uigroup{lidx}.txlab = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .49 .11 0.025], ...
	      'FontSize',10, ...
	      'FontWeight','Bold',...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1]); %%% bgcolor too!
handles.uigroup{lidx}.dummyp(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Cutoff %', ...
	      'Position',[.87 .4625 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txthres = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','(Uninitialized)', ...
	      'Position',[.95 .46 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
% Doesn't work in uicontros but does in titles. -DCS:2005/08/08
%units = texlabel('(um^2)');
units = '(um^2)';
handles.uigroup{lidx}.dummyp(2) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',['Min area ' units], ...
	      'Position',[.87 .4325 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txarlow = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .43 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.dummyp(3) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String',['Max area ' units], ...
	      'Position',[.87 .4025 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txarhigh = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .40 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btdetect = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Detect', ...
	      'Position',[.87 .3625 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''detect_cells_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.bthide = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Hide', ...
	      'Position',[.93 .3625 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''bthide_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummyp(4) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Pi limit', ...
	      'Position',[.8725 .32 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txpilim = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.95 .32 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btfindbad = ...
    uicontrol('Style','pushbutton', ...		      
	      'Units','normalized', ...
	      'String','Find', ...
	      'Position',[.87 .286 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''find_bad_cells_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadjust = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Adjust', ...
	      'Position',[.93 .286 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''adjust_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdeletepi = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .255 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''delete_high_pi_contours_callback'',gcbo,guidata(gcbo))');
%handles.uigroup{lidx}.btprev = ...
%    uicontrol('Style','pushbutton', ...
%	      'Units','normalized', ...
%	      'String','<< Prev', ...
%	      'Position',[.87 .205 .05 0.03], ...
%	      'FontSize',9,...
%	      'Visible', 'off', ...
%	      'Callback','caltracer(''btprev_callback'',gcbo,guidata(gcbo))');
%handles.uigroup{lidx}.btnext = ...
%    uicontrol('Style','pushbutton', ...
%	      'Units','normalized', ...
%	      'String','Next >>', ...
%	      'Position',[.93 .205 .05 0.03], ...
%	      'FontSize',9,...
%	      'Visible', 'off', ...
%	      'Callback','caltracer(''btnext_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummyp(6) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Move contours', ...
	      'Position',[.87 .215 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.moveall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move All', ...
	      'Position',[.87 .1875 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''move_all_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.rotateall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Rotate All', ...
	      'Position',[.93 .1875 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''rotate_all_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.moveone = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move One', ...
	      'Position',[.87 .1565 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''move_one_contour_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummyp(5) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Manual add/delete shape', ...
	      'Position',[.87 .135 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.shaperad1 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Circle', ...
	      'Position',[.87 .115 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''detectcells_shaperad1_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad2 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Custom', ...
	      'Position',[.925 .115 .055 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''detectcells_shaperad2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadd = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.87 .085 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''manual_contour_add_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdelete = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .085 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''manual_contour_delete_callback'',gcbo,guidata(gcbo))',...
	      'enable','off');
handles.uigroup{lidx}.btloadcontours = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Load', ...
	      'Position', [.87 0.054 .05 0.03], ...
	      'FontSize', 9, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''load_contours_callback'',gcbo,guidata(gcbo))');

handles.uigroup{lidx}.reset = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Reset', ...
	      'Position',[.87 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','on', ...
	      'Callback','caltracer(''reset_detect_screen_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btnextscr = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''detect_cells_next_callback'',gcbo,guidata(gcbo))', ...
 	      'enable','off');
      

lidx = get_label_idx(handles, 'consolidatemaps');
handles.uigroup{lidx}.map_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Consolidate', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dummyp(5) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Manual add shape', ...
	      'Position',[.87 .1725 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.stoverlap = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Overlap %', ...
	      'Position',[.87 .34 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...	      
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txoverlap = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String','10', ...
	      'Position',[.95 .34 .03 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.adjustkeep = ...
   uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Classify', ...
	      'Position',[.925 .29 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''adjustkeep_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.adjustseparate = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Eliminate', ...
	      'Position',[.87 .29 .055 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''adjustseparate_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btfindbad = ...
    uicontrol('Style','pushbutton', ...		      
	      'Units','normalized', ...
	      'String','Find', ...
	      'Position',[.87 .26 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''find_overlap_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadjust = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Adjust', ...
	      'Position',[.93 .26 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''adjust_overlap_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.movetext = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Move contours', ...
	      'Position',[.87 .235 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.moveall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Move All', ...
	      'Position',[.87 .2075 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''move_all_contours2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.rotateall = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Rotate All', ...
	      'Position',[.93 .2075 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''rotate_all_contours2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad1 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Circle', ...
	      'Position',[.87 .145 .05 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',1, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''consolidatemaps_shaperad1_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.shaperad2 = ...
    uicontrol('Style','radiobutton', ...
	      'Units','normalized', ...
	      'String','Custom', ...
	      'Position',[.925 .145 .055 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Value',0, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''consolidatemaps_shaperad2_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btadd = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Add', ...
	      'Position',[.87 .11 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''manual_contour_add_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.btdelete = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Delete', ...
	      'Position',[.93 .11 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''manual_contour_delete_callback'',gcbo,guidata(gcbo))',...
	      'enable','off');
handles.uigroup{lidx}.btnextscr = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''setup_halos_callback'',gcbo,guidata(gcbo))', ...
 	      'enable','on');



% The widgets that read the traces and create halos..
lidx = get_label_idx(handles, 'halos');
handles.uigroup{lidx}.trace_title = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Traces', ...
	      'Position',[.87 .755 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.halo_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Use halos', ...
	      'Value', 1, ...
	      'Position',[.87 .715 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''halo_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.dummy(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Halo area', ...
	      'Position',[.87 0.6875 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.inpthaloar = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 0.6625 .11 0.025], ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'enable','on');
handles.uigroup{lidx}.btupdate = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Update', ...
	      'Position',[.93 .6175 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''halo_update_callback'',gcbo,guidata(gcbo))',...
	      'enable','on');
handles.uigroup{lidx}.dummy(2) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Trace reader', ...
	      'Position',[.87 0.575 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpreaders = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .55 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Visible', 'off', ...
	      'Callback','caltracer(''setup_signals_callback'',gcbo,guidata(gcbo))');

lidx = get_label_idx(handles, 'signals');
 handles.uigroup{lidx}.textstring1 = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Signals', ...
	      'Position',[.87 .955 .11 0.03], ...
	      'FontSize',12, ...
	      'FontWeight','Bold', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.trace_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show raw', ...
	      'Position',[.87 .93 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Value', 0, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Tag', handles.appData.showCheckBoxTag,...
	      'UserData', 1, ...
	      'Callback','caltracer(''trace_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.clean_trace_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show clean', ...
	      'Position',[.87 .91 .11 0.025], ...
	      'FontSize',9,...
          'Value', 1, ...
          'Visible', 'off', ...
	      'Tag', handles.appData.showCheckBoxTag,...
	      'UserData', 2, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer(''clean_trace_check_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.halo_raw_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show halo raw', ...
	      'Position',[.87 .89 .11 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Tag', handles.appData.showHaloCheckBoxTag,...
	      'UserData', 1, ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer(''halo_raw_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.halo_preprocess_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show halo clean', ...
	      'Position',[.87 .87 .11 0.025], ...
	      'FontSize',9,...
	      'Tag', handles.appData.showHaloCheckBoxTag,...
	      'UserData', 2, ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer(''halo_preprocess_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.signals_check = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String','Show signals', ...
	      'Position',[.87 .850 .11 0.025], ...
	      'FontSize',9,...
          'Value',1,...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8], ...
	      'Callback','caltracer(''signals_checkbox_callback'',gcbo,guidata(gcbo))');
      
      
handles.uigroup{lidx}.FrameSpecTitle = ...
    uicontrol('Style','Text',...
        'String','Frame Input Type',...
        'FontWeight','Bold',...
        'Units','Normalized',...
        'Position',[.855 .82 .13 .025],...
        'Visible','off',...
        'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.use_frame_click_input_checkbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Click Input', ...
	      'Position',[.87 .81 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Value',0,...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer(''click_frame_input_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.use_numerical_frame_input_checkbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Number Input', ...
	      'Position',[.87 .79 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Value',0,...
	      'BackgroundColor',[.8 .8 .8],...
          'Callback','caltracer(''numerical_frame_input_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.use_numerical_frame_input_min = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
          'Position',[.88 .775 .035 0.0175], ...
	      'FontSize',9,...
	      'Visible', 'Off',...	
          'Enable','Off',...
          'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.use_numerical_frame_input_max = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
          'Position',[.93 .775 .035 0.0175], ...
	      'FontSize',9,...
	      'Visible', 'Off',...
          'Enable','Off',...
          'BackgroundColor',[1 1 1]);


handles.uigroup{lidx}.numslider = ...
    uicontrol('Style','slider', ...
	      'Units','normalized', ...
	      'Position',[0.05 0.0 0.79 0.03], ...
	      'Callback','caltracer(''numslider_callback'',gcbo,guidata(gcbo))', ... 
	      'Min', 0, ...
	      'Max', 1, ...		% (Uninitialized)
	      'Sliderstep', 0:1, ...	% (Uninitialized)
	      'Visible', 'off', ...
	      'Value', 1);

% Clustering widgets.
handles.uigroup{lidx}.stxdimreduxmethod = ...
    uicontrol('Style', 'text', ...
	      'Units', 'normalized', ...
	      'String', 'Dim Reduction', ...
	      'Position', [.87 .7500 .11 0.02], ...
	      'FontSize', 9, ...
	      'Visible', 'off', ...
	      'HorizontalAlignment', 'left', ...
	      'BackgroundColor', [.8 .8 .8]);
handles.uigroup{lidx}.dpdimreducers = ...
    uicontrol('Style', 'popupmenu', ...
	      'String', '(Uninitialized)', ...
	      'Units', 'normalized', ...
	      'Position', [.87 .7250 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize', 9, ...
	      'HorizontalAlignment', 'left', ...
	      'BackgroundColor', [1 1 1]);
handles.uigroup{lidx}.stxclustermethod = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Cluster method', ...
	      'Position',[.87 .7000 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpclassifiers = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .6750 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.stxnclusters = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Num clusters  Num trials', ...
	      'Position',[.87 .6500 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.txnclusters = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '1', ...
	      'Position',[.87 .6250 .05 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.txntrials = ...
    uicontrol('Style','edit', ...
	      'Units','normalized', ...
	      'String', '1', ...
	      'Position',[.94 .6250 .05 0.025], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'BackgroundColor',[1 1 1], ...
	      'HorizontalAlignment','left');
handles.uigroup{lidx}.btcluster = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Cluster', ...
	      'Position',[.87 .5900 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''cluster_callback'',gcbo,guidata(gcbo))');

handles.uigroup{lidx}.stsavedclusterings = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Partitions', ...
	      'Position',[.87 .5650 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.clusterpopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .5400 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer(''clusterpopup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);

% Contour order widgets.
handles.uigroup{lidx}.stxcontourorder = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Contour Order', ...
	      'Position',[.87 .4500 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dporderroutines = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .4250 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.btreorder = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Order', ...
	      'Position',[.87 .3900 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''order_contours_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.stsavedcontourorders = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Contour Orders', ...
	      'Position',[.87 .3650 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.contourorderpopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .3400 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer(''contour_order_popup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);




% Signal detector stuff.
handles.uigroup{lidx}.dummy(1) = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Signal Detector', ...
	      'Position',[.87 0.2525 .11 0.02], ...
	      'FontSize',9,...
	      'HorizontalAlignment','left', ...
	      'Visible', 'off', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.dpdetectors = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .2275 .12 0.025], ...
	      'Visible', 'off', ...
	      'FontSize',9,...
	      'BackgroundColor',[1 1 1]);
handles.uigroup{lidx}.btdetect = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Detect', ...
	      'Position',[.87 .1925 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''detect_signals_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.stsavedsignals = ...
    uicontrol('Style','text', ...
	      'Units','normalized', ...
	      'String','Saved Signals', ...
	      'Position',[.87 .1675 .11 0.02], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'HorizontalAlignment','left', ...
	      'BackgroundColor',[.8 .8 .8]);
handles.uigroup{lidx}.signalspopup = ...
    uicontrol('Style','popupmenu', ...
	      'Units','normalized', ...
	      'String', '(Uninitialized)', ...
	      'Position',[.87 .1425 .12 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
	      'Callback', 'caltracer(''signals_popup_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[1 1 1]);
%handles.uigroup{lidx}.signals_radio = ...
%    uicontrol('Style','radio',...
%        'Units','normalized',...
%        'Position',[.87 .1125 .03 .03],...
%        'Value',0,...
%        'Visible','off',...
%        'BackgroundColor',[.8 .8 .8],...
%        'Callback','caltracer(''signals_radio_callback'',gcbo,guidata(gcbo))');
%handles.uigroup{lidx}.signals_radio_label = ...
%    uicontrol('Style','text',...
%	      'Units','normalized',...
%	      'Position',[.89 .1125 .10 .03],...
%	      'String','Show Event Markers',...
%	      'Visible','off',...
%	      'BackgroundColor',[.8 .8 .8]);


handles.uigroup{lidx}.btexporttoanalyzer = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','To Anaylzer', ...
	      'Position',[.87 .05 .05 0.03], ...
	      'FontSize',9,...
	      'Visible', 'off', ...
	      'Callback','caltracer(''export_signals_to_analyzer_callback'',gcbo,guidata(gcbo))');
handles.uigroup{lidx}.signaleditmodecheckbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Edit Signals', ...
	      'Position',[.87 .02 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Callback', 'caltracer(''signal_edit_mode_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[.8 .8 .8]);


      
      
%contour slider checkbox at bottom
handles.uigroup{lidx}.contourslidercheckbox = ...
    uicontrol('Style','checkbox', ...
	      'Units','normalized', ...
	      'String', 'Single Contour Display', ...
	      'Position',[.87 0 .125 0.025], ...
	      'FontSize',9,...
	      'Visible', 'Off', ...	
          'Callback', 'caltracer(''use_contour_slider_callback'',gcbo,guidata(gcbo))',...
	      'BackgroundColor',[.8 .8 .8]);

      


lidx = get_label_idx(handles, 'logo');
axes(handles.uigroup{lidx}.logoim);
handles.appData.logoImage = imagesc(handles.appData.logo);
axis equal;
axis off;


% Save the data before we leave.
guidata(hObject, handles);

%%
% function ct_OutputFcn
function ct_OutputFcn
1;					% do nothing for now.


%%
%%%%% Callbacks
function open_image_callback(hObject, handles)
% 'tcImage' is the name for the real movie, not any masks.

newhandles = open_image(handles);
if isempty(newhandles)
    return
else
    handles = newhandles;
end

if isfield(handles.appData,'logoImage');
    delete(handles.appData.logoImage);
    handles.appData = rmfield(handles.appData,'logoImage');
end
guidata(hObject, handles);

%%
function open_image_as_callback(hObject, handles)

[filename, pathname] = uigetfile({'*.mat'}, 'Choose analyzed movie to open the same way as');
if ~ischar(filename)
    return
end
fnm = [pathname filename];
savestruct = load(fnm);
app_data = ct_add_missing_options(savestruct.A);
[experiment app_data] = ct_add_missing_options_exp(savestruct.E, app_data);
app_data = ct_add_missing_options2(app_data, experiment);

openaslist = {'Image Opening',...
    'Spatial Resolution',...
    'Temporal Resolution',...
    'Skip Regions',...
    'Image Filter',...
    'Load Contours',...
    'Halo Area',...
    'Skip Halos',...
    'Flip Signals'};
%     'Later Masks',...
[selection,value] = listdlg('PromptString','"Open As" using which features:',...
                'SelectionMode','multiple',...
                'ListString', openaslist,...
                'InitialValue',1:length(openaslist));
if value == 0;
    return
end

handles.appData.openedAs = fnm;
if ~isempty(find(selection == strmatch('Image Opening',openaslist)));
    newhandles = open_image(handles,['ct_',experiment.tcImage.frameType]);
else
    newhandles = open_image(handles);
end
if isempty(newhandles)
    return
else
    handles = newhandles;
end

if ~isempty(find(selection == strmatch('Skip Regions',openaslist)));
    handles.appData.skipThroughSettings.skipRegions.index = 1;
end
if ~isempty(find(selection == strmatch('Image Filter',openaslist)));
    handles.appData.skipThroughSettings.skipFilter.index = 1;
    handles.appData.skipThroughSettings.skipFilter.options{1} =...
        experiment.tcImage.filterName;
    handles.appData.skipThroughSettings.skipFilter.options{2} =...
        experiment.tcImage.filterParam;
end
if ~isempty(find(selection == strmatch('Load Contours',openaslist)));
    handles.appData.skipThroughSettings.autoLoadContours.index = 1;
end
if ~isempty(find(selection == strmatch('Halo Area',openaslist)));
    handles.appData.haloArea = app_data.haloArea;
end
if ~isempty(find(selection == strmatch('Skip Halos',openaslist)));
    handles.appData.skipThroughSettings.haloUpdate =...
        app_data.skipThroughSettings.haloUpdate;
end
if ~isempty(find(selection == strmatch('Skip Halos',openaslist)));
    handles.appData.skipThroughSettings.skipHaloWindow.index = 1;
end
if ~isempty(find(selection == strmatch('Flip Signals',openaslist)));
    handles.appData.skipThroughSettings.flipSignalQuestion =...
        app_data.skipThroughSettings.flipSignalQuestion;
end

guidata(hObject, handles);

lidx = get_label_idx(handles, 'resolution');
spatval = ~isempty(find(selection == strmatch('Spatial Resolution',openaslist)));
if spatval
    set(handles.uigroup{lidx}.inptsr,'string',experiment.mpp);
end
tempval = ~isempty(find(selection == strmatch('Temporal Resolution',openaslist)));
if tempval
    set(handles.uigroup{lidx}.inpttr,'string',experiment.timeRes);
end
if spatval & tempval
    caltracer('setup_regions_callback',gcbo,guidata(gcbo))
end


%%
% adjust_contrast_callback
function adjust_contrast_callback(hObject, handles)
handles = adjust_contrast(handles);
guidata(hObject, handles);


%%
% setup_regions_callback
function setup_regions_callback(hObject, handles)
handles = setup_regions(handles);
guidata(hObject, handles);
if handles.appData.skipThroughSettings.skipRegions.index > 0;
    name_regions(handles.fig, handles)
end


%%
% setup_regions
function handles = setup_regions(handles)
%Read resolution datar
handles.exp.spaceRes = ...
    str2num(uiget(handles, 'resolution', 'inptsr', 'string'));
handles.exp.mpp = handles.exp.spaceRes;	% microns per pixel
handles.exp.ppm = 1./handles.exp.mpp;	% pixels per micron.
handles.exp.timeRes = ...
    str2num(uiget(handles, 'resolution', 'inpttr', 'string'));
handles.exp.fs = 1./handles.exp.timeRes;
handles = uiset(handles, 'image', 'bopenimage', 'enable','off');
handles = hide_uigroup(handles, 'resolution');
handles = show_uigroup(handles, 'regions');
handles = determine_regions(handles);



%%
% regionmap_buttondown_callback
function regionmap_buttondown_callback(hObject, handles)
user_data = get(hObject, 'UserData');
ridx = user_data(1);
midx = user_data(2);
handles = save_detectcell_widget_values(handles);
%handles.guiOptions.face.isHid = 1;
%handles = hide_region_contours(handles);
%ridx = handles.appData.currentRegionIdx;
% Get the new region index.
names = handles.exp.regions.name;
%handles.appData.currentRegionIdx = mod(ridx+length(names)-2,length(names))+1;
handles.appData.currentRegionIdx = ridx;
handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);



%%
function create_region_callback(hObject, handles)
handles = create_region(handles);
guidata(hObject, handles);


%%
function delete_region_callback(hObject, handles)
handles = delete_region(handles);
guidata(hObject, handles);


%%
% name_regions
function name_regions(hObject, handles)
coords = handles.exp.regions.coords;
% Hide the create and delete widgets.
handles = hide_uiwidget(handles, 'regions', 'bord_add');
handles = hide_uiwidget(handles, 'regions', 'bord_delete');
handles = hide_uiwidget(handles, 'regions', 'bnext');
cl = hsv(length(coords));
for c = 1:length(coords)
%    region.coords{c} = reg{c};
    lidx = get_label_idx(handles, 'regions');
    handles.uigroup{lidx}.txlab(c) = ...
	uicontrol('Style','text', ...
		  'Units','normalized', ...
		  'String',['Region ' num2str(c)], ...
		  'Position',[.87 .60-(c-1)*.07 .11 0.025], ...
		  'FontSize',9,...
		  'HorizontalAlignment','left', ...
		  'BackgroundColor',cl(c,:));
    handles.uigroup{lidx}.inpt(c) = ...
	uicontrol('Style','edit', ...
		  'Units','normalized', ...
		  'String',['Name ' num2str(c)], ...
		  'Position',[.87 .60-(c-1)*.07-0.035 .11 0.03], ...
		  'FontSize',9,...
		  'BackgroundColor',[1 1 1], ...
		  'HorizontalAlignment','left');
end



%%% FYI, this resets bnext, so if we ever allow backwards, this
% will break. -DCS:2005/03/16
handles.uigroup{lidx}.bnext = ...
    uicontrol('Style','pushbutton', ...
	      'Units','normalized', ...
	      'String','Next >>', ...
	      'Position',[.93 .02 .05 .03], ...
	      'FontSize',9, ...
	      'Enable','on', ...
	      'Callback','caltracer(''setup_filter_image'',gcbo,guidata(gcbo))');
guidata(hObject, handles);
if handles.appData.skipThroughSettings.skipRegions.index > 0;
    caltracer('setup_filter_image',hObject, handles)
end



%%
% setup_filter_image
function setup_filter_image(hObject, handles)
% Setup the GUI to filter the image.  This comes before cell
% detection.

% Before we move onto filtering, we can set the regions strutures.
% Set the name of the regions in the structure.
lidx = get_label_idx(handles, 'regions');
nregions = length(handles.exp.regions.coords);
for c = 1:nregions
    inpt = handles.uigroup{lidx}.inpt(c);
    handles.exp.regions.name{c} = get(inpt,'String');
end
handles.exp.numRegions = nregions;
handles.exp.regions.cl = hsv(nregions);
handles.exp.regions.contours = cell(1, nregions);
for r = 1:nregions
    handles.exp.regions.contours{r}{1} = [];
end


handles = menuset(handles, 'Contours','contours','Tile Region','Enable','on');
handles = menuset(handles, 'Contours','contours','Tile region with rectangles','Enable','on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show contour ordering', 'Enable', 'on');


% Should this be part of the regions?  I don't think so because they
% can be constructed from the region data above, and they have no life
% outside of the GUI.
handles.guiOptions.face.handl = cell(1, nregions);
% Include a cell array for the map index as well.
for r = 1:nregions
    handles.guiOptions.face.handl{r} = cell(1);
end
% Some initialization is going on here but only the first time.
handles.guiOptions.face.thresh = 15*ones(1, nregions);
handles.guiOptions.face.oldThresh = inf*ones(1, nregions);
handles.guiOptions.face.minArea = 10*ones(1, nregions);
handles.guiOptions.face.maxArea = repmat(inf,1, nregions);
handles.guiOptions.face.piLimit = 4*ones(1, nregions);
handles.guiOptions.face.isAdjusted = zeros(1, nregions);
handles.guiOptions.face.isDetected = zeros(1, nregions);
handles.guiOptions.face.isHid = zeros(1, nregions);

try%allow user to set cell detection preferences
    handles=ct_guiOptionsFacePreferences(handles,nregions);
end

% Now we switch the GUI from regions to filtering.
handles = hide_uigroup(handles, 'regions');
% Keep the region widget on for a little longer.
show_axis(handles.uigroup{lidx}.regax);
handles = show_uigroup(handles, 'filterimage');
handles = show_uigroup(handles, 'filterimagebadpixels');

% Load the various image filters from the directory.
[st, filter_names] = readdir(handles, 'imagefilters');
handles.appData.filterNames = filter_names;
handles = uiset(handles, 'filterimage', 'dpfilters', 'String', st);
guidata(hObject, handles);

if handles.appData.skipThroughSettings.skipFilter.index > 0;
    caltracer('ct_filter_callback',hObject, handles)
end

%%
function show_save_bad_pixels_callback(hObject, handles);

handles = show_save_bad_pixels(hObject,handles);
guidata(hObject, handles);

%%
function ct_filter_callback(hObject, handles)

midx = handles.appData.currentMaskIdx;
lidx = get_label_idx(handles, 'filterimagebadpixels');      

%go thru left, right, up, down and get value then delete the graphics box
imsz = size(handles.exp.tcImage(midx).image);
value = str2num(get(handles.uigroup{lidx}.leftcols,'String'));
startval = 1;
stopval = value;
if value == 0;
    handles.exp.tcImage(midx).badpixels.leftcols = [];
else            
    handles.exp.tcImage(midx).badpixels.leftcols = [startval:stopval];
end
value = str2num(get(handles.uigroup{lidx}.rightcols,'String'));
startval = (imsz(2)-value)+1;
stopval = imsz(2);
if value == 0;
    handles.exp.tcImage(midx).badpixels.rightcols = [];
else            
    handles.exp.tcImage(midx).badpixels.rightcols = [startval:stopval];
end
value = str2num(get(handles.uigroup{lidx}.upperrows,'String'));
startval = 1;
stopval = value;
if value == 0;
    handles.exp.tcImage(midx).badpixels.upperrows = [];
else            
    handles.exp.tcImage(midx).badpixels.upperrows = [startval:stopval];
end
value = str2num(get(handles.uigroup{lidx}.lowerrows,'String'));
startval = (imsz(1)-value)+1;
stopval = imsz(1);
if value == 0;
    handles.exp.tcImage(midx).badpixels.lowerrows = [];
else            
    handles.exp.tcImage(midx).badpixels.lowerrows = [startval:stopval];
end

if isfield (handles.exp.tcImage(midx).badpixels,'leftbox')
    if ~isempty(handles.exp.tcImage(midx).badpixels.leftbox);
        delete (handles.exp.tcImage(midx).badpixels.leftbox)
    end
end
if isfield (handles.exp.tcImage(midx).badpixels,'rightbox')
    if ~isempty(handles.exp.tcImage(midx).badpixels.rightbox);
        delete (handles.exp.tcImage(midx).badpixels.rightbox)
    end
end
if isfield (handles.exp.tcImage(midx).badpixels,'upperbox')
    if ~isempty(handles.exp.tcImage(midx).badpixels.upperbox);
        delete (handles.exp.tcImage(midx).badpixels.upperbox)
    end
end
if isfield (handles.exp.tcImage(midx).badpixels,'lowerbox')
    if ~isempty(handles.exp.tcImage(midx).badpixels.lowerbox);
        delete (handles.exp.tcImage(midx).badpixels.lowerbox)
    end
end

%actually filter now
handles = ct_filter(handles);
% If the cancel button was pressed or something went wrong.  Sort
% of ghetto but gets the job done.
if ~isfield(handles.exp.tcImage(midx), 'filteredImage');
    return;
end

handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);
if handles.appData.skipThroughSettings.autoLoadContours.index > 0;
    load_contours_callback(hObject, handles)
end


%%
% function view_filtered_image
function view_filtered_image(hObject, handles)
% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
indicator = 0;
if isfield(handles.appData,'mainTcImageSource');
    if strcmp(handles.appData.mainTcImageSource,'filtered')    
        indicator = 1;
    end
end
if indicator == 1;
    set(handles.appData.mainTcImage,'CData',handles.exp.tcImage(midx).image)
    handles.appData.mainTcImageSource = 'original';
elseif indicator == 0;
    set(handles.appData.mainTcImage,'CData',handles.exp.tcImage(midx).filteredImage)
    handles.appData.mainTcImageSource = 'filtered';
end
guidata(hObject, handles);
% figure('Name','Filtered image','NumberTitle','off','MenuBar','none');
% colormap gray
% imagesc(handles.exp.tcImage(midx).filteredImage);
% axis equal;
% axis off;
%zoom on;



%%
% sync_detectcell_buttons
function handles = sync_detectcell_buttons(handles)
% Load the right regions settings in the buttons and enable some things.
ridx = handles.appData.currentRegionIdx;
region = handles.exp.regions;
face = handles.guiOptions.face;
if strcmp(uiget(handles, 'filterimage', 'det_view','enable'),'off')
    %%% These comments will break something. -DCS:2005/04/05
    %handl = handles.guiOptions.face.handl;
    %nhandl = length(handl);
    %for c = 1:nhandl
%	if ~isempty(ishandle(face.handl{c}))
%	    valid_handles = find(ishandle(face.handl{c}));
%	    delete(face.handl{c}(valid_handles));
%	end
%    end
    
    handles = uiset(handles, 'filterimage', 'det_view', 'enable', 'on');
    handles = show_uigroup(handles, 'detectcells');
end
if strcmp(uiget(handles, 'filterimagebadpixels', 'leftcolslabel','visible'),'on')
    handles = hide_uigroup(handles,'filterimagebadpixels');
end

handles = uiset(handles, 'detectcells', 'txlab', ...
		'BackgroundColor',region.cl(ridx,:), ...
		'String', region.name{ridx});
handles = uiset(handles, 'detectcells', 'txthres', ...
		'String', num2str(face.thresh(ridx)));
handles = uiset(handles, 'detectcells', 'txarlow', ...
		'String', num2str(face.minArea(ridx)));
handles = uiset(handles, 'detectcells', 'txarhigh', ...
		'String', num2str(face.maxArea(ridx)));
handles = uiset(handles, 'detectcells', 'txpilim', ...
		'String', num2str(face.piLimit(ridx)));
%zoom on;

if (handles.guiOptions.face.isHid(ridx))
    str = 'Show';
else
    str = 'Hide';
end
handles = uiset(handles, 'detectcells', 'bthide', 'String', str);



%%
% tile_region_callback
function tile_region_callback(hObject, handles)
prompt = {'Enter the side length in um for each tile:'};
def = {'10'};
dlgTitle = 'Tile Side Length';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    errordlg('You must enter a valid side length.');
    return;
end

% Get the data from the uicontrols to find the cells.
ridx = handles.appData.currentRegionIdx;
% answer{1} is in um. So tileSide is in pixels!
handles.face.tileSide(ridx) = str2num(answer{1})/handles.exp.mpp;
handles = tile_region(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);


%% 
% tile_region_with_rectangles_callback
function tile_region_with_rectangles_callback(hObject, handles)
prompt = {'Enter the short side length in um of the rectangle:'};
def = {'10'};
dlgTitle = 'Tile with Rectangles Short Side Length';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('You must enter a valid side length.');
    return;
end
ridx = handles.appData.currentRegionIdx;
handles.face.tileType(ridx) = {'rectangle'};
handles.face.tileSide(ridx) = str2num(answer{1})/handles.exp.spaceRes;
handles = tile_region_with_rectangles(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);

%%
function randomize_contour_order_callback(hObject, handles);
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
contours = handles.exp.regions.contours{ridx}{midx};
numcells = size(contours,2);
[trash,inds]=sort(rand(1,numcells));
contours = contours(inds);
handles.exp.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);


%% 
function keep_only_brightest_contours_callback(hObject, handles)
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of brightest contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
contours = handles.exp.regions.contours{ridx}{midx};
if size(contours,2)>numcells;
    contours = keepbrightestcontours(contours,numcells,handles.exp.tcImage.image);
end
handles.exp.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

%% 
function keep_random_contours_callback(hObject, handles)
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
% if state == x;
%     contours = handles.exp.regions.contours{ridx}{midx};
% else
% end

contours = handles.exp.regions.contours{ridx}{midx};
if numcells<size(contours,2);
    inds = randperm(size(contours,2));
end
contours = contours(inds(1:numcells));
handles.exp.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);
%% 
function keep_last_contours_callback(hObject, handles)
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
contours = handles.exp.regions.contours{ridx}{midx};
% if state == x;
%     contours = handles.exp.regions.contours{ridx}{midx};
% else
% end
if numcells<size(contours,2);
    inds = size(contours,2)-(numcells-1):size(contours,2);
    contours = contours(inds);
end
handles.exp.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

%% 
function keep_last_contours_randomize_callback(hObject, handles)
prompt = {'Keep how many contours?'};
def = {'500'};
dlgTitle = 'Number of contours';
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if isempty(answer)
    errordlg('Not a recognized number.');
    return;
end
numcells = str2num(answer{1});
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
contours = handles.exp.regions.contours{ridx}{midx};
% if state == x;
%     contours = handles.exp.regions.contours{ridx}{midx};
% else
% end
if numcells<size(contours,2);
    inds = size(contours,2)-(numcells-1):size(contours,2);
    contours = contours(inds);
end
[trash,inds]=sort(rand(1,numcells));
contours = contours(inds);

handles.exp.regions.contours{ridx}{midx} = contours;
handles = draw_cell_contours(handles);
guidata(hObject, handles);

%%
% detect_cells_callback
function detect_cells_callback(hObject, handles)
handles = save_detectcell_widget_values(handles);
handles = detect_cells(handles);
handles = draw_cell_contours(handles);
% Allow export of contours
handles = menuset(handles, 'Contours','contours','Randomize contour order','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep only brightest contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep random contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours & randomize order','Enable','on');
handles = menuset(handles, 'Export', 'export', 'Export contours', 'Enable', 'on');
handles = menuset(handles, 'Export', 'export', 'Export contours to file', 'Enable', 'on');
guidata(hObject, handles);


%%
% cmnd
% This function was a string called before certain Call backs.
% Now it is called as the first thing in those callbacks.
function handles = save_detectcell_widget_values(handles)
% Set the values for cell detection based on the values in the widgets.
ridx = handles.appData.currentRegionIdx;
thresh = str2num(uiget(handles, 'detectcells', 'txthres', 'String'));
min_area = str2num(uiget(handles, 'detectcells', 'txarlow', 'String'));
max_area = str2num(uiget(handles, 'detectcells', 'txarhigh', 'String'));
pi_lim = str2num(uiget(handles, 'detectcells', 'txpilim', 'String'));
handles.guiOptions.face.thresh(ridx) = thresh;
handles.guiOptions.face.minArea(ridx) = min_area;
handles.guiOptions.face.maxArea(ridx) = max_area;
handles.guiOptions.face.piLimit(ridx) = pi_lim;



%%
% btprev_callback
function btprev_callback(hObject, handles)
handles = save_detectcell_widget_values(handles);
%handles.guiOptions.face.isHid = 1;
handles = hide_region_contours(handles);
ridx = handles.appData.currentRegionIdx;
% Get the new region index.
names = handles.exp.regions.name;
handles.appData.currentRegionIdx = mod(ridx+length(names)-2,length(names))+1;
handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);


%%
% btnext_callback
function btnext_callback(hObject, handles)
handles = save_detectcell_widget_values(handles);
%handles.guiOptions.face.isHid = 1;
handles = hide_region_contours(handles);
names = handles.exp.regions.name;
ridx = handles.appData.currentRegionIdx;
%%% Why are we only saving this one value, right here, right now?
%-DCS:2005/03/17
%handles.guiOptions.face.thresh(ridx) = ...
%    str2num(uiget(handles, 'detectcells', 'txthres', 'string'));
handles.appData.currentRegionIdx = mod(ridx,length(names))+1;
handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);



%%
%  bthide_callback
function bthide_callback(hObject, handles)
%handles.guiOptions.face.isHid = 1-handles.guiOptions.face.isHid;
handles = hide_region_contours(handles);
guidata(hObject, handles);



%%
% hide the contours for a given region.
function handles = hide_region_contours(handles)
ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;
if handles.guiOptions.face.isHid(ridx) == 0
    handles = uiset(handles, 'detectcells', 'bthide', 'string', 'Show');
    set(handles.guiOptions.face.handl{ridx}{midx}, 'visible', 'off');
    handles.guiOptions.face.isHid(ridx) = 1;
else
    handles = uiset(handles, 'detectcells', 'bthide', 'string', 'Hide');
    set(handles.guiOptions.face.handl{ridx}{midx}, 'visible', 'on');   
    % Assume that the handles already exist and are visible, this should avoid
    % color issues.
    %    handles = draw_cell_contours(handles);
    handles.guiOptions.face.isHid(ridx) = 0;
end


%%
% adjustkeep_callback
function adjustkeep_callback(hObject, handles)
handles = uiset(handles, 'consolidatemaps', 'adjustkeep', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'adjustseparate', 'value', 0);
guidata(hObject, handles);


%%
% adjustseparate_callback
function adjustseparate_callback(hObject, handles)
handles = uiset(handles, 'consolidatemaps', 'adjustseparate', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'adjustkeep', 'value', 0);
guidata(hObject, handles);

%%
function move_all_contours_callback(hObject,handles)
% Design a little gui here instead of ginput?
% Let user click 2 times... once for initial and once for new position.
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');
[x,y] = ginput(2);
x = x(2)-x(1);
y = y(2)-y(1);
midx = handles.appData.currentMaskIdx;

handles = move_all_contours(handles,x,y,midx);
handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);
%%

function move_one_contour_callback(hObject,handles)
% Design a little gui here instead of ginput?
% Let user click 2 times... once for initial and once for new position.
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

[ox,oy] = ginput(2);
x = ox(2)-ox(1);
y = oy(2)-oy(1);

midx = handles.appData.currentMaskIdx;
[cidx,ridx] = determine_cell_clicked(handles,midx,1:handles.exp.numRegions,ox(1),oy(1));
if length(cidx) > 1 | isempty(cidx);
    msgbox('You must click inside one cell');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return
end

handles = move_one_contour(handles,x,y,ridx,cidx,midx);
handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);

handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);

%%
% Sort of a hack becaues the second time (on consolidate maps, we
% don't want to redraw any regions or any region widgets, and we
% color by map..
function move_all_contours2_callback(hObject,handles)
% Design a little gui here instead of ginput?
% Let user click 2 times... once for initial and once for new position

handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');
[x,y] = ginput(2);
x = x(2)-x(1);
y = y(2)-y(1);
midx = handles.appData.currentMaskIdx;
handles = move_all_contours(handles,x,y,midx);
% It'd be nice to have a color for each map saved but didn't get to
% it. -DCS:2005/09/01
nmaps = length(handles.exp.tcImage);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx','all', ...
			     'color', mapcolors(midx,:));
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);


%%
function rotate_all_contours_callback(hObject,handles)
% Design a little gui here instead of ginput?
% Let user click 2 times... once for initial and once for new position.
% Assume rotation about center point of image

handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

fulcrum = size(handles.exp.tcImage(1).image);
fulcrum = (fulcrum * .5) + .5;

[x,y] = ginput(2);
x1 = x(1) - fulcrum(1);
x2 = x(2) - fulcrum(1);
y1 = y(1) - fulcrum(2);
y2 = y(2) - fulcrum(2);

midx = handles.appData.currentMaskIdx;

ang1 = atan2(y1,x1);
ang2 = atan2(y2,x2);
diffang = ang2 - ang1;

handles = rotate_all_contours(handles,diffang,fulcrum,midx);

handles = draw_cell_contours(handles,'ridx','all');
handles = redraw_regions(handles,hObject);
handles = draw_region_widget(handles);

handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);


%%
% Sort of a hack becaues the second time (on consolidate maps, we
% don't want to redraw any regions or any region widgets, and we
% color by map..
function rotate_all_contours2_callback(hObject,handles)
% Design a little gui here instead of ginput?
% Let user click 2 times... once for initial and once for new position
handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

fulcrum = size(handles.exp.tcImage(1).image);
fulcrum = (fulcrum * .5) + .5;

[x,y] = ginput(2);
x1 = x(1) - fulcrum(1);
x2 = x(2) - fulcrum(1);
y1 = y(1) - fulcrum(2);
y2 = y(2) - fulcrum(2);

midx = handles.appData.currentMaskIdx;

ang1 = atan2(y1,x1);
ang2 = atan2(y2,x2);
diffang = ang2 - ang1;

handles = rotate_all_contours(handles,diffang,fulcrum,midx);

% It'd be nice to have a color for each map saved but didn't get to
% it. -DCS:2005/09/01
nmaps = length(handles.exp.tcImage);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx','all', ...
			     'color', mapcolors(midx,:));
             
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');
guidata(hObject, handles);


%%
% detectcells_shaperad1_callback
function detectcells_shaperad1_callback(hObject, handles)
handles = uiset(handles, 'detectcells', 'shaperad1', 'value', 1);
handles = uiset(handles, 'detectcells', 'shaperad2', 'value', 0);
guidata(hObject, handles);



%%
% consolidate_shaperad2_callback
function detectcells_shaperad2_callback(hObject, handles)
handles = uiset(handles, 'detectcells', 'shaperad1', 'value', 0);
handles = uiset(handles, 'detectcells', 'shaperad2', 'value', 1);
guidata(hObject, handles);



%%
% consolidate_shaperad1_callback
function consolidatemaps_shaperad1_callback(hObject, handles)
handles = uiset(handles, 'consolidatemaps', 'shaperad1', 'value', 1);
handles = uiset(handles, 'consolidatemaps', 'shaperad2', 'value', 0);
guidata(hObject, handles);



%%
% consolidate_shaperad2_callback
function consolidatemaps_shaperad2_callback(hObject, handles)
handles = uiset(handles, 'consolidatemaps', 'shaperad1', 'value', 0);
handles = uiset(handles, 'consolidatemaps', 'shaperad2', 'value', 1);
guidata(hObject, handles);


%%
function find_bad_cells_callback(hObject, handles)
handles = find_bad_cells(handles);
guidata(hObject, handles);


%%
function adjust_contours_callback(hObject, handles)
handles = save_detectcell_widget_values(handles);
handles = adjust_contours_towards_pi(handles);
handles = draw_cell_contours(handles);
guidata(hObject, handles);


%%
function delete_high_pi_contours_callback(hObject, handles);
handles=delete_high_pi_contours(handles);
guidata(hObject,handles);

%%
function manual_contour_add_callback(hObject, handles)
handles = save_detectcell_widget_values(handles);
handles = manual_contour_add(handles);
guidata(hObject, handles);


%%
function manual_contour_delete_callback(hObject, handles)
handles = manual_contour_delete(handles);
guidata(hObject, handles);


%%
function reset_detect_screen_callback(hObject, handles)
%turn off ginput
%interrupt all functions
handles = uiset(handles,'detectcells','all','enable','on');
error('reset')

%%
% detect_cells_next_callback
function detect_cells_next_callback(hObject, handles)
% Before we move on the the halos we ask the user if they would like
% to load any masks such as a sulfarhodamine or GFP labelled
% interneurons, etc.

button_name = 'Yes';

button_name=questdlg('Would you like to load a mask, such as a sulfarhodamine or GFP labelled interneuron mask?', ...
		     'Load mask', ...
		     'Yes','No', 'Yes');
%turn off contour number changers after contours have been finalized
handles = menuset(handles, 'Contours','contours','Randomize contour order','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep only brightest contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep random contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep last contours','Enable','off');
handles = menuset(handles, 'Contours','contours','Keep last contours & randomize order','Enable','off');
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file', 'Enable', 'on');  
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than once)', 'Enable', 'on'); 
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than one pulse per target)', 'Enable', 'on');

switch button_name
   case 'Yes'
      prompt={'Enter the name for the new mask:'};
      nummasks=size(handles.exp.tcImage,2);
      %%%
      def = {['new',num2str(nummasks)]};
      dlgTitle='Mask title';
      lineNo=1;
      answer=inputdlg(prompt,dlgTitle,lineNo,def);
      if isempty(answer)
          errordlg('You must enter a valid name');
          return;
      end
      handles = set_new_mask_idx(handles, answer{1});
      handles.exp.numMasks = handles.exp.numMasks + 1;
      handles.appData.currentMaskIdx = get_mask_idx(handles,answer{1});
      % Another hack.  Have to increase the size of the handle cell array.
      nregions = handles.exp.numRegions;
      for r = 1:nregions
          handles.exp.regions.contours{r}{end+1} = [];
          handles.guiOptions.face.handl{r}{end+1} = [];
      end
      guidata(hObject, handles);
      % This widget is used to determine the detectcells uigroup.
      % Could be done better. -DCS:2005/04/04
      handles = uiset(handles, 'filterimage', 'det_view', 'enable', 'off');
      handles = hide_uigroup(handles, 'detectcells');
      handles = show_uigroup(handles, 'filterimagebadpixels');
      handles = delete_contour_handles(handles, 'ridx', 'all', 'midx', handles.appData.currentMaskIdx-1);
      open_image_callback(hObject, handles);
    case 'No'
      handles = delete_contour_handles(handles, 'ridx', 'all', 'midx', handles.appData.currentMaskIdx);
      drawnow;
      handles = setup_consolidate_maps(handles);
      guidata(hObject, handles);
    otherwise%ie if question box is closed and not answered
        return
end



%%
% setup_consolidate_maps
function handles = setup_consolidate_maps(handles)

handles.exp.numMasks = length(handles.exp.tcImage);
nmaps = handles.exp.numMasks;
nregions = handles.exp.numRegions;

%set up a system to keep track of which movie contour each other contour overlaps with
%always within the same region
handles.exp.contourMaskIdx={};
for ridx = 1:nregions;
    numcontours=length(handles.exp.regions.contours{ridx}{1});
    handles.exp.contourMaskIdx{ridx}=ones(1,numcontours);%default for which mask the 
%         movie contours overlapped with
    for midx = 1:nmaps;
        numcontours = length(handles.exp.regions.contours{ridx}{midx});
        handles.exp.overlapsInfo{ridx}{midx} = zeros(numcontours, 2);
    end
end

if (nmaps == 1)
    handles = setup_halos(handles);
    return;
end

% Show / hide the right GUI widget groups.
lidx = get_label_idx(handles, 'consolidatemaps');
handles = hide_uigroup(handles, 'detectcells');
handles = hide_uigroup(handles, 'filterimage');
handles = hide_uigroup(handles, 'regions');
handles = show_uigroup(handles, 'consolidatemaps');

% Draw the multiple region widgets on the right.
button_down_fnc = 'caltracer(''consolidate_buttondown_callback'',gcbo,guidata(gcbo))'; 
mapcl = hsv(nmaps);
for i = 1:nmaps   
    handles.uigroup{lidx}.mapax(i) = ...
	axes('position',[0.87 0.60-(i-1)*0.15 0.11 0.10]);
    draw_region_widget(handles, ...
		       'axes', handles.uigroup{lidx}.mapax(i), ...
		       'midx', i, ...
		       'dotitle', 1, ...
		       'mapcolor', mapcl(i,:),...
		       'buttondownfnc', button_down_fnc);
    
end

% Draw an average of all the zstacks in the main image axis. Could use
% display_zstack_image to do this, with proper
% modifications. -DCS:2005/04/05
I = zeros(handles.exp.tcImage(1).nY, handles.exp.tcImage(1).nX);
I3 = zeros(handles.exp.tcImage(1).nY, handles.exp.tcImage(1).nX,3);
avg_title = [];
for i = 1:nmaps%get z-scored images
    m = mean2(handles.exp.tcImage(i).filteredImage);
    s = std2(handles.exp.tcImage(i).filteredImage);
%    I = I + handles.exp.tcImage(i).image/m;
    if (i < 4)
        I3(:,:,i) = (handles.exp.tcImage(i).filteredImage-m)/s;
    end
    avg_title = [avg_title ' + ' handles.exp.tcImage(i).title];
end
mostmin = min(min(min(I3)));
for i = 1:nmaps
    I3(:,:,i) = I3(:,:,i) - mostmin;			% min to 0.
end
m2 = mean2(I3(:,:,1:nmaps));
s2 = std2(I3(:,:,1:nmaps));
I3 = I3/(m2 + 2*s2);
for cidx = 1:size(I3,3);%normalize each color plane...
    thisplane = I3(:,:,cidx);
    thisplane =  thisplane - min(thisplane(:));
    I3(:,:,cidx) = thisplane / max(thisplane(:));
end
% I3 = I3 - min(I3(:));
% I3 = I3 / max(I3(:));

lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
set(handles.appData.mainTcImage,'CData',I3);
% hold on;
% set(gca, 'xtick', [], 'ytick', []);
% axis equal;
% axis tight;
% box on;
title(texlabel(avg_title, 'literal'));
% Put the region border in front.
if ~isempty(handles.exp.regions.bhand)
    c = get(handles.uigroup{lidx}.imgax, 'Children');    
    cch = find(strcmpi(get(c, 'Tag'), 'cellcontour'));
    delete(c(cch));
    %%% Delete the handles from the array. -DCS:2005/04/04
    c = get(handles.uigroup{lidx}.imgax, 'Children');
    ctag = get(c, 'Tag');
    rbh_idx = find(strcmpi(ctag, 'regionborder'));
    not_rbh_idx = find(~strcmpi(ctag, 'regionborder')); 
    newc = [c(rbh_idx); c(not_rbh_idx)];
    set(handles.uigroup{lidx}.imgax, 'Children', newc);
end

% Else we enter an optional phase of the GUI where the user decides
% how to consolidate the various contours we've found from the
% different regions of each time collapsed image.

% First draw all the maps on the side, for selection.
mapcolors = hsv(nmaps);
% Draw all the contours for the user to see.
for r = 1:nregions
    handles.appData.currentRegionIdx = r;
    for m = 1:nmaps
	handles.appData.currentMaskIdx = m;
	handles = draw_cell_contours(handles, ...
				     'ridx', r, ...
				     'midx', m, ...
				     'color', mapcolors(m,:), ...
				     'savehandles', 1);
    end
end
handles.exp.masks.cl = mapcolors;


%%
function find_overlap_callback(hObject, handles)
handles = find_overlap(handles);
guidata(hObject, handles);


%%
function adjust_overlap_callback(hObject, handles)
handles = adjust_overlap(handles);
colors = handles.exp.masks.cl;
m=1;
for r = 1:handles.exp.numRegions
%     for m = 1:handles.exp.numMasks
        handles = draw_cell_contours(handles, 'ridx', r, 'midx', m, ...
            'color', colors(m,:));
%     end
end
guidata(hObject, handles);



%%
% consolidate_buttondown_callback
function consolidate_buttondown_callback(hObject, handles)
user_data = get(hObject, 'UserData')
ridx = user_data(1);
midx = user_data(2);
handles.appData.currentRegionIdx = ridx;
handles.appData.currentMaskIdx = midx;
handles = hide_region_contours(handles);
%ridx = handles.appData.currentRegionIdx;
% Get the new region index.
names = handles.exp.regions.name;
%handles.appData.currentRegionIdx = mod(ridx+length(names)-2,length(names))+1;

handles = sync_detectcell_buttons(handles);
guidata(hObject, handles);





%%
% setup_halos_callback
function setup_halos_callback(hObject, handles)
handles = setup_halos(handles);
guidata(hObject, handles);
if handles.appData.skipThroughSettings.skipHaloWindow.index > 0;
    caltracer('setup_signals_callback',hObject, handles)
end

%%
% setup_halos
function handles = setup_halos(handles)
% Copy the GUI parameters into the experiment now that we are done.
handles.exp.regions.cutoff = handles.guiOptions.face.thresh;
minArea = handles.guiOptions.face.minArea;
handles.exp.regions.minArea = minArea;
maxArea = handles.guiOptions.face.maxArea;
handles.exp.regions.minArea = minArea;
handles.exp.regions.maxArea = maxArea;
handles.exp.regions.isDetected = handles.guiOptions.face.isDetected;
handles.exp.regions.piLimit = handles.guiOptions.face.piLimit;
handles.exp.regions.isAdjusted = handles.guiOptions.face.isAdjusted;
cn = handles.exp.regions.contours;
%centr = handles.exp.regions.centroids;
nregions = handles.exp.numRegions;
nmaps = handles.exp.numMasks;
contours = {};
centroids = {};
areas = {};
cridx = [];
cmidx = [];
% Once this button is hit, we recompute everything from the contour
% because the previous actions (adjusting pi / adding deleting
% cells all only modify the contours.  So every other structure
% might be out of sync.
for r = 1:nregions
    cmidx = [cmidx handles.exp.contourMaskIdx{r}];
    for m = 1:nmaps			% -DCS:2005/08/04
        for c = 1:length(cn{r}{m})
            %centroids{end+1} = centr{c}(d,:);BW
            areas{end+1} = polyarea(cn{r}{m}{c}(:,1), cn{r}{m}{c}(:,2));
            cridx = [cridx r];
            if m==1;%only for first region -BW
                contours{length(contours)+1} = cn{r}{m}{c};%keep each contour from each region
                centroids{end+1} = create_centroid(cn{r}{m}{c});
            end
        end
    end
end
handles.exp.centroids = centroids;	% not indexed by region anymore.
handles.exp.contourLines = contours;	% not indexed by region anymore.
handles.exp.areas = areas;
handles.exp.contourRegionIdx = cridx;	% an index into regions.
handles.exp.contourMaskIdx = cmidx;	% an index into tcImage... now a vector
% Now we are done with many uigroups, so hide them.
handles = hide_uigroup(handles, 'regions');
handles = hide_uigroup(handles, 'filterimage');
handles = hide_uigroup(handles, 'detectcells');
handles = hide_uigroup(handles, 'consolidatemaps');
handles = show_uigroup(handles, 'halos');
% This is a bit of a hack because one cannot turn 'visible' to
% 'off' for an axes.
lidx = get_label_idx(handles, 'regions');
hide_axis(handles.uigroup{lidx}.regax);

% Redraw the contours because the colors might not be in region
% mode, which is what we want.
handles = draw_movie_cell_contours(handles);


%%% Initialize some new varaibles.  Should any of this be appData
%or guiOptions or exp?
handles.appData.haloHands = [];
handles.appData.haloBorderHands = [];
handles.appData.halos = {};
handles.appData.haloBorders = {};
% handles.appData.haloMode = 1;
% handles.appData.haloArea = 2;

[st, tracereader_names] = readdir(handles, 'tracereaders');
handles.appData.traceReaderNames = tracereader_names;
handles = uiset(handles, 'halos', 'dpreaders', 'String', st);
handles = uiset(handles, 'halos', 'inpthaloar', ...
		'String', num2str(handles.appData.haloArea));



%%
% halo_check
function halo_check_callback(hObject, handles)
if (uiget(handles, 'halos', 'halo_check', 'value') == 0)
    if (~isempty(handles.appData.haloHands))
        delete(handles.appData.haloHands);
    end
    if (~isempty(handles.appData.haloBorderHands))
        delete(handles.appData.haloBorderHands);
    end
    handles.appData.haloHands = [];
    handles.appData.haloBorderHands = [];
    handles.appData.halos = {};
    handles.appData.haloMode = 0;
    handles = uiset(handles, 'halos', 'inpthaloar', 'enable','off');
    handles = uiset(handles, 'halos', 'btupdate', 'enable','off');
else
    handles.appData.haloMode = 1;
    handles = uiset(handles, 'halos', 'btupdate','enable','on');
    handles = uiset(handles, 'halos', 'inpthaloar','enable','on');
end
%zoom on;
guidata(hObject, handles);



%%
% halo_update_callback
function halo_update_callback(hObject, handles)
if isfield(handles.appData,'haloHands')
    if (~isempty(handles.appData.haloHands))
        delete(handles.appData.haloHands);
        delete(handles.appData.haloBorderHands);
    end
end
regions = handles.exp.regions;
nregions = handles.exp.numRegions;
midx = handles.appData.currentMaskIdx;
nx = handles.exp.tcImage(midx).nX;
ny = handles.exp.tcImage(midx).nY;
handles.appData.haloHands = [];
handles.appData.halos = cell(1,length(handles.exp.contourLines));
regions.haloArea = str2num(uiget(handles, 'halos','inpthaloar','string'));
cridx = handles.exp.contourRegionIdx;
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
for c = 1:length(handles.exp.contourLines)
    cent = create_centroid(handles.exp.contourLines{c});
    ct = repmat(cent,size(handles.exp.contourLines{c},1),1);
    % Halo contour is created 2*area is out, but because of the halo
    % border the halo is still haloArea in area.
    halos{c} = (handles.exp.contourLines{c}-ct)*sqrt((1+2*regions.haloArea))+ct;
    halo_borders{c} = (handles.exp.contourLines{c}-ct)*sqrt((1+1*regions.haloArea))+ct;
    halos{c}(find(halos{c}(:,1) < 1),1) = 1;
    halos{c}(find(halos{c}(:,2) < 1),2) = 1;
    halos{c}(find(halos{c}(:,1) > nx),1) = nx;
    halos{c}(find(halos{c}(:,2) > ny),2) = ny;
    halo_borders{c}(find(halo_borders{c}(:,1) < 1),1) = 1;
    halo_borders{c}(find(halo_borders{c}(:,2) < 1),2) = 1;
    halo_borders{c}(find(halo_borders{c}(:,1) > nx),1) = nx;
    halo_borders{c}(find(halo_borders{c}(:,2) > ny),2) = ny;

    
    color = regions.cl(cridx(c),:);  
    halo_hands(c) = plot(halos{c}([1:end 1],1), halos{c}([1:end 1],2),...
			 'Color', color,...
			 'LineWidth', 1,...
			 'LineStyle', ':');
    border_hands(c) = plot(halo_borders{c}([1:end 1],1), halo_borders{c}([1:end 1],2),...
			   'Color', color,...
			   'LineWidth', 1,...
			   'LineStyle', '--');
end
%zoom on;
handles.appData.haloHands = halo_hands;
handles.appData.halos = halos;
handles.appData.haloBorderHands = border_hands;
handles.appData.haloBorders = halo_borders;
guidata(hObject, handles);



%%
function handles = create_experiment_from_app(handles)
% Setup the experiment structure by reading traces and filling out
% the structure, etc.
set(handles.fig, ...
    'Name', [handles.appData.title ' - ' handles.exp.tcImage(1).title]);

midx = get_mask_idx(handles, 'tcImage');

% Get the correct colormap for the time collapsed image.
brightness = uiget(handles, 'image', 'bbright', 'value');
contrast = uiget(handles, 'image', 'bcontrast', 'value');
%climg = compute_contrast(brightness, contrast);
%handles.exp.tcImage(midx).colorMap = climg;

% Now that we are done setting up the halos, we can copy the latest
% halos to the experiment.
handles.exp.haloMode = handles.appData.haloMode;
% Add them here and then remove them after the tracereader call.  Data
% is saved in the contour array.
handles.exp.halos = handles.appData.halos;
handles.exp.haloBorders = handles.appData.haloBorders;

% Read the traces.
rid = uiget(handles, 'halos', 'dpreaders', 'value');
reader_name = handles.appData.traceReaderNames(rid);
reader_name = reader_name{1};

if handles.appData.skipThroughSettings.flipSignalQuestion.index > 0;
    button = handles.appData.skipThroughSettings.flipSignalQuestion.options;
else
    qstring = ['Some dyes produce a downward signal.  The rest of the program works on the assumption that a signal is a higher value than baseline.  Would you like to flip the traces about their means?'];
    button = questdlg(qstring, 'Signal Direction.', ...
              'Yes', 'No', 'Cancel', 'No');
end
if (strcmpi(button, 'Yes'))
    handles.appData.multiplySignalsbyNegOne = 1;
elseif (strcmpi(button, 'No'))
    handles.appData.multiplySignalsbyNegOne = 0;
else
    return;
end

[traces, halo_traces, param] = feval(reader_name, handles.exp, midx);
warning off
if (handles.appData.multiplySignalsbyNegOne)
    [ncontours, len] = size(traces);
    trace_means = mean(traces,2);
    trace_means_mat = repmat(trace_means, 1, len);
    traces = traces * -1 + 2*trace_means_mat;
    if ~isempty(halo_traces)
        halo_trace_means = mean(halo_traces,2);
        halo_trace_means_mat = repmat(halo_trace_means, 1, len);    
        halo_traces = halo_traces * -1 + 2*halo_trace_means_mat;
    end
end
handles.exp = rmfield(handles.exp, 'halos');
handles.exp = rmfield(handles.exp, 'haloBorders');

handles.exp.traces = traces;
handles.exp.haloTraces = halo_traces;
handles.exp.traceReaderName = reader_name;
handles.exp.traceReaderParams = param;

ncontours = length(handles.exp.contourLines);
halos = handles.appData.halos;
halo_borders = handles.appData.haloBorders;
if (~handles.appData.haloMode)
    halos = cell(1,ncontours);
    halo_borders = cell(1,ncontours);
end
contours = handles.exp.contourLines;
centroids = handles.exp.centroids;
cridx = handles.exp.contourRegionIdx;
cmidx = handles.exp.contourMaskIdx;
areas = handles.exp.areas;

% Integration with David Sussillo's movie_analysis.
handles.exp.numContours = size(traces, 1);
%handles.exp.currentContourOrder = [1:handles.exp.numContours];
% Do the simple order of the contours reflect the ordering set earlier
% in the program?
coidx = 1;
new_order = neworder;
new_order.id = 1;
new_order.title = 'cell_number_id1'; % default name.
new_order.orderName = 'default';
new_order.order = [1:handles.exp.numContours];
new_order.index = [1:handles.exp.numContours];
handles.exp.contourOrder(coidx) = new_order;
handles.appData.currentContourOrderIdx = 1;
handles.exp.numContourOrders = 1;

enduseless = round(.1*handles.exp.numContours);
colors = hsv(round(1.7*handles.exp.numContours));
stopcolors = size(colors,1)-enduseless;
startcolors = stopcolors - (handles.exp.numContours-1);
handles.exp.contourColors = colors(startcolors:stopcolors,:);
% colors = spring(handles.exp.numContours);
for i = 1:handles.exp.numContours
    handles.exp.contours(i).id = i;
    handles.exp.contours(i).regionIdx = cridx(i);
    handles.exp.contours(i).maskIdx = cmidx(i);
    handles.exp.contours(i).intensity = traces(i,:);
    handles.exp.contours(i).contour = contours{i};
    handles.exp.contours(i).Centroid = centroids{i};
    handles.exp.contours(i).area = areas{i};
    handles.exp.contours(i).haloIntensity = halo_traces(i,:);
    handles.exp.contours(i).haloContour = halos{i};
    handles.exp.contours(i).haloBorderContour = halo_borders{i};
end

handles.exp.globals.numImagesProcess = size(traces,2);
handles.exp.globals.name = handles.exp.fileName;
handles.exp.globals.height = handles.exp.tcImage(midx).nY;
handles.exp.globals.width = handles.exp.tcImage(midx).nX;
handles.exp.globals.fs = 1/handles.exp.timeRes;
handles.exp.globals.timeRes = handles.exp.timeRes;
handles.exp.globals.mpp = handles.exp.spaceRes;
handles.exp.globals.spaceRes = handles.exp.spaceRes;
handles.exp.globals.movie_start_idx = 1;
handles.exp.globals.haloMode = handles.appData.haloMode;
handles.exp.globals.haloArea = handles.appData.haloArea;

d = newdetection;
d.title = '1';
d.id = 1;
d.detectorName = 'default';
d.onsets = cell(1, ncontours);
d.offsets = cell(1, ncontours);
handles.exp.detections(1) = d;



%%
function handles = create_clusters_gui(handles, nclusters, varargin)
% Call create clusters AND create the application patches.
ntrials = str2num(uiget(handles, 'signals', 'txntrials', 'string'));
varargin{end+1} = 'numtrials';
varargin{end+1} = ntrials;
handles = createclusters(handles, ...
                         nclusters, ...
                         varargin{:});
%[starts, stops] = process_options(varargin, 'start', 1, 'stop', 2);
pidx = handles.appData.currentPartitionIdx;
partition_names = cellstr(uiget(handles, 'signals', 'clusterpopup', 'String'));
npartitions = length(partition_names)+1;
partition_names{end+1} = handles.exp.partitions(pidx).title;
uiset(handles, 'signals', 'clusterpopup', 'String', partition_names);
uiset(handles, 'signals', 'clusterpopup', 'Value', npartitions);


axes(handles.guiOptions.face.imagePlotH);
%handles = plot_intensity_image(handles);
handles = plot_gui(handles);
%handles = setup_cluster_patches(handles);


%%
% setup_signals_callback
function setup_signals_callback(hObject, handles)
if (isempty(handles.appData.halos) & handles.appData.haloMode)
    halo_update_callback(hObject, handles);
    handles=guidata(hObject);
end

handles = setup_signals(handles);
guidata(hObject, handles);


%%
% setup_signals
function handles = setup_signals(handles)
init_spectral;				% dumb library.
midx = get_mask_idx(handles, 'tcImage');
% Handle the GUI options that are OK first.
% Allow the user to save at this point.  Activate lots of other menu
% options
handles = menuset(handles, 'File', 'file', 'Save Experiment', 'Enable', 'on');
handles = menuset(handles, 'File', 'file', 'Open Experiment', 'Enable', 'off');
handles = menuset(handles, 'Contours','contours','Tile Region','Enable','off');
handles = menuset(handles, 'Contours','contours','Tile Region with rectangles','Enable','off');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Turn active contours off' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Connect highlighted contours in order', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Plot highlighted contours', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Highlight contours by order', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Highlight contours by order (in partition)', ...
		  'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...		   
		   'Highlight contours by cluster id', ...
		   'Enable', 'on');

handles = menuset(handles, 'Contours', 'contours', ...
      'Convert contours to parallel image' ,...
      'Enable', 'on');
handles = menuset(handles, 'Contours', 'contours', ...
		  'Make all contours active' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display centroids on selected (pixels)' ,...
		  'Enable', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display ids on selected contours' ,...
		  'Enable', 'on', ...
		  'Checked', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Display ids on all contours' ,...
		  'Enable', 'on', ...
		  'Checked', 'off');
      
% Enable export menu functions
handles = menuset(handles,'Export','export',...
            'Active cells to vnt file' ,...
            'Enable','on');
handles = menuset(handles,'Export','export',...
            'Export traces' ,...
            'Enable','on');
handles = menuset(handles,'Export','export',...
            'Export active cell traces' ,...
            'Enable','on');
        
% Enable the clustering functions.
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Highlight all clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Unhighlight all clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Merge highlighted clusters', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by id', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by size', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete contours by order', 'Enable', 'on');
handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Order clusters by intensity peak', 'Enable', 'on');

          
% Preprocessing.
handles = menuset(handles, 'Preprocessing', 'preprocessing', ...
		  'Preprocessing Options', 'Enable', 'on');



handles = menuset(handles, 'Clustering', 'clustering', ...
		  'Delete clusters by size', 'Enable', 'on');

% Preferences
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Long Raster', 'Enable', 'on');
% handles = menuset(handles, 'Preferences', 'preferences', ...
% 		  'Use contour slider', 'Enable', 'on');
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show ordering line', 'Enable', 'on');

% Enable the user defined signal functions.
[st, function_names] = readdir(handles, 'signalfunctions');
for i = 1:length(st)
    handles = menuset(handles, 'Functions', 'functions', ...
		      st{i}, 'Enable', 'on');
end


% The only version of this works for finding contours but not the
% later map.
handles = menuset(handles, 'Preferences', 'preferences', ...
		  'Show contour ordering', 'Enable', 'off');

% Setup the intensity map for clustering.
% Setup the cluster image axis.
% Load the clustering algorithms must be above create_clusters_gui.
[cluster_methods, cluster_method_names] = readdir(handles, 'classifiers');
uiset(handles, 'signals', 'dpclassifiers', 'String', cluster_methods);

if (~handles.appData.didSetupExperiment)
    handles = create_experiment_from_app(handles);
    handles = setup_clickmap_image(handles);
    handles = setup_traceplot(handles);
    handles = setup_rasterplot(handles);
    % Put the axes creation after create call so that it doen't show
    % up on the screen in annoying fashion.  this means we have to
    % wait to do first create-clusters until it's created, which is
    % why it's right below, and not in create_experiment.

    handles = create_clusters_gui(handles, 1 , ...
				  'onecluster', 1);
    handles.appData.didSetupExperiment = 1;
    handles = hide_uigroup(handles, 'image');
    handles = hide_uigroup(handles, 'halos');
else					% loaded experiment.
    handles = setup_traceplot(handles);
    handles = setup_clickmap_image(handles);   
    handles = setup_rasterplot(handles);

    % Bug with this function so only use in this case.
    handles = hide_all_uigroups(handles);
end

if (handles.exp.haloMode == 0)
    handles = uiset(handles, 'signals', 'halo_raw_check' ,'enable','off');
    handles = uiset(handles, 'signals', 'halo_preprocess_check' ,'enable','off');
end

% Turn off the contour finding images.
lidx = get_label_idx(handles, 'image');
hide_axis(handles.uigroup{lidx}.imgax);

% Turn on the GUI widgets for analyzing the signals.
handles = show_uigroup(handles, 'signals');

ncontours = length(handles.exp.contours);


% Load the dimension reduction methods.
[dimredux_methods, dimredux_method_names] = readdir(handles, 'dimreducers');
uiset(handles, 'signals', 'dpdimreducers', 'String', dimredux_methods);


% Set the partition names.  
npartitions = length(handles.exp.partitions);
for p = 1:npartitions
    partition_names{p} = (handles.exp.partitions(p).title);
end
uiset(handles, 'signals', 'clusterpopup', 'String', ...
      partition_names);
partition_order_value = handles.appData.currentPartitionIdx;
uiset(handles, 'signals', 'clusterpopup', 'Value', partition_order_value);


% Load the Contour Order routines.
[st, orderroutine_names] = readdir(handles, 'orderroutines');
handles.appData.contourOrderRoutines = orderroutine_names;
handles = uiset(handles, 'signals', 'dporderroutines', 'String', st);

% Set the contour orders.  The default is the first partition.
norders = length(handles.exp.contourOrder);
for c = 1:norders
   contour_order_names{c} = (handles.exp.contourOrder(c).title); 
end
uiset(handles, 'signals', 'contourorderpopup', 'String', contour_order_names);
contour_order_value = handles.appData.currentContourOrderIdx;
uiset(handles, 'signals', 'contourorderpopup', 'Value', contour_order_value);


% Load the signal detectors.
[st, signaldetector_names] = readdir(handles, 'signaldetectors');
handles.appData.signalDetectorNames = signaldetector_names;
handles = uiset(handles, 'signals', 'dpdetectors', 'String', st);

% Load the saved signal detections.
ndetections = length(handles.exp.detections);
for c = 1:ndetections
   detection_names{c} = (handles.exp.detections(c).title); 
end
uiset(handles, 'signals', 'signalspopup', 'String', detection_names);
detection_order_value = handles.appData.currentDetectionIdx;
uiset(handles, 'signals', 'signalspopup', 'Value', detection_order_value);

% Contour slider.
% The contour slider is off by default.
handles = uiset(handles, 'signals', 'numslider', ...
		'Min', 1, ...
		'Max', ncontours, ...
		'Sliderstep', [1/ncontours 10/ncontours]);

uiset(handles, 'signals', 'numslider', 'Visible', 'off');
handles.appData.useContourSlider = 0;

handles = plot_gui(handles);  %GA tracking

try
    handles = ct_setup_signalsPreferences(handles);%allow user to set some widget 
    %     and other preferences for the upcoming signals screen
end


%%
% contour_buttondown_callback
function contour_buttondown_callback(hObject, handles)
cid = get(hObject, 'UserData');
active_color = handles.appData.activeContourColor;
face_color = get(hObject, 'FaceColor');
if (handles.appData.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end
% Not selected, cluster not selected. (Could use UserData here.).

% Since the active cell and current cell GUI concepts conflict
% (i.e. the user gets confused.  It's either one or the other.
if (~do_use_current_cell)
    if (ischar(face_color) & strcmpi(face_color, 'none'))
        handles.appData.activeCells = [handles.appData.activeCells cid];
    elseif (length(find(face_color == active_color)) < 3)
        handles.appData.activeCells = [handles.appData.activeCells cid];
    else					% it was active, get rid of it.
        handles.appData.activeCells = ...
            setdiff(handles.appData.activeCells, cid);
    end
else
    % Make sure contour selected is in current partition, else ignore.
    pidx = handles.appData.currentPartitionIdx;
    p = handles.exp.partitions(pidx);
    contour_ids = [p.clusters.contours];    
    ncontours = length(contour_ids);
    nonnan_contour_idxs = find(~isnan([p.clusterIdxsByContour{1:end}]) == 1);
    contour_idx = find(nonnan_contour_idxs == cid);    
    % Only update the id from here when things are no good.
    if (isempty(contour_idx) | contour_idx < 1 | contour_idx > ncontours)
	warndlg(['In contour slider mode, you can only select contours' ...
		 ' that are in the current partition.  Deselect' ...
		 ' Preferences->Use Contour Slider to select this contour.']);
	return;
    end
    handles.appData.currentCellId = cid;
end

handles = plot_gui(handles);
guidata(hObject, handles);



%%
function handles = toggle_other_show_checkboxes(hObject,handles, tag)
if (get(hObject,'Value') == get(hObject,'Max'))
    do_uncheck_others = 1;
else
    do_uncheck_others = 0;
end
hs = findobj(handles.fig, 'Tag', tag);

for i = 1:length(hs)
    h = hs(i);
    if (~(get(h, 'UserData') == get(hObject, 'UserData')))
	if (do_uncheck_others)
	    set(h, 'Value', get(h, 'Min'));
	end
    end
end



%%
% clean_trace_callback
function clean_trace_check_callback(hObject, handles)
% This halo check is for read traces.
handles = toggle_other_show_checkboxes(hObject, handles, handles.appData.showCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);


%%
% trace_check_callback
function trace_check_callback(hObject, handles)
% This halo check is for read traces.
handles = toggle_other_show_checkboxes(hObject, handles, handles.appData.showCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);


%%
% halo_raw_callback
function halo_raw_callback(hObject, handles)
% This halo check is for read traces.
handles = toggle_other_show_checkboxes(hObject, handles, handles.appData.showHaloCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);


% halo_preprocess_callback
function halo_preprocess_callback(hObject, handles)
% This halo check is for read traces.
handles = toggle_other_show_checkboxes(hObject, handles, handles.appData.showHaloCheckBoxTag);
handles = plot_gui(handles);
guidata(hObject, handles);


% No longer used due to preprocessor. -DCS:2005/05/31
%%
% df_check_callback
%function df_check_callback(hObject, handles)
%handles = toggle_other_show_checkboxes(hObject, handles);
%handles = plot_gui(handles);
%guidata(hObject, handles);


%%
% numslider_callback
function numslider_callback(hObject, handles)
% This can handle contours that have been deleted/killed.
nonnan_order = round(uiget(handles, 'signals', 'numslider', 'Value'));

% Find all the contours in the current partition.
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
nonnan_contour_ids = find(~isnan([p.clusterIdxsByContour{1:end}]) == 1);

% Look up the id for the order taken from the numslider.
coidx = handles.appData.currentContourOrderIdx;
nonnan_contour_order = ...
    handles.exp.contourOrder(coidx).index(nonnan_contour_ids);

nn = [nonnan_contour_order; nonnan_contour_ids]';
sorted_nn = sortrows(nn,1);
contour_id = sorted_nn(nonnan_order,2);


if (isempty(contour_id))
    errordlg('Something wrong in numslider_callback.');
end

% Store the updated id.
handles.appData.currentCellId = contour_id;

% Replot the GUI and save.
handles = plot_gui(handles);
guidata(hObject, handles);



%%
% cluster_callback
function cluster_callback(hObject, handles)
nclusters = str2num(uiget(handles, 'signals', 'txnclusters', 'String'));
handles = create_clusters_gui(handles, nclusters);
handles = plot_gui(handles);
guidata(hObject, handles);

%%
% clusterpopup_callback
function clusterpopup_callback(hObject, handles)
%function clusterpopup_callback(hObject, handles)
% Set the signals GUI to the correct clustering.
partition_names = uiget(handles, 'signals', 'clusterpopup', 'String');
pnidx = uiget(handles, 'signals', 'clusterpopup', 'Value');
pname = partition_names{pnidx};
% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(pname, 'id[0-9]+');
if isempty(match)
   errordlg(['Error in clusterpopup_callback with name: ' pname]); 
   return;
end
pidx = str2num(pname(start+2:fin));
handles.appData.currentPartitionIdx = pidx;
handles.appData.currentContourOrderIdx = ...
    handles.exp.partitions(pidx).contourOrderId;

handles = plot_gui(handles);
guidata(hObject, handles);


%% 
% order_contours_callback
function order_contours_callback(hObject, handles)
% Should have both here in the future.
%lidx = get_label_idx(handles, 'signals');
%%% Hack on lack of wizard order.
%if (strcmpi(uiget(handles, 'signals', 'btcluster','Visible'),'off'))
%    handles = reorder_contours_early(handles);
%else
%    handles = reorder_contours(handles);
%end

old_num_contour_orders = handles.exp.numContourOrders;
handles = ordercontours(handles);

if (old_num_contour_orders >= handles.exp.numContourOrders)
    return;
end

% Now fill the popup with the saved contour orders.
contour_order_names = uiget(handles, 'signals', 'contourorderpopup', 'String');
%coidx = uiget(handles, 'signals', 'contourorderpopup', 'Value');

coidx = handles.appData.currentContourOrderIdx;
new_coname = handles.exp.contourOrder(coidx).title;
contour_order_names{end+1} = new_coname;
val = length(contour_order_names);
handles = uiset(handles, 'signals', 'contourorderpopup', ...
		'String', contour_order_names);
handles = uiset(handles, 'signals', 'contourorderpopup', ...
		'Value', val);

handles = plot_gui(handles);
guidata(hObject, handles);


%%
% contour_order_popup_callback
function contour_order_popup_callback(hObject, handles)
contour_order_names = uiget(handles, 'signals', 'contourorderpopup', 'String');
coidx_popup = uiget(handles, 'signals', 'contourorderpopup', 'Value');
coname = contour_order_names{coidx_popup};

% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(coname, 'id[0-9]+');
if isempty(match)
    coidx = str2num(coname);		% simple name for early stuff.
else
    coidx = str2num(coname(start+2:fin));
end

handles.appData.currentContourOrderIdx = coidx;
handles = plot_gui(handles);
guidata(hObject, handles);



%%
function convert_contours_to_parallel_image_callback(hObject, handles)
convert_contours_to_parallel_image(handles)


%%
function make_all_contours_active_callback(hObject, handles)
handles.appData.activeCells = [1:handles.exp.numContours];
handles = plot_gui(handles);
guidata(hObject, handles);



%%
% turn_active_contours_off_callback
function turn_active_contours_off_callback(hObject, handles)
% Sometimes it's a pain to turn off all the active contours by
% clicking on them individually, so this function will turn them all
% off without the user having to hunt through the clickmap.
handles.appData.activeCells = [];
handles = plot_gui(handles);
guidata(hObject, handles);



%%
% function connect_highlighted_contours_in_order_callback(hObject, handles)
function connect_highlighted_contours_in_order_callback(hObject, handles)
val = get(hObject, 'Checked');
if (strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');
else
    set(hObject, 'Checked', 'off');
end
handles = plot_gui(handles);
guidata(hObject, handles);



%%
% display_centroids_on_selection_callback
function display_centroids_on_selection_callback(hObject, handles)
% Can show centroid value when a cell is selected if this value is on.  
% Selecting this will toggle this value on/off and then redraw.

% Could use in future. -DCS:2005/08/15
% val = get(hObject, 'Checked');    
if handles.appData.centroidDisplay.on == 1;
    set(hObject, 'Checked', 'off');    
    handles.appData.centroidDisplay.on = 0;
elseif handles.appData.centroidDisplay.on == 0;
    set(hObject, 'Checked', 'on');    
    handles.appData.centroidDisplay.on = 1;
end
handles = plot_gui(handles);
guidata(hObject, handles);


%%
% display_ids_on_selected_contours_callback
function display_ids_on_selected_contours_callback(hObject, handles)
% Can show the cluster on id on the centroid is the contour is selected.
val = get(hObject, 'Checked');    
if (strcmp(val, 'on'))
    set(hObject, 'Checked', 'off');    
else
    set(hObject, 'Checked', 'on');    
end
handles = plot_gui(handles);
guidata(hObject, handles);


% display_ids_on_all_contours_callback
function display_ids_on_all_contours_callback(hObject, handles)
% Can show the cluster on id on the centroid is the contour is selected.
val = get(hObject, 'Checked');    
if (strcmp(val, 'on'))
    set(hObject, 'Checked', 'off');    
else
    set(hObject, 'Checked', 'on');    
end
handles = plot_gui(handles);
guidata(hObject, handles);




% signal_functions_callback
function signal_functions_callback(hObject, handles)
fname = get(hObject, 'UserData');
handles = feval(fname, handles);
% There is a question of how to handle the graphics handles that might
% be changed as a result of these calls.  I'm not sure what to do here
% but I'm inclined to save only the experiment part of handles and
% show any graphics changes, but not save them.  -DCS:2005/08/02
guidata(hObject, handles);


%%
function save_experiment_callback(hObject, handles)
midx = get_mask_idx(handles, 'tcImage');
filename = [handles.exp.tcImage(midx).title(1:end-4) '_exp.mat'];
[filename, pathname] = uiputfile(filename, 'Save experiment as');
fnm = [pathname filename];
if (~ischar(fnm))
    return;
end
E = handles.exp;
A = handles.appData;
save (fnm, 'E', 'A');
handles.appData.didSaveExperiment = 1;
guidata(handles.fig, handles);

function new_ct_callback(hObject, handles)
caltracer

%%
function load_contours_callback(hObject, handles)
[hObject, handles] = load_contours(hObject,handles);
guidata(hObject, handles);


%%
function open_experiment_callback(hObject, handles)
[filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
if (filename == 0)			% returns 0 for some reason.
    return;
end

fnm = [pathname filename];
savestruct = load(fnm);
app_data = ct_add_missing_options(savestruct.A);
[experiment app_data] = ct_add_missing_options_exp(savestruct.E, app_data);
app_data = ct_add_missing_options2(app_data, experiment);
handles.exp = experiment;
handles.appData = app_data;
%handles.appData.didSetupExperiment = 1;
set(handles.fig, 'Name', [handles.appData.title ' - ' filename]);
%guidata(hObject, handles);
handles = setup_signals(handles);
guidata(hObject, handles);



%% Preferences menu.
function long_raster_callback(hObject, handles)
val = get(hObject, 'Checked');
if(strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');    
    set(handles.guiOptions.face.tracePlot, ...
	'position', [0.05 0.05 0.42 0.3]);
    set(handles.guiOptions.face.imagePlotH, ...
	'position', [0.50 0.05 0.35 0.90]);
else
    set(hObject, 'Checked', 'off');
    set(handles.guiOptions.face.tracePlot, ...
	'position', [0.05 0.05 0.79 0.3]);
    set(handles.guiOptions.face.imagePlotH, ...
	'position', [0.50 0.40 0.35 0.55]);
end
guidata(hObject, handles);



% use_contour_slider_callback
function use_contour_slider_callback(hObject, handles)
val = get(hObject, 'value');
% if (strcmp(val, 'off'))
if val == 1
%     set(hObject, 'Checked', 'on');    
%     set(hObject, 'value', 1);    
    uiset(handles, 'signals', 'numslider', 'Visible', 'on');
    handles.appData.useContourSlider = 1;
    if (~isempty(handles.appData.activeCells))
        cid = handles.appData.activeCells(1);
        handles.appData.currentCellId = cid;
    else
        handles.appData.currentCellId = 1;
    end
else
%     set(hObject, 'Checked', 'off');
%     set(hObject, 'value', 0)
    uiset(handles, 'signals', 'numslider', 'Visible', 'off');
    handles.appData.useContourSlider = 0;
    if (~isempty(handles.appData.currentCellId))
	handles.appData.activeCells = ...
	    handles.appData.currentCellId(1); % (1) just to be sure.
    end
end
handles = plot_gui(handles);
guidata(hObject, handles);

%%
% show_ordering_line_callback
function show_ordering_line_callback(hObject, handles)
is_visible = uiget(handles, 'signals', 'clusterpopup', 'Visible');
is_early = strcmpi(is_visible, 'off');
if (is_early)
    lidx = get_label_idx(handles, 'image');
    axes(handles.uigroup{lidx}.imgax);
else    
    ax = handles.guiOptions.face.clickMap;
end
handles = show_ordering_line(handles, ax, 1);
guidata(hObject, handles);

%%
function show_contour_ordering_callback(hObject, handles)
is_visible = uiget(handles, 'signals', 'clusterpopup', 'Visible');
is_early = strcmpi(is_visible, 'off');
if (is_early)
    lidx = get_label_idx(handles, 'image');
    ax = handles.uigroup{lidx}.imgax;
else    
    ax = handles.guiOptions.face.clickMap;
end
handles = show_contour_ordering(handles, ax, 1);
guidata(hObject, handles);



%% Export menu.

% function copy_axis_as_meta_to_clipboard_callback
function copy_axis_as_meta_to_clipboard_callback(hObject, handles)
ax = get_axis_handle(handles);
if (ax == 0)
    errordlg('Error in axis selection.');
    return;
end
m = findobj(handles.fig, 'Type','uicontrol');
f = figure; 
ax_copy = copyobj(ax, f);
set(ax_copy,'position',[.05 .10 .90 .85]);
figure(f);

print('-dmeta', '-r600', f);
delete(f);

% function copy_axis_to_new_figure_callback
function copy_axis_to_new_figure_callback(hObject, handles)
ax = get_axis_handle(handles);
if (ax == 0)
    errordlg('Error in axis selection.');
    return;
end
m = findobj(handles.fig, 'Type','uicontrol');
f = figure; 
ax_copy = copyobj(ax, f);
set(ax_copy,'position',[.05 .10 .90 .85]);
figure(f);

function export_contours_callback(hObject,handles)
% exports to the base workspace a variable called "contours" which is
% a cell containing contours

% if contours exist (and there is at least two... as a test of
% detection having been done);
if (isfield(handles,'exp') ...
    && isfield(handles.exp,'regions') ...
    && isfield(handles.exp.regions,'contours') ...
    && iscell(handles.exp.regions.contours) ...
    && length(handles.exp.regions.contours{1}{1}) > 1)
    
    assignin('base','CONTS',handles.exp.regions.contours{1}{1});
%     close(handles.fig)
    try
        %in case were waiting on this to continue... as in vovan's case
        uiresume
    catch
    end
else
    %if any of the above fail
    errordlg('Cell contours do not yet exist')       
end


function export_contours_to_file_callback(hObject,handles)
% exports to the base workspace a variable called "contours" which is
% a cell containing contours

% if contours exist (and there is at least two... as a test of
% detection having been done);
if (isfield(handles,'exp') ...
    && isfield(handles.exp,'regions') ...
    && isfield(handles.exp.regions,'contours') ...
    && iscell(handles.exp.regions.contours) ...
    && length(handles.exp.regions.contours{1}{1}) > 1)
    
    deffilename = [handles.exp.fileName(1:end-4),'_conts'];
    [FileName,PathName,FilterIndex] = uiputfile('.mat','Contour File Name',deffilename);
    if FileName==0 & PathName==0 & FilterIndex==0
        return
    end
    CONTS = handles.exp.regions.contours{1}{1};
    save([PathName,FileName],'CONTS')
else
    %if any of the above fail
    errordlg('Cell contours do not yet exist')       
end



function export_traces_callback(hObject,handles)
export_traces(handles);

function export_active_cell_traces_callback(hObject,handles)
export_active_cell_traces(handles);

function all_centroids_to_vnt_callback(hObject,handles)
all_centroids_to_vnt(handles);

function all_centroids_to_vnt_repeat_callback(hObject,handles)
all_centroids_to_vnt_repeat(handles);

function all_centroids_to_vnt_pulses_callback(hObject,handles)
all_centroids_to_vnt_pulses(handles);

function active_cells_to_vnt_callback(hObject,handles)
active_cells_to_vnt(handles);



%%
function clustermap_buttondown_callback(hObject, handles)
st = get(handles.fig, 'SelectionType');
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
cmenu = get(hObject, 'UIContextMenu');
% Show context menu.
if strcmpi(st, 'alt')
    old_units = get(handles.fig, 'Units');
    set(handles.fig, 'Units', 'pixels');
    current_mouse_point = get(handles.fig, 'CurrentPoint');
    set(handles.fig, 'Units', old_units);
    set(cmenu, 'Position', current_mouse_point);
    set(cmenu, 'Visible', 'on');
	
    % Else plot cells in cluster.
else
    highlighted_contour_id = determine_highlighted_contour_leftclick(handles);

    if (handles.appData.useContourSlider)
        do_use_current_cell = 1;
    else
        do_use_current_cell = 0;
        current_cell = [];			% checks for empties.
    end

    if isempty(find(handles.appData.activeCells==highlighted_contour_id));%if cell not on before this
        if (~do_use_current_cell)		% many active cells
            handles.appData.activeCells(end+1) = highlighted_contour_id;
            handles.appData.activeCells = unique(handles.appData.activeCells);
        else
            handles.appData.currentCellId = highlighted_contour_id;
        end
    else %if cell was already on
        if (~do_use_current_cell)		% many active cells
            nidx = find(handles.appData.activeCells == highlighted_contour_id);
            handles.appData.activeCells(nidx) = [];
            handles.appData.activeCells = unique(handles.appData.activeCells);
            if (isempty(handles.appData.activeCells))
                handles.appData.activeCells = [];
            end
        else
            if (highlighted_contour_id == handles.appData.currentCellId)
                handles.appData.currentCellId = [];
            end
        end
    end
    handles = plot_gui(handles);
    guidata(handles.fig, handles);
    
    %for leftclick = turn on cluster (not cell)
%     edge_color  = get(hObject, 'edgecolor');
%     user_data = get(hObject, 'UserData');
%     hid = user_data(1);
%     cid = user_data(2);
%     cidx = find([p.clusters.id] == cid);
%     if strcmpi(edge_color, 'none')
%         cluster_color = p.clusters(cidx).color;
%         new_edge_color = cluster_color;
%         handles.exp.partitions(pidx).clusters(cidx).doShow = 1;
%     else
%         new_edge_color = 'none';
%         handles.exp.partitions(pidx).clusters(cidx).doShow = 0;
%     end
%     
%     set(handles.guiOptions.face.clusterPatchH(hid), 'edgecolor', new_edge_color);
%     
%     handles = plot_gui(handles);
%     guidata(handles.fig, handles);
end

%%
function highlight_all_clusters_callback(hObject, handles)
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
for cid = 1:p.numClusters
    cidx = find([p.clusters.id] == cid);    
    cluster_color = p.clusters(cidx).color;
    new_edge_color = cluster_color;
    handles.exp.partitions(pidx).clusters(cidx).doShow = 1;
    set(handles.guiOptions.face.clusterPatchH(cid), 'edgecolor', new_edge_color);
end
handles = plot_gui(handles);
guidata(handles.fig, handles);

%%
% function unhighlight_all_clusters_callback(hObject, handles)
function unhighlight_all_clusters_callback(hObject, handles)
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
for cid = 1:p.numClusters
    cidx = find([p.clusters.id] == cid);  
    if (isempty(cidx))
        continue;
    end
    handles.exp.partitions(pidx).clusters(cidx).doShow = 0;
    set(handles.guiOptions.face.clusterPatchH(cid), 'edgecolor', 'none');
end
handles = plot_gui(handles);
guidata(handles.fig, handles);


%%
% function highlight_cell_callback(hObject, handles)
function highlight_cell_callback(hObject, handles)
highlighted_contour_id = determine_highlighted_contour(hObject, handles);

if (handles.appData.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end
if (~do_use_current_cell)		% many active cells
    handles.appData.activeCells(end+1) = highlighted_contour_id;
    handles.appData.activeCells = unique(handles.appData.activeCells);
else
    handles.appData.currentCellId = highlighted_contour_id;
end
handles = plot_gui(handles);
guidata(hObject, handles);



%%
% function unhighlight_cell_callback(hObject, handles)
function unhighlight_cell_callback(hObject, handles)
highlighted_contour_id = determine_highlighted_contour(hObject, handles);

if (handles.appData.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end
if (~do_use_current_cell)		% many active cells
    nidx = find(handles.appData.activeCells == highlighted_contour_id);
    handles.appData.activeCells(nidx) = [];
    handles.appData.activeCells = unique(handles.appData.activeCells);
    if (isempty(handles.appData.activeCells))
        handles.appData.activeCells = [];
    end
else
    if (highlighted_contour_id == handles.appData.currentCellId)
        handles.appData.currentCellId = [];
    end
end
handles = plot_gui(handles);
guidata(hObject, handles);

%%
function highlight_cluster_callback(hObject, handles)
% highlighted_contour_id = determine_highlighted_contour(hObject, handles);

%first get info from the uimenu object... the original "cluster number" (ie
%3 even if 2nd cluster was killed stays 3)
id = get(get(hObject, 'Parent'), 'UserData');
if (isempty(id))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end

%use that to find the cluster patch
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
cidx = find([p.clusters.id] == id);%ie find which remaining cluster has id = 3

clusterpatchhandle = handles.guiOptions.face.clusterPatchH(cidx);

%change the coloring and drawing settings
edge_color  = get(clusterpatchhandle, 'edgecolor');
cluster_color = p.clusters(cidx).color;
if strcmpi(edge_color, 'none')
    new_edge_color = cluster_color;
    handles.exp.partitions(pidx).clusters(cidx).doShow = 1;
else
    new_edge_color = 'none';
    handles.exp.partitions(pidx).clusters(cidx).doShow = 0;
end
set(clusterpatchhandle, 'edgecolor', new_edge_color);

handles = plot_gui(handles);
guidata(handles.fig, handles);



% %%
% function unhighlight_cluster_callback(hObject, handles)
% %first get info from the uimenu object... the original "cluster number" (ie
% %3 even if 2nd cluster was killed stays 3)
% id = get(get(hObject, 'Parent'), 'UserData');
% if (isempty(id))
%     errordlg('Cluster patches are setup incorrectly.');
%     return;
% end
% 
% %use that to find the cluster patch
% pidx = handles.appData.currentPartitionIdx;
% p = handles.exp.partitions(pidx);
% cidx = find([p.clusters.id] == id);%ie find which remaining cluster has id = 3
% 
% clusterpatchhandle = handles.guiOptions.face.clusterPatchH(cidx);
% %change the coloring and drawing settings
% edge_color  = get(clusterpatchhandle, 'edgecolor');
% cluster_color = p.clusters(cidx).color;
% new_edge_color = 'none';
% handles.exp.partitions(pidx).clusters(cidx).doShow = 0;
% 
% set(clusterpatchhandle, 'edgecolor', new_edge_color);
% 
% handles = plot_gui(handles);
% guidata(handles.fig, handles);


%%
% function kill_cell_callback(hObject, handles)
function kill_cell_callback(hObject, handles)
id = get(get(hObject, 'Parent'), 'UserData');
if (isempty(id))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end
cluster_id = id(1);
highlighted_contour_id = determine_highlighted_contour(hObject, handles);

handles = delete_contours_from_partition(handles, highlighted_contour_id);

handles = plot_gui(handles);
guidata(hObject, handles);


%%
% determine_highlighted_contour
function highlighted_contour_id = determine_highlighted_contour(hObject,handles)
% This hObject is the context menu, so this function only works for
% the context menu items on the intensity plot (that show the
% temporal clusters.)

% Remember!:  Position is [left bottom width height], 
% except for the context menu where it's [width height].

% First figure out the number or contours and the contour ids, in order.
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
num_contours = sum([p.clusters.numContours]);
displayed_contours = handles.appData.partitions(pidx).displayedContours;


% Now do the height computation to figure out which contour the user wants
% to become active.
if strcmp(get(hObject,'type'),'uimenu')
    uictxmenuhand = get(hObject, 'parent');		% get the context menu.
elseif strcmp(get(hObject,'type'),'uicontextmenu')
    uictxmenuhand = hObject;
end
cmenu_pos_wrt_fig = get(uictxmenuhand, 'Position'); % Position of context menu.
fig_pos = get(handles.fig, 'Position');	% in pixels.
% normalized units -> pixel units
set(handles.guiOptions.face.imagePlotH, 'Units', 'Pixels');
imap_pos = get(handles.guiOptions.face.imagePlotH, 'Position');
set(handles.guiOptions.face.imagePlotH, 'Units', 'normalized');
imap_bottom = imap_pos(2);
imap_height = imap_pos(4);
% Now put the cmenu position in terms of the imap axis.
cmenu_height =  cmenu_pos_wrt_fig(2) - imap_bottom;
% How many pixels does each raster get (in terms of height)?
pixels_per_raster = imap_height / num_contours;



% Contour_height is the order of the contour we are interested in.
contour_height = num_contours - ceil(cmenu_height/pixels_per_raster)+1;
%highlighted_contour_id = contour_ids(index(contour_order));
highlighted_contour_id = displayed_contours(contour_height);




%%
% determine_highlighted_contour
function highlighted_contour_id = determine_highlighted_contour_leftclick(handles)
% This hObject is the context menu, so this function only works for
% the context menu items on the intensity plot (that show the
% temporal clusters.)

% Remember!:  Position is [left bottom width height], 
% except for the context menu where it's [width height].

% First figure out the number or contours and the contour ids, in order.
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
num_contours = sum([p.clusters.numContours]);
displayed_contours = handles.appData.partitions(pidx).displayedContours;


% Now do the height computation to figure out which contour the user wants
% to become active.
clickpoint = get(handles.fig,'CurrentPoint'); % Point on figure where clicked.
fig_pos = get(handles.fig, 'Position');	% in pixels.
% normalized units -> pixel units
set(handles.guiOptions.face.imagePlotH, 'Units', 'Pixels');
imap_pos = get(handles.guiOptions.face.imagePlotH, 'Position');
set(handles.guiOptions.face.imagePlotH, 'Units', 'normalized');
imap_bottom = imap_pos(2);
imap_height = imap_pos(4);
% Now put the click point in terms of the imap axis.
click_height =  clickpoint(2) - imap_bottom;
% How many pixels does each raster get (in terms of height)?
pixels_per_raster = imap_height / num_contours;


% Contour_height is the order of the contour we are interested in.
contour_height = num_contours - ceil(click_height/pixels_per_raster)+1;
%highlighted_contour_id = contour_ids(index(contour_order));
highlighted_contour_id = displayed_contours(contour_height);


%%
% plot_cluster_mean_callback
function plot_cluster_mean_callback(hObject, handles)
cid = get(get(hObject, 'Parent'), 'UserData');
if (isempty(cid))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end
val = get(hObject, 'Checked');
if(strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');
    do_show = 1;
else
    set(hObject, 'Checked', 'off');
    do_show = 0;
end

pidx = handles.appData.currentPartitionIdx;
cidx = find([handles.exp.partitions(pidx).clusters.id] == cid);
handles.appData.partitions(pidx).clusters(cidx).doPlotMean = do_show;
handles = plot_gui(handles);
guidata(handles.fig,handles);


%% 
function change_contour_color_callback(hObject, handles);
highlighted_contour_id = determine_highlighted_contour_leftclick(handles);
oidx = handles.appData.currentContourOrderIdx;
% handles.exp.contourColors(highlighted_contour_id,:) = ...
%     1 - handles.exp.contourColors(highlighted_contour_id,:);
index = handles.exp.contourOrder(oidx).index;
cell = index(highlighted_contour_id);
handles.exp.contourColors(cell,:) = rand(1,3);


handles = plot_gui(handles);
guidata(handles.fig,handles);


%% 
% plot_cluster_stddev_callback
function plot_cluster_stddev_callback(hObject, handles)
cid = get(get(hObject, 'Parent'), 'UserData');
if (isempty(cid))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end
val = get(hObject, 'Checked');
if(strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');
    do_show = 1;
else
    set(hObject, 'Checked', 'off');
    do_show = 0;
end
pidx = handles.appData.currentPartitionIdx;
cidx = find([handles.exp.partitions(pidx).clusters.id] == cid);
handles.appData.partitions(pidx).clusters(cidx).doPlotStandardDeviation = ...
    do_show;
handles = plot_gui(handles);
guidata(handles.fig,handles);



%%
function show_cluster_position_callback(hObject, handles)
cid = get(get(hObject, 'Parent'), 'UserData');
if (isempty(cid))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end
val = get(hObject, 'Checked');
if (strcmp(val, 'off'))
    set(hObject, 'Checked', 'on');
    do_show = 1;
else
    set(hObject, 'Checked', 'off');
    do_show = 0;
end
pidx = handles.appData.currentPartitionIdx;
cidx = find([handles.exp.partitions(pidx).clusters.id] == cid);
handles.appData.partitions(pidx).clusters(cidx).doShowPosition = do_show;
handles = plot_gui(handles);
guidata(handles.fig, handles);



%%
function show_cluster_border_callback(hObject, handles)
cid = get(get(hObject, 'Parent'), 'UserData');
if (isempty(cid))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end
val = get(hObject, 'Checked');
if (strcmp(val, 'off'))    
    set(hObject, 'Checked', 'on');
    do_show = 1;
else
    set(hObject, 'Checked', 'off');
    do_show = 0;
end
pidx = handles.appData.currentPartitionIdx;
cidx = find([handles.exp.partitions(pidx).clusters.id] == cid);
handles.appData.partitions(pidx).clusters(cidx).doShowBorder = do_show;
handles = plot_gui(handles);
guidata(handles.fig, handles);



%%
function kill_cluster_callback(hObject, handles)
% First we 'kill' the appropriate cluster.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  Of course if the
% user decides to reset the clusterting, then the user can have the
% contours back (that composed the cluster.)  Reseting the contours
% loses all the information about the 'killed' cluster.  Thus the
% cluster is really lost, while the contours are not. 

% Note that this function uses the old setup of (globals, exp) that
% was used in the early version of this code.

% This is the menu item, and the data is in the context menu, which
% is the parent.
id = get(get(hObject, 'Parent'), 'UserData');
if (isempty(id))
    errordlg('Cluster patches are setup incorrectly.');
    return;
end

cluster_id = id(1);

varargin{1} = 'clusters';
varargin{2} = cluster_id;
handles = killclusters(handles,handles.exp.globals, handles.exp, varargin{:});

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
%handles = plot_intensity_image(handles);
%	handles = setup_cluster_patches(handles);
handles = plot_gui(handles);

guidata(handles.fig, handles);



%%
function signals_checkbox_callback(hObject, handles)
%val = get(hObject, 'Value');    
%if (val == 1)
%    set(hObject, 'Value', 0);    
%else
%    set(hObject, 'Value', 1);    
%end
handles = plot_gui(handles);
guidata(hObject,handles);


%%
% preprocessing_options_callback
function preprocessing_options_callback(hObject, handles)
[st, filter_names] = readdir(handles, 'preprocessors');	
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);

do_one_cluster = 1;
keep_same_contours = 0;
keep_same_clusters = 0;

qstring = ['Would you like to keep the same CONTOURS as partition ' ...
	   handles.exp.partitions(pidx).title ...
	   ' or would you like to reset them?'];
button = questdlg(qstring, 'Reset contours', ...
		  'Keep', 'Reset', 'Cancel', ...
		  'Keep') ;
if (strcmpi(button, 'Keep'))
    keep_same_contours = 1;
elseif (strcmpi(button, 'Reset'))
    keep_same_contours = 0;
else
    return;
end

if (keep_same_contours)
    qstring = ['Would you like to keep the same CLUSTERS as partition ' ...
	       handles.exp.partitions(pidx).title ...
	       ' or would you like to reset them?'];
    button = questdlg(qstring, 'Reset clusters', ...
		      'Keep', 'Reset', 'Cancel', ...
		      'Keep') ;
    if (strcmpi(button, 'Keep'))
        keep_same_clusters = 1;
        do_one_cluster = 0;
    elseif (strcmpi(button, 'Reset'))
        keep_same_clusters = 0;
        do_one_cluster = 1;
    else
    	return;
    end
end

universe = st;
[sidxs,universe2,preprocess_options] = ...
    SelectBox({'Preprocessing Options'}, universe, ...
	      p.preprocessStrings, ...
	      'Please select the appropriate preprocessing steps.', ...
	      p.preprocessOptions);
if isempty(universe2) & isempty(sidxs) & isempty(preprocess_options)
    return;
end
handles.exp.preprocessOptions = preprocess_options;
handles.exp.preprocessStrings = universe2(sidxs);

handles = create_clusters_gui(handles, 1 , ...
			      'onecluster', do_one_cluster, ...
			      'newpreprocessing', 1, ...
			      'keepcontours', keep_same_contours, ...
			      'keepclusters', keep_same_clusters);


% Plot the new data.
%handles = plot_intensity_image(handles);
handles = plot_gui(handles);
guidata(hObject, handles);



%% delete_clusters_by_id_callback
function delete_clusters_by_id_callback(hObject, handles)
% First we 'kill' the appropriate cluster.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  Of course if the
% user decides to reset the clustering, then the user can have the
% contours back (that composed the cluster.)  Reseting the contours
% loses all the information about the 'killed' cluster.  Thus the
% cluster is really lost, while the contours are not.

% Note that this function uses the old setup of (globals, exp) that
% was used in the early version of this code.

% This is the menu item, and the data is in the context menu, which
% is the parent.

% Get the cluster sizes for deletion.
prompt={'Enter the ids of clusters to delete:'};
def = {''};
dlgTitle='Kill clusters by id';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    %errordlg('You must enter a valid size');
    return;
end
% Set up the variable argument used to kill the clusters.
varargin{1} = 'clusters';
varargin{2} = str2num(answer{1});
handles = killclusters(handles,handles.exp.globals, handles.exp, varargin{:});

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
%handles = plot_intensity_image(handles);
%handles = setup_cluster_patches(handles);
handles = plot_gui(handles);

guidata(handles.fig, handles);



%% delete_clusters_by_size_callback
function delete_clusters_by_size_callback(hObject, handles)
% First we 'kill' the appropriate cluster.  'Kill' means hide and you
% can't have it back.  Thus the strong terminology.  Of course if the
% user decides to reset the clustering, then the user can have the
% contours back (that composed the cluster.)  Reseting the contours
% loses all the information about the 'killed' cluster.  Thus the
% cluster is really lost, while the contours are not. 

% Note that this function uses the old setup of (globals, exp) that
% was used in the early version of this code.

% This is the menu item, and the data is in the context menu, which
% is the parent.

% Get the cluster sizes for deletion.
prompt={'Enter the sizes of clusters to delete:'};
def = {''};
dlgTitle='Mask title';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    %errordlg('You must enter a valid size');
    return;
end
% Set up the variable argument used to kill the clusters.
varargin{1} = 'bysize';
varargin{2} = str2num(answer{1});
handles = killclusters(handles,handles.exp.globals, handles.exp, varargin{:});

% We want to replot the entire gui but it's not clear that plot_gui
% does this.  It ignores the intensity map.
axes(handles.guiOptions.face.imagePlotH);
%handles = plot_intensity_image(handles);
%handles = setup_cluster_patches(handles);
handles = plot_gui(handles);

guidata(handles.fig, handles);



%%
function plot_highlighted_contours_callback(hObject, handles)
plot_highlighted_contours(handles);




%% highlight_contours_by_cluster_id_callback
function highlight_contours_by_cluster_id_callback(hObject, handles)
if (handles.appData.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

prompt = {'Enter the cluster ids:'};
def = {''};
dlgTitle = 'Highlight contours by cluster id';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
cluster_ids_for_highlight = str2num(answer{1});

pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
cluster_ids = [p.clusters.id];

% BP.
cluster_ids_for_highlight = intersect(cluster_ids_for_highlight, cluster_ids);

if(isempty(cluster_ids_for_highlight))
    errordlg('There are no clusters with those ids.');
    return;
end

% First we translate from order to id.
for cid = cluster_ids_for_highlight    
    cidx = find([p.clusters.id] == cid);    
    contour_ids = p.clusters(cidx).contours;    
    handles.appData.activeCells = [handles.appData.activeCells contour_ids];
end
handles.appData.activeCells = unique(handles.appData.activeCells);

handles = plot_gui(handles);
guidata(hObject, handles);



%%
function highlight_contours_by_order_callback(hObject, handles)
if (handles.appData.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

prompt = {'Enter the ORDER (not Id) of contours to highlight:'};
def = {''};
dlgTitle = 'Highlight contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});
% BP.
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > handles.exp.numContours) = [];
% First we translate from order to id.
coidx = handles.appData.currentContourOrderIdx;
contour_ids = handles.exp.contourOrder(coidx).order(contour_orders);

handles.appData.activeCells = [handles.appData.activeCells contour_ids];
handles.appData.activeCells = unique(handles.appData.activeCells);

handles = plot_gui(handles);
guidata(hObject, handles);



%%
% highlight_contours_by_order_in_partition_callback
function highlight_contours_by_order_in_partition_callback(hObject, handles)
% BP.
if (handles.appData.useContourSlider)
    warndlg(['Since contour slider mode shows only one cell at a' ...
	     ' time, you must uncheck  "Preferences->Use Contour' ...
	     ' Slider" to use this function.']);
    return;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

% Get the orders that the user would like.
prompt = {'Enter the ORDER (not Id) of contours to highlight:'};
def = {''};
dlgTitle = 'Highlight contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});

% Get the correct partition and the correct contour ids.
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
nonnan_contour_ids = find(~isnan([p.clusterIdxsByContour{1:end}]));
num_contours = length(nonnan_contour_ids);

% BP.
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > num_contours) = [];

% Get the orders for all the contours in the partition.
coidx = handles.appData.currentContourOrderIdx;
nonnan_ordering = handles.exp.contourOrder(coidx).index(nonnan_contour_ids);

% Sort by the order and pick out the contour_orders worth of ids.
nn = [nonnan_ordering; nonnan_contour_ids]';
sorted_nn = sortrows(nn, 1);
contour_ids = sorted_nn(contour_orders,2)';

% Put these contoru ids into the correct structure.
handles.appData.activeCells = [handles.appData.activeCells contour_ids];
handles.appData.activeCells = unique(handles.appData.activeCells);

% Plot 'n go.
handles = plot_gui(handles);
guidata(hObject, handles);





%% 
% function delete_contours_by_order_callback(hObject, handles)
function delete_contours_by_order_callback(hObject, handles)
% Get the cluster sizes for deletion.
prompt = {'Enter the ORDER (not Id) of contours to delete:'};
def = {''};
dlgTitle = 'Kill contours by order';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    return;
end
contour_orders = str2num(answer{1});
% BP.
contour_orders(contour_orders < 1) = [];
contour_orders(contour_orders > handles.exp.numContours) = [];
% First we translate from order to id.
coidx = handles.appData.currentContourOrderIdx;
contour_ids = handles.exp.contourOrder(coidx).order(contour_orders);
handles = delete_contours_from_partition(handles, contour_ids);

handles = plot_gui(handles);
guidata(hObject, handles);


%%
% function merge_highlighted_clusters_callback(hObject, handles)
function merge_highlighted_clusters_callback(hObject, handles)
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
merge_cluster_ids = [];
for c = 1:p.numClusters
    if (p.clusters(c).doShow == 1)
	cid = p.clusters(c).id;
	merge_cluster_ids(end+1) = cid;
    end
end
% BP
if (isempty(merge_cluster_ids))
    return;
end

% Merge the clusters.
handles = mergeclusters(handles, pidx, {merge_cluster_ids});

% Redisplay.
%handles = plot_intensity_image(handles);
%handles = setup_cluster_patches(handles);
handles = plot_gui(handles);
guidata(hObject, handles);


%%
function order_clusters_by_intensity_peak_callback(hObject, handles);
%Take the clean version of the mean intensity of each cluster, find the
%peak intensity and then set up their cluster order by when their peaks 
%occur relative to each other.
pidx = handles.appData.currentPartitionIdx;
handles = order_clusters_by_intensity_peak (handles, pidx);
handles = plot_gui(handles);
guidata(hObject, handles);


%%
% detect_signals_callback
function detect_signals_callback(hObject, handles)
handles = detect_signals(handles);

% Now fill the popup with the saved detections.
signals_names = uiget(handles, 'signals', 'signalspopup', 'String');
didx = handles.appData.currentDetectionIdx;

new_signal_name = handles.exp.detections(didx).title;
signals_names{end+1} = new_signal_name;
val = length(signals_names);
handles = uiset(handles, 'signals', 'signalspopup', ...
		'String', signals_names);
handles = uiset(handles, 'signals', 'signalspopup', ...
		'Value', val);

handles = plot_gui(handles);
guidata(hObject, handles);


%%
function signals_popup_callback(hObject, handles)
signals_names = uiget(handles, 'signals', 'signalspopup', 'String');
didx_popup = uiget(handles, 'signals', 'signalspopup', 'Value');
signal_name = signals_names{didx_popup};

% This string is created in createclusters.m
[start fin extent match tokens names] = regexp(signal_name, 'id[0-9]+');
if isempty(match)
    didx = str2num(signal_name);		% simple name for early stuff.
else
    didx = str2num(signal_name(start+2:fin));
end
handles.appData.currentDetectionIdx = didx;
handles = plot_gui(handles);
guidata(hObject, handles);


%%
function export_signals_to_analyzer_callback(hObject, handles);

% 1) get frames of interest by user clicks
pidx = handles.appData.currentPartitionIdx;
%gather all contours in all clusters of this partition
clustered_contour_ids = [];
for clidx = 1:handles.exp.partitions(pidx).numClusters;
    clustered_contour_ids = cat(2,clustered_contour_ids,...
        handles.exp.partitions(pidx).clusters(clidx).contours);
end
clean_traces = handles.exp.partitions(pidx).cleanContourTraces;
clean_traces = clean_traces(clustered_contour_ids,:);

[intensitymap start_idx, stop_idx, x, y] = ...
        get_raster_input(handles, clean_traces);

% 2) get onsets and offsets, transform into a logical matrix
didx = handles.appData.currentDetectionIdx;
tempons = handles.exp.detections(didx).onsets;
onsets = cell(size(tempons));
onsets(clustered_contour_ids) = tempons(clustered_contour_ids);
tempoffs = handles.exp.detections(didx).offsets;
offsets = cell(size(tempons));
offsets(clustered_contour_ids) = tempoffs(clustered_contour_ids);


activitymtx = logical(zeros(size(onsets,2),size(clean_traces,2)));
onsmtx = activitymtx;
for cidx = 1:size(onsets,2);%for each cell
    for oidx = 1:length(onsets{cidx});%for each onset/activation
        frameson = onsets{cidx}(oidx):offsets{cidx}(oidx);
        activitymtx(cidx,frameson) = 1;%activity matrix has 1 between on and
        % off of any cell activation and zeros everywhere else
        onsmtx(cidx,onsets{cidx}(oidx)) = 1;
    end
end
%this does not work because of places where an onset is the frame after an offset
% onsmtx = ct_keepfirstonframe(activitymtx')';%onsmtx has 1s only where onsets are, zeros all else


%for each specified region of frames (ie if multiple)
figthere = 0;%default that analyzer figure not already there
for chunk_idx = 1:length(start_idx);    
% 2) For each clicked region get all signals from current detection with onsets 
% within those frames
    thisstart = start_idx(chunk_idx);
    thisstop = stop_idx(chunk_idx);
    thisonsmtx = onsmtx(:,thisstart:thisstop);%ons starting in these frames
    thisactivitymtx = activitymtx(:,thisstart:thisstop);
    thisactivitymtx(~sum(thisonsmtx,2),:)=0;%all activity of cells with ons starting in these frames
    %get name ready to pass
    filename = handles.exp.fileName;
    perspot = strfind(filename,'.');
    filename(perspot:end) = [];
    chunkname = [filename,'_Detect',num2str(didx),...
        '_Frm',num2str(thisstart),'-',num2str(thisstop)];
    %evaluate whether the Analyzer Figure is already there or not
    if chunk_idx == 1;
        analyzerFigure = findobj('type','figure','tag','analyzerFigure');
        if ~isempty(analyzerFigure)
            figthere = 1;
        end
%         if isfield(handles,'signalAnalyzerFig');
%             if ~isempty(handles.signalAnalyzerFig);
%                 figthere =1;
%             end
%         end
    end
    %    if the analyzer does not exist, create it first
    if ~figthere
        analyzerFigure = create_signal_analyzer(handles);
        figthere = 1;
    end

% 3) pass data to the analyzer
    data_to_analyzer(analyzerFigure,...
        handles,...
        thisactivitymtx,...
        thisonsmtx,...
        chunkname);
end
guidata(hObject, handles);


%%
function signal_edit_mode_callback(hObject, handles)
%turn on/off signal edit mode
if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.contourslidercheckbox,'value',1);%put on contour slider
    set(handles.uigroup{lidx}.signals_check,'value',1);%turn on show signals mode
    caltracer('use_contour_slider_callback',gcbo,guidata(gcbo))
end

%%
function click_frame_input_callback(hObject, handles);

if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.use_numerical_frame_input_checkbox,'value',0);
    set(handles.uigroup{lidx}.use_numerical_frame_input_min,'enable','off');
    set(handles.uigroup{lidx}.use_numerical_frame_input_max,'enable','off');

    guidata(hObject, handles);
end

%%
function numerical_frame_input_callback(hObject, handles);

if get(hObject,'value') == 1;
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.use_frame_click_input_checkbox,'value',0);
    set(handles.uigroup{lidx}.use_numerical_frame_input_min,'enable','on');
    set(handles.uigroup{lidx}.use_numerical_frame_input_max,'enable','on');

    guidata(hObject, handles);
end