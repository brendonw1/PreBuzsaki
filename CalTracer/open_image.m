function handles = open_image(handles,varargin)
% function handles = open_image(handles)
% Open an image and display a listdlg to create a zstack.  Save the
% results.


if ~isempty(varargin);
    zstack_name = varargin{1};
else
    zstack_name = [];
end
% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;

if strcmpi(handles.appData.currentImageInputType, 'inputarg') %if an image was 
    %input to epo at initiation and this is the first time an image is being 
    %opened (if after first time, ='s 2);
    filename = 'Workspace Variable';
    pathname = '';
%     numframes=1;%apparently never used
    zstack=double(handles.exp.tcImage.image);
    param.frameType='variable';
else %if no image yet... get one
    if strcmpi(handles.appData.currentImageInputType, 'inputfilename');
        [pathname,filename,ext]=fileparts(varargin{2})
        filename = [filename ext];
        if isempty(pathname);
            pathname = [cd '\'];
        else
            pathname = [pathname '\'];
        end
        set(handles.fig, 'Name', [handles.appData.title ' - ' filename ext]);
        fnm = [pathname filename];
        handles.exp.fileName = fnm;
    else
        [filename, pathname] = uigetfile({'*.tif'}, 'Choose image to open');
        if ~ischar(filename)
            handles = [];
            return
        end
        set(handles.fig, 'Name', [handles.appData.title ' - ' filename]);
        fnm = [pathname filename];
        handles.exp.fileName = fnm;
    % 	info = imfinfo(fnm);%apparently never used
    % 	numframes = length(info);%apparently never used
    end	
    if isempty(zstack_name);%if zstack_name was not given at input (as might
            %happen with skipthrough)  
        % Load the various zstack routines from the directory.
        [str, zstack_names] = readdir(handles, 'zstacks');
        %allow user to specify favorite zstack function... or default=1;
        try
            match=ct_zstackTypeDefaultPreference(zstack_names);
        catch
            match=1;
        end
        %str = {'Average', 'Maximum', 'First Frame', 'StdDev', 'DFoverF'};
        [s,v] = listdlg('PromptString','Select a zstack option:',...
                'SelectionMode','single',...
                'ListString', str,...
                'InitialValue',match);
        if (~v)
            handles = [];
            return;
        end
        % Process the image stack.
%         button = str{s};%apparently never used
        zstack_name = zstack_names{s};
    end
	[zstack, param] = feval(zstack_name, filename, pathname);
end

handles.exp.fileName = filename;
% Save the output of the zstack routine.
[maxy maxx] = size(zstack);
handles.exp.tcImage(midx).title = filename;
handles.exp.tcImage(midx).fileName = filename;
handles.exp.tcImage(midx).pathName = pathname;
handles.exp.tcImage(midx).nX = maxx;
handles.exp.tcImage(midx).nY = maxy;
handles.exp.tcImage(midx).frameType = param.frameType;
handles.exp.tcImage(midx).image = zstack;
handles.exp.tcImage(midx).maskLoadedFromFile = 'not loaded';
handles.exp.tcImage(midx).movementVector = [0 0];
handles.exp.tcImage(midx).rotationRadians = 0;
handles.exp.tcImage(midx).badpixels.leftcols = [];
handles.exp.tcImage(midx).badpixels.rightcols = [];
handles.exp.tcImage(midx).badpixels.upperrows = [];
handles.exp.tcImage(midx).badpixels.lowerrows = [];


%%% This is a hack, we should have an index explainined the the
%current GUI index.  But instead we just look at active widgets. -DCS:2005/04/04
handles = hide_uigroup(handles, 'logo');
handles = enable_uigroup(handles, 'image');
handles = enable_uigroup(handles, 'resolution');
%handles = menuset(handles, 'Functions', 'functions', ...
%		  'Measure distance', 'Enable', 'on');
handles = display_zstack_image(handles);
handles = adjust_contrast(handles);

if (strcmp(uiget(handles, 'filterimage', 'det_tx1', 'Visible'), 'on'))
    draw_region_widget(handles);
end

ran = 1;