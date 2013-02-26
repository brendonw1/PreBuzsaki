function analyzerFigure = create_signal_analyzer(handles);

%make figure itself
analyzerHandles.handles.figure = figure('units','normalized',...
    'position',[.20 (25/90) .6 40/90],...
    'CloseRequestFcn',@analyzer_closer_fcn,...
    'NumberTitle','off',...
    'Name','Signal Analyzer',...
    'tag','analyzerFigure');
analyzerFigure = analyzerHandles.handles.figure;

%% make menus
analyzerHandles.handles.analyzerMenu = uimenu('Label', 'Analyzer');
% Add the menu items.

analyzerHandles.handles.activeAnalyzerMenu = ...
   uimenu(analyzerHandles.handles.analyzerMenu, ...
   'Label', 'Active Analyzer', ...
   'Checked','on',...
   'Callback', @toggle_active_analyzer);
analyzerHandles.handles.importContoursMenu = ...
   uimenu(analyzerHandles.handles.analyzerMenu, ...
   'Label', 'Import Contours', ...
   'Callback', @analyzer_import_contours);
analyzerHandles.handles.activesToVnt = ...
   uimenu(analyzerHandles.handles.analyzerMenu, ...
   'Label', 'Write chunk actives to vnt', ...
   'Callback', @write_chunk_actives_to_vnt);
analyzerHandles.handles.activesToVnt = ...
   uimenu(analyzerHandles.handles.analyzerMenu, ...
   'Label', 'Write chunk sequence to vnt', ...
   'Callback', @write_chunk_sequence_to_vnt);


%% chunk selector box
%title for box to select chunks to analyze
analyzerHandles.handles.chunksTitle = uicontrol...
    ('style','text',...
    'backgroundcolor',[.8 .8 .8],...
    'string','Select signal chunks',...
    'FontWeight','Bold',...
    'units','normalized',...
    'position',[.025 .94 .25 .05]);
% box to select chunks to analyze
analyzerHandles.handles.chunksListBox = uicontrol('style','listbox',...
    'string',{},...
    'units','normalized',...
    'position',[0 0 .3 .95],...
    'max',2,...
    'min',0,...
    'value',1,...
    'callback',@cta_color_by_overlap);

%% stuff for choosing operators to act on chunks
%title for operation selector
analyzerHandles.handles.operationTitle = uicontrol...
    ('style','text',...
    'backgroundcolor',[.8 .8 .8],...
    'string','Select operation',...
    'FontWeight','Bold',...    
    'units','normalized',...
    'position',[.325 .91 .15 .05]);
%dropdown to choose operation
[liststrs,fcnnames]=readdir(handles,'signal_analyzer/chunk_operations');
analyzerHandles.handles.operationDropdown = uicontrol...
    ('style','popupmenu',...
    'string',liststrs,...
    'units','normalized',...
    'position',[.325 .885 .15 .04]);
%pushbutton to execute operation
analyzerHandles.handles.operationPushButton = uicontrol...
    ('style','pushbutton',...
    'string','Execute',...
    'units','normalized',...
    'position',[.325 .84 .15 .04],...
    'callback',@analyze_chunks); %analyze chunks may want to change the callback of chunksListBox

%% Other list and gui controls
uicontrol('style','frame',...
    'units','normalized',...
    'position',[.312 .8 .188 .005]);
analyzerHandles.handles.deleteChunkButton = uicontrol...
    ('style','pushbutton',...
    'string','Delete Chunks',...
    'units','normalized',...
    'position',[.325 .72 .07 .04],...
    'callback',@delete_chunks); %analyze chunks may want to change the callback of chunksListBox



%% callback control for chunk selector
%title of buttons to let you choose which function to make the callback of 
%chunk selector listbox
analyzerHandles.handles.chunkSelectorFunctionButtonTitle = uicontrol...
    ('style','text',...
    'backgroundcolor',[.8 .8 .8],...    
    'string','Chunk Selector Fcn',...
    'FontWeight','Bold',...
    'units','normalized',...
    'position',[.325 .105 .15 .04]);
%dropdown to choose which function to make the callback of chunk selector 
%listbox
[liststrs,fcnnames]=readdir(handles,'signal_analyzer/chunk_listbox_callbacks');
analyzerHandles.handles.selectCallbackDropdown = uicontrol...
    ('style','popupmenu',...
    'string',liststrs,...
    'units','normalized',...
    'position',[.325 .07 .15 .04]);
match = strmatch('color_by_overlap',liststrs,'exact');%desired default
if ~isempty(match);
    set(analyzerHandles.handles.selectCallbackDropdown,'Value',match);
end
%pushbutton to assign chosen fcn as callback of chunk selector listbox
analyzerHandles.handles.selectCallbackPushButton = uicontrol...
    ('style','pushbutton',...
    'string','Assign Fcn',...
    'units','normalized',...
    'position',[.325 .025 .15 .04],...
    'callback',@assign_listbox_callback); %analyze chunks may want to change the callback of chunksListBox


%% create a general purpose text display and axes
analyzerHandles.handles.textBox = uicontrol('style','text',...
    'units','normalized',...
    'position',[.5 .9 .5 .1],...
    'backgroundcolor',[.8 .8 .8],...
    'string',['']);
analyzerHandles.handles.axes = axes('units','normalized',...
    'position',[.5 0 .5 .9]);
axis off



%% setting up some data storage fields
analyzerHandles.data.activitymtxs = {};
analyzerHandles.data.onsmtxs = {};
analyzerHandles.data.chunkNames = {};
analyzerHandles.data.contours = {};




%axis for whatever general use
%     1) if no function is called yet: plot contours and fill them in with selected chunks using HSV for number of
%        chunks each cell is in if no function yet executed
%     2) after that, functions can control the axes
%     3) have a button in center column of figure to revert to overlap fcn
    

% handles.signalAnalyzerFig = analyzerHandles.handles.figure;
analyzerHandles.creatorFig = handles.fig;
guidata(analyzerHandles.handles.figure, analyzerHandles);