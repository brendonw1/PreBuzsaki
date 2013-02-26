function [onsets, offsets, options] = ...
    epo_max(rastermap, handles, ridxs, clustered_contour_ids, options)

% NB -DCS:2005/08/04 Because the data matrix DOES NOT reflect all of
% the contours, the programmer MUST used clustered_contour_ids to
% index ANYTHING in handles.experiment!


% Get the moving average window length for later.
window_idx = find(strcmp(options.preprocessStrings, 'moving_average'));
windowlen_idx = find(strcmp('windowLength', options.preprocessOptions{window_idx})) + 1;

windowlen = options.preprocessOptions{window_idx}{windowlen_idx};
    

% First find all the maxima / minima via the derivative.

[ncontours, len] = size(rastermap);
do_debug = 0;
dt = options.timeRes.value;

threshold = options.threshold.value;
bunch_cutoff = options.bunchCutoff.value / options.timeRes.value;
bunch_cutoff = round(bunch_cutoff/2);  % Keep the convolution smaller.
if (threshold > 0)
    do_threshold = 1;
else
    do_threshold = 0;
end

% Here's an example of using the preprocessor routines outside of the
% preprocessor loop.  Very easy, just remember to add the GUI options.

% keep tolerence relevant across amplitude scales with zscore.
df_options = add_options_from_gui(handles, epo_derivative_options);
traces = handles.exp.traces(clustered_contour_ids,:);
num_clustered_contour_ids = length(clustered_contour_ids);
onsets = cell(1, ncontours);
offsets = cell(1, ncontours);
do_debug = 0;
idx = 1;
start_idx = options.startIdxs.value;
stop_idx = options.stopIdxs.value;
for cidx = 1:num_clustered_contour_ids
    if (clustered_contour_ids(cidx) == 79)
        do_debug = 0;
        1;
    else
        do_debug = 0;
    end
    
    y = rastermap(cidx,:);
    t = [1:length(y)];
    % Raw data, for later matching maxes later..
    trace = traces(cidx,start_idx:stop_idx);
    
    % Make tolerence indifferent to the time step size.
    % This just won't work for small sampling rate.
    maxmin_idxs = [1:len];
    maxmin_idxs(maxmin_idxs == 1) = [];
    maxmin_idxs(maxmin_idxs == len) = [];
    
    % Now we determine only the maximums.
    midxs = find(y(maxmin_idxs) - y(maxmin_idxs-1) > 0 );
    maxmin_idxs = maxmin_idxs(midxs);
    midxs = find(y(maxmin_idxs) - y(maxmin_idxs+1) > 0);
    max_idxs = maxmin_idxs(midxs);
    max_len = length(max_idxs);
    
    if (do_debug)
        figure; 
        plot(y)
        hold on; stem(t(max_idxs), y(max_idxs), 'c');
    end
    
    
    if (do_threshold)
        % Now we threshold based on the standard deviation.
        
        tidxs = find(y(max_idxs) > threshold); % stddevs cause zscore
        max_idxs = max_idxs(tidxs);
        if (do_debug)
            hold on; stem(t(max_idxs), y(max_idxs), 'k');
        end
    end
   
    
    % Remove any indexes that are bunched together too tightly.
    if (isempty(max_idxs))
        continue;
    end
    
    tt = zeros(1,length(y));
    tt(max_idxs) = 1;
    % Take a moving average and find the 0->1 transitions in this moving
    % average.
    do_first_edge = 0;
    do_max_in_conv = 1;
    if (do_first_edge)
        ttconv = conv(tt, ones(1, bunch_cutoff));
        ttconv_diff = diff(ttconv);
        ttconv_diff1_idxs = find(ttconv_diff == 1);
        ttconv_0_idxs = find(ttconv == 0);
        edge_idxs = intersect(ttconv_diff1_idxs, ttconv_0_idxs);
        edge_idxs = edge_idxs + 1;
        max_idxs = edge_idxs;
    
        max_len = length(max_idxs);
    end
    if (do_max_in_conv)
        ttconv = conv(tt, ones(1, bunch_cutoff));
        ttconv_0_idxs = find(ttconv == 0);
        ttconv_other_idxs = find(ttconv ~= 0);
        
        check_between_starts = ttconv_0_idxs(find(diff(ttconv_0_idxs) ~= 1));
        check_between_stops = intersect(ttconv_other_idxs+1, ttconv_0_idxs);
        % Now since we took the max of a smoothed signal, the maxes will probably
        % not match up with the maxes in the noisier data. Check the real data for
        % the max in about half the smoothing window length.
        w = round(windowlen/2);
    
        num_check_regions = length(check_between_starts);
        midx = 1;
        old_max_idxs = max_idxs;
        max_idxs = [];
        for nc = 1:num_check_regions
            pot_max_idxs = [check_between_starts(nc)-w:...
                            check_between_stops(nc)+w];
            pot_max_idxs(pot_max_idxs < 1) = [];
            pot_max_idxs(pot_max_idxs > len) = [];
            trace_piece = trace(pot_max_idxs);
            trace_max = max(trace_piece);
            trace_max = trace_max(1);
            trace_max_idx = find(trace_piece == trace_max);
            trace_max_idx = trace_max_idx(1);
            min_pot_max_idx = min(pot_max_idxs);
            min_pot_max_idx = min_pot_max_idx(1);
            max_idx = min(pot_max_idxs) + trace_max_idx - 1;
            max_idxs(midx) = max_idx;
            midx = midx+1;
        end        
    end
    if (do_debug)
        hold on; stem(t(max_idxs), y(max_idxs), 'y');
    end

    if (do_debug)        
        figure; plot(t, trace); hold on; stem(t(max_idxs), trace(max_idxs), 'r');
    end
    
    max_idxs = unique(max_idxs);
    
    % Single point events are now stored.
    onsets{cidx} = max_idxs;
    offsets{cidx} = max_idxs;
end