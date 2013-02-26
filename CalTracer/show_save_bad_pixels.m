function handles = show_save_bad_pixels(hObject,handles);
%takes input from badpixel editboxes and highlights the chosen rows and
%columns.  Also saves the values of pixels to ignore in exp.tcImage.

midx = handles.appData.currentMaskIdx;
ridx = handles.appData.currentRegionIdx;
lidx = get_label_idx(handles, 'image');

button = get(hObject,'tag');
value = str2num(get(hObject,'string'));
imsz = size(handles.exp.tcImage(midx).image);
thisax = handles.uigroup{lidx}.imgax;
% handl = handles.guiOptions.face.handl{ridx}{midx};
switch button
    case 'leftcols'
        startval = 1;
        stopval = value;
        if value == 0;
            handles.exp.tcImage(midx).badpixels.leftcols = [];
        else            
            handles.exp.tcImage(midx).badpixels.leftcols = [startval:stopval];
        end
        if isfield (handles.exp.tcImage(midx).badpixels,'leftbox')
            if ~isempty(handles.exp.tcImage(midx).badpixels.leftbox);
                delete (handles.exp.tcImage(midx).badpixels.leftbox)
            end
        end
        handles.exp.tcImage(midx).badpixels.leftbox =... 
            plot([startval stopval stopval startval]+0.5,...
            [0 0 imsz(2) imsz(2)]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'rightcols'
        startval = (imsz(2)-value)+1;
        stopval = imsz(2);
        if value == 0;
            handles.exp.tcImage(midx).badpixels.rightcols = [];
        else            
            handles.exp.tcImage(midx).badpixels.rightcols = [startval:stopval];
        end
        if isfield (handles.exp.tcImage(midx).badpixels,'rightbox')
            if ~isempty(handles.exp.tcImage(midx).badpixels.rightbox);
                delete (handles.exp.tcImage(midx).badpixels.rightbox)
            end
        end
        handles.exp.tcImage(midx).badpixels.rightbox =...
            plot([stopval startval startval stopval]+0.5,...
            [0 0 imsz(2) imsz(2)]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'upperrows'
        startval = 1;
        stopval = value;
        if value == 0;
            handles.exp.tcImage(midx).badpixels.upperrows = [];
        else            
            handles.exp.tcImage(midx).badpixels.upperrows = [startval:stopval];
        end
        if isfield (handles.exp.tcImage(midx).badpixels,'upperbox')
            if ~isempty(handles.exp.tcImage(midx).badpixels.upperbox);
                delete (handles.exp.tcImage(midx).badpixels.upperbox)
            end
        end
        handles.exp.tcImage(midx).badpixels.upperbox =...
            plot([0,imsz(1),imsz(1),0]+0.5,...
            [startval startval stopval stopval]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
    case 'lowerrows'
        startval = (imsz(1)-value)+1;
        stopval = imsz(1);
        if value == 0;
            handles.exp.tcImage(midx).badpixels.lowerrows = [];
        else            
            handles.exp.tcImage(midx).badpixels.lowerrows = [startval:stopval];
        end
        if isfield (handles.exp.tcImage(midx).badpixels,'lowerbox')
            if ~isempty(handles.exp.tcImage(midx).badpixels.lowerbox);
                delete (handles.exp.tcImage(midx).badpixels.lowerbox)
            end
        end
        handles.exp.tcImage(midx).badpixels.lowerbox =... 
            plot([0,imsz(1),imsz(1),0]+0.5,...
            [startval startval stopval stopval]+0.5,...
            'parent',thisax,'color','r','linewidth',2);
end
% handles.guiOptions.face.handl{ridx}{midx} = handl;