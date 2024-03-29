function handles = plot_trace(handles)
% plot_trace
% Plot the trace of the cell that is currently in focus.
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);

% Get the appropriate varaibles first.
cellnum = handles.appData.currentCellId;
cl = handles.exp.regions.cl;
traces = handles.exp.traces;
halo_traces = handles.exp.haloTraces;
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
clean_traces = p.cleanContourTraces;
clean_halo_traces = p.cleanHaloTraces;
time_res = handles.exp.timeRes;
contours = handles.exp.contours;



% Set the trace plot active.
delete(get(handles.guiOptions.face.tracePlot, 'Children'));
subplot(handles.guiOptions.face.tracePlot);
hold on;

tidx = 1;
size(traces);
size(halo_traces);
halotime  = time_res*(0:size(halo_traces,2)-1);
tracetime = time_res*(0:size(traces,2)-1);
max(tracetime);

%do_dfoverf = uiget(handles, 'signals', 'df_check', 'value');
%check = uiget(handles, 'signals', 'numslider', 'Checked');

if (handles.appData.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
end

do_trace = uiget(handles, 'signals', 'trace_check', 'value');
do_halo = uiget(handles, 'signals', 'halo_raw_check', 'value');
do_clean_trace = uiget(handles, 'signals', 'clean_trace_check', 'value');
do_clean_halo = uiget(handles, 'signals', 'halo_preprocess_check', 'value');
do_signal_markers = uiget(handles, 'signals', 'signals_check', 'value');

if (~do_trace & ~do_halo & ~do_clean_trace & ~do_clean_halo)
    return;
else
    axes(handles.guiOptions.face.tracePlot);%set as current axes
    set(handles.guiOptions.face.tracePlot,'color','black');
end
lidx = get_label_idx(handles, 'signals');
if get(handles.uigroup{lidx}.signaleditmodecheckbox,'value') == 1%if in signal edit mode
    set(handles.guiOptions.face.tracePlot,...
        'buttondownfcn','ct_signaleditcallback');
end

contour_ids = [handles.exp.contours.id];

clustered_contour_ids = [p.clusters.contours];

coidx = handles.appData.currentContourOrderIdx;
index = handles.exp.contourOrder(coidx).index;

% Since the active cell and current cell GUI concepts conflict
% (i.e. the user gets confused.  It's either one or the other.
if (do_use_current_cell)
    active_cells = cellnum;
else
    active_cells = handles.appData.activeCells;
end
if (isempty(active_cells))
    active_cells = [];
end

for i = active_cells
    % i are ids, not indices.

    nidx = find([handles.exp.contours.id] == i);
    color = handles.exp.contourColors(index(nidx),:);

    if (do_trace)
        trace_to_plot=traces(nidx,:);
        line(tracetime, trace_to_plot, 'Color', color);
    end
    if (do_clean_trace)
        trace_to_plot = clean_traces(nidx,:);
        line(tracetime, trace_to_plot, 'Color', color,'hittest','off');
    end

%     if (do_trace)
%         plot(tracetime, traces(nidx,:), 'Color', color);
%         xlim([0 max(tracetime)]);
%     end
%     if (do_clean_trace)
%         clean_trace = clean_traces(nidx,:);
%         plot(tracetime, clean_trace, 'Color', color);
%     end
    
    if (do_halo)
        plot(halotime, halo_traces(nidx,:), '-x', 'Color', color);
        xlim([0 max([1 max(halotime)]) ]);
    end
    if (do_clean_halo)
        clean_halo_trace = clean_halo_traces(nidx,:);
        plot(halotime, clean_halo_trace, '-x', 'Color', color);
    end
end
xlim([0 max([1 max(halotime)]) ]);
if (do_trace)
    ylabel('Fluorescence (ADU)');
elseif (do_clean_trace)
    ylabel('Fluorescence (various units)');
end


% Plot some cluster means, if so desired.
nclusters = p.numClusters;
cluster_ids = [p.clusters.id];
cph = handles.guiOptions.face.clusterPatchH;
for i = 1:nclusters
    cidx = find([p.clusters.id] == cluster_ids(i));
    cmenu = get(cph(cidx), 'UIContextMenu');
    plot_mean_h = findobj(cmenu, 'Label', 'Plot mean');
    mean_checked = is_checked(plot_mean_h);
    plot_stddev_h = findobj(cmenu, 'Label','Plot standard deviation');
    stddev_checked = is_checked(plot_stddev_h);
    do_show = p.clusters(cidx).doShow;
    color = get(cph(cidx), 'edgecolor'); % not 'none'.
    % The default color is white for the unclustered raster so we have
    % to make it visible against the white background.
    if (isempty(setdiff(color, [1 1 1])))
        color = [1/2 1/2 1/2];
    end
    if (mean_checked & do_show)
        tidx = 1;
        ctraces = {};
        marker = {};
        if (do_trace)
            ctraces{tidx} = [p.clusters(cidx).meanIntensity];
            marker{tidx} = 'none';
            tidx = tidx + 1;
        end
        if (do_clean_trace)
            ctraces{tidx} = [p.clusters(cidx).meanIntensityClean];
            marker{tidx} = 'none';
            tidx = tidx + 1;
        end	

        if (do_halo)
            ctraces{tidx} = [p.clusters(cidx).meanHaloIntensity];
            marker{tidx} = '.';
            tidx = tidx + 1;	    
        end
        if (do_clean_halo)
            ctraces{tidx} =[p.clusters(cidx).meanHaloIntensityClean];
            marker{tidx} = '.';
            tidx = tidx + 1;
        end
        for j = 1:length(ctraces)
            line(tracetime, ctraces{j}, ...
             'Color', color, ...
             'LineWidth', 2, ...
             'Marker', marker{j}, ...
             'MarkerEdgeColor', [0 0 0], ...
             'MarkerSize', 3,...
             'HitTest','off');
        end
    end    
    if (stddev_checked & do_show)
        tidx = 1;
        ctraces = {};
        marker = {};
        if (do_trace)
            ctraces{tidx} = ...
            ...%[p.clusters(cidx).meanIntensity] + ...
            [p.clusters(cidx).stdIntensity];
            marker{tidx} = 'none';
            tidx = tidx + 1;
        end
        if (do_clean_trace)
            ctraces{tidx} = ...
            ...%[p.clusters(cidx).meanIntensityClean] + ...
            [p.clusters(cidx).stdIntensityClean];
            marker{tidx} = 'none';
            tidx = tidx + 1;
        end	

        if (do_halo)
            ctraces{tidx} = ...
            ...%[p.clusters(cidx).meanHaloIntensity] + ...
            [p.clusters(cidx).stdHaloIntensity];
            marker{tidx} = '.';
            tidx = tidx + 1;
        end
        if (do_clean_halo)
            ctraces{tidx} = ...
            ...%[p.clusters(cidx).meanHaloIntensityClean]+...
            [p.clusters(cidx).stdHaloIntensityClean];
            marker{tidx} = '.';
            tidx = tidx + 1;
        end
        for j = 1:length(ctraces)
            line(tracetime, ctraces{j}, ...
             'Color', color, ...
             'LineWidth', 1, ...
             'Marker', marker{j}, ...
             'MarkerEdgeColor', [0 0 0], ...
             'MarkerSize', 3,...
             'HitTest','off');
        end	
    end
end

axis tight;
% Plot the cluster line, so peeps can see what they clustered on.
myylim = ylim;
yheight = myylim(2);
ncluster_regions = length(p.startIdxs);
for i = 1:ncluster_regions
    p.startIdxs(i);
    p.stopIdxs(i);
    
    line_start = p.startIdxs(i) * time_res;
    line_stop = p.stopIdxs(i) * time_res;
    h(i) = line([line_start line_stop], ...
		[yheight yheight], ...
		'Color', [0 0 0], ... % 2 is red.
		'LineWidth', 8,...
        'HitTest','off');
end

% Put this last in order to get the yheight accurate.
handles.guiOptions.face.stopmarks = [];
handles.guiOptions.face.startmarks = [];
for i = active_cells
    % i are ids, not indices.
    nidx = find([handles.exp.contours.id] == i);

    didx = handles.appData.currentDetectionIdx;
    if (do_signal_markers & didx > 0);
        onsets = handles.exp.detections(didx).onsets(nidx);
        offsets = handles.exp.detections(didx).offsets(nidx);
        ecolor = [1 0 0];
        myylim = ylim;
        yheight = myylim(2);
        if ~isempty(onsets)
            onsets = onsets{1};
            offsets = offsets{1};
            for a = 1:length(onsets)
                start_idx = onsets(a);
                stop_idx = offsets(a);
                %draw a line indicating duration of signal, not clickable
                line([tracetime(start_idx) ...
                    tracetime(stop_idx)], ...
                    [yheight yheight], ...
                    'Color', ecolor, ...
                    'LineWidth', 2,...
                    'hittest','off');
                
                %draw start and stop circles for each signal
%                 lidx = get_label_idx(handles, 'signals');
%                 if get(handles.uigroup{lidx}.signaleditmodecheckbox,'value') == 1
                %if in edit mode, give each function a callback
%                     startbuttondownfcn = 'ct_startmarkerfcn';
%                     stopbuttondownfcn = 'ct_stopmarkerfcn';
%                 else
%                     startbuttondownfcn = [];
%                     stopbuttondownfcn = [];
%                 end
%                 end
                handles.guiOptions.face.stopmarks(end+1) = line(tracetime(stop_idx),...%draw stop marker
                    yheight, ...
                    'Color', 'black', ...
                    'LineWidth', 2,...
                    'hittest','off', ...
                    'Marker', 'o',...
                    'UserData',[i a]);%store cell num and event num
                %plot starts last so always visible
                handles.guiOptions.face.startmarks(end+1) = line(tracetime(start_idx),...%draw start marker
                    yheight, ...
                    'Color', ecolor, ...
                    'LineWidth', 2,...
                    'hittest','off', ...
                    'Marker', 'o',...
                    'UserData',[i a]);%store cell num and event num
            end
        end
    end
end

% lidx = get_label_idx(handles, 'signals');
% if get(handles.uigroup{lidx}.signaleditmodecheckbox,'value') == 1
    
    
    %generally assume number of pixels determines resolution of click...
    %actually in click callback will round to nearest pixel
%     set(gca,'units','pixels');
%     numpix = get(gca,'position');
%     numpix = numpix(3:4);
%     set(gca,'units','normalized');
%     xl = get(gca,'xlim');
%     yl = get(gca,'ylim');
%     xresol = (xl(2)-xl(1))/numpix(1);%gives data value/pixel
%     yresol = (yl(2)-yl(1))/numpix(1);

    %default markersize = 6 points = 6/72inch = 1/12 inch
%     ppi = get(0,'ScreenPixelsPerInch');
%     pixelspermarker = ceil(ppi/12);
%     valsradiusmarkerx = pixelspermarker * xresol/2;%how wide the marker is in xvalue
%     valsradiusmarkery = pixelspermarker * yresol/2;%how wide the marker is in yvalue
%     
%     allstartx = [];
%     allstarty = [];
%     allstopx = [];
%     allstopy = [];
%     allstartrefs = [];
%     allstoprefs = [];
%     for sigidx = 1:length(stopmarks);
%         xstartpt = get(startmarks(sigidx),'xdata');
%         ystartpt = get(startmarks(sigidx),'ydata');
%         startxpix = (xstartpt-valsradiusmarkerx):xresol:(xstartpt+valsradiusmarkerx);
%         startypix = (ystartpt-valsradiusmarkery):yresol:(ystartpt+valsradiusmarkery);
%         [startx,starty] = meshgrid(startxpix,startypix);
%         startx = startx(:);
%         starty = starty(:);
%         startrefs = sigidx * ones(size(startx));%mark that these points come from start marker sigidx
%         allstartx = cat(1,allstartx,startx);
%         allstarty = cat(1,allstarty,starty);
%         allstartrefs = cat(1,allstartrefs,startrefs);
%         
%         xstoppt = get(stopmarks(sigidx),'xdata');
%         ystoppt = get(stopmarks(sigidx),'ydata');
%         stopxpix = (xstoppt-valsradiusmarkerx):xresol:(xstoppt+valsradiusmarkerx);
%         stopypix = (ystoppt-valsradiusmarkery):yresol:(ystoppt+valsradiusmarkery);
%         [stopx,stopy] = meshgrid(stopxpix,stopypix);
%         stopx = stopx(:);
%         stopy = stopy(:);
%         stoprefs = sigidx * ones(size(stopx));%mark that these points come from stop marker sigidx
%         allstopx = cat(1,allstopx,stopx);
%         allstopy = cat(1,allstopy,stopy);
%         allstoprefs = cat(1,allstoprefs,stoprefs);
%     end
%     allptsdata = {allstartx;allstarty;allstopx;allstopy;allstartrefs;allstoprefs;};
%     set(gca,'userdata',allptsdata);
% end



% Comment this out for speed reasons.  Not sure why it's here.
%drawnow;
xlabel('Time (sec)');
if (length(active_cells) > 15)
    title_active_cells = active_cells(1:15);
    extra = ' ...';
else
    title_active_cells = active_cells;
    extra = '';
end
title(['Cells: ' num2str(title_active_cells) extra ' of ' ...
       num2str(length(contours)) ' (all) & ' ...
       num2str(length(clustered_contour_ids)) ' (clustered).']);

   