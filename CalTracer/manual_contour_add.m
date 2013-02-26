function handles = manual_contour_add(handles)
% function handles = manual_contour_add(handles)
% Manually add a circle or contour to the image.

handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'detectcells','reset','enable','on');
handles = uiset(handles,'filterimage','all','enable','off');

dummya = [];
midx = handles.appData.currentMaskIdx;
ridx = handles.appData.currentRegionIdx;
% Circle
currentbutton = findobj('style','radiobutton','string','Circle','parent',handles.fig,'visible','on');
    %find current relevant radio button... as denominated by it's
    %visibility
if get(currentbutton,'value') == 1
    x = [];
    y = [];
    [x(1) y(1) butt] = ginput(1);
    if (butt > 1)
        handles = uiset(handles,'detectcells','all','enable','on');
        handles = uiset(handles,'filterimage','all','enable','on');
        return;
    end    
    dummya = plot(x,y,'+r');
    [x(2) y(2) butt] = ginput(1);
    if (butt > 1)
        delete(dummya);
        handles = uiset(handles,'detectcells','all','enable','on');
        handles = uiset(handles,'filterimage','all','enable','on');
        return
    end    
    r = sqrt((x(2)-x(1)).^2+(y(2)-y(1)).^2);
    theta = 0:pi/50:2*pi-pi/50;
    newcn = [r*cos(theta)'+x(1) r*sin(theta)'+y(1)];
else					% random contour.
    nx = [];
    ny = [];
    butt = 1;
    while (butt <= 1)
        [x y butt] = ginput(1);
        nx = [nx; x];
        ny = [ny; y];
        if size(nx,1) == 1
            dummya = plot(nx,ny,'+r');
        else
            set(dummya, ...
		'xdata', nx, ...
		'ydata', ny, ...
		'linestyle',':', ...
		'linewidth', 2, ...
		'marker','none');
        end
    end
    newcn = [nx ny];
end

delete(dummya);
% BP.
if (size(newcn,1) < 3)
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end

ct = create_centroid(newcn);
% Some kind of check to make sure these in the right region?
reg = 0;
min_area = str2num(uiget(handles, 'detectcells', 'txarlow', 'String'));
max_area = str2num(uiget(handles, 'detectcells', 'txarhigh', 'String'));

coords = handles.exp.regions.coords;
nregions = handles.exp.numRegions;
%for c = 1:length(region.coords)
for c = 1:nregions
    if (inpolygon(ct(1),ct(2),coords{c}(:,1),coords{c}(:,2)))
        if (reg == 0)
            reg = c;
        elseif (polyarea(coords{c}(:,1),coords{c}(:,2)) < ...
		polyarea(coords{reg}(:,1),coords{reg}(:,2)))
            reg = c;
        end
    end
end

% BP.  Make sure region is the right size.
thisareapixels = polyarea(newcn(:,1),newcn(:,2));
thisareamicrons = thisareapixels * (handles.exp.mpp^2);
if thisareamicrons == 0;
    errordlg('Attempted contour has 0 area.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end
if thisareamicrons < min_area(reg)
    errordlg('Attempted contour area is too small.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end
if thisareamicrons > max_area(reg)
    errordlg('Attempted contour area is too large.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end
    

% end is length(cn{reg})
handles.exp.regions.contours{reg}{midx}{end+1} = newcn;
%%% Could be taken out to the GUI level. -DCS:2005/04/05
handles = draw_cell_contours(handles, 'ridx', reg);
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');