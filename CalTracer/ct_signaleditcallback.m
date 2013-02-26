function ct_signaleditcallback
%user just clicked the trace axes when in "edit signals" mode

%% get object and basic info
obj = gcbo;
cp = get(obj,'currentpoint');
x = cp(1,1);%get position of click in datapoint values
y = cp(1,2);%

handles = guidata(gcbo);%get guidata
clicktype = get(handles.fig,'SelectionType');%get click type (ie Right vs Left)

starts = handles.guiOptions.face.startmarks;
stops = handles.guiOptions.face.stopmarks;

%% figure out whether the click was on a marker
set(gca,'units','pixels');
numpix = get(gca,'position');
numpix = numpix(3:4);
set(gca,'units','normalized');
xl = get(gca,'xlim');
yl = get(gca,'ylim');
xresol = (xl(2)-xl(1))/numpix(1);%gives data value/pixel
yresol = (yl(2)-yl(1))/numpix(2);
%default markersize = 6 points = 6/72inch = 1/12 inch
ppi = get(0,'ScreenPixelsPerInch');
pixelspermarker = ceil(ppi/12)+2;
markradx = pixelspermarker * xresol/2;%how wide the marker is in xvalue... add 2 to make easier
markrady = 1.2 * pixelspermarker * yresol/2;%how wide the marker is in yvalue
instart = 0;
instop = 0;
for sigidx = 1:length(starts);%check to see if click was on a start/stop marker (ie to edit it)
    startx = get(starts(sigidx),'xdata');
    starty = get(starts(sigidx),'ydata');
    if x>(startx-markradx) && x<(startx+markradx)
        if y>(starty-markrady) && y<(starty+markrady)
            instart = 1;
            signum = sigidx;
            cellnum = handles.appData.currentCellId;
            break%note starts trump overlapping stops
        end
    end
    stopx = get(stops(sigidx),'xdata');
    stopy = get(stops(sigidx),'ydata');
    if x>(stopx-markradx) && x<(stopx+markradx)
        if y>(stopy-markrady) && y<(stopy+markrady)
            instop = 1;
            signum = sigidx;
            cellnum = handles.appData.currentCellId;
            break
        end
    end
end

didx = handles.appData.currentDetectionIdx;
if instart || instop%if clicked on a marker
    if strcmp(clicktype,'alt');%if right click...
        handles.exp.detections(didx).onsets{cellnum}(signum) = [];
        handles.exp.detections(didx).offsets{cellnum}(signum) = [];
    elseif strcmp(clicktype,'normal');%if left click...
        [x,y] = ginput(1);
        x = round(x/handles.exp.timeRes)+1;%round to nearest frame - add one b/c Dave called Frame 1 Time = 0
        if instart
            if x <= handles.exp.detections(didx).offsets{cellnum}(signum,1)%if not after the stop
                handles.exp.detections(didx).onsets{cellnum}(signum,1) = x;
            end
        elseif instop
            if x >= handles.exp.detections(didx).onsets{cellnum}(signum,1)%if not before its start
                handles.exp.detections(didx).offsets{cellnum}(signum,1) = x;
            end
        end
    end
elseif strcmp(clicktype,'normal')%ie if click was elsewhere and was a left click... add a new event
    ontime = round(x/handles.exp.timeRes);%round initial click to nearest frame
    [x,y] = ginput(1);%next click for offset time
    offtime = round(x/handles.exp.timeRes);%round second click to nearest frame
    if offtime >= ontime;
        cellnum = handles.appData.currentCellId;
        cellons = handles.exp.detections(didx).onsets{cellnum};
        [cellons,idx] = sort([cellons ontime]);
        handles.exp.detections(didx).onsets{cellnum} = cellons;
        celloffs = handles.exp.detections(didx).offsets{cellnum};
        if idx(end)<=size(celloffs,1);
            celloffs = [celloffs(1:idx(end)-1); offtime; celloffs(idx(end):end)];
        elseif idx(end)>size(celloffs,1);
            celloffs = [celloffs offtime];
        end
        handles.exp.detections(didx).offsets{cellnum} = celloffs;
    end
else
    return
end


handles = plot_gui(handles);
guidata(handles.fig,handles);