function [onsets, offsets, params] = ...
    ct_threshold(rastermap, handles, ridxs, clustered_contour_ids, options)
%-BW:2005/09/19
%Allows for a basic threshold-based signal detection.
%Takes the shown "clean" or "preprocessed" data from the gui.  
siglen=size(rastermap,2);
ampthresh=options.AmplitudeThreshold.value;
mintime=round(options.MinDuration.value/handles.exp.timeRes);
maxtime=round(options.MaxDuration.value/handles.exp.timeRes);
waithandle = waitbar(0,'Detecting signals');
for idx = 1:size(rastermap,1);%for each trace
    aboveperiods = continuousabove(rastermap(idx,:),zeros([1 siglen]),ampthresh,mintime,maxtime);
    if ~isempty(aboveperiods)
        onsets{idx} = aboveperiods(:,1);
        offsets{idx} = aboveperiods(:,2);
    else
        onsets{idx} = [];
        offsets{idx} = [];
    end
    waitbar(idx/size(rastermap,1), waithandle);
end
params.AmplitudeThreshold=options.AmplitudeThreshold.value;
params.MinDurationInSeconds=options.MinDuration.value;
params.MaxDurationInSeconds=options.MaxDuration.value;
delete(waithandle);
%%
function aboveperiods = continuousabove(data,baseline,abovethresh,mintime,maxtime);
% Finds periods in a linear trace that are above some baseline by some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.
above = find(data>=baseline+abovethresh);
% If only 1 potential event found
if (max(diff(diff(above))) == 0 & ...
    length(above) >= mintime & ...
    length(above) <= maxtime)
    aboveperiods = [above(1) above(end)];
% if many possible events
elseif (length(above) > 0)
    % find breaks between potential events
    ends = find(diff(above)~=1);
    % for the purposes of creating lengths of each potential event
    ends(end+1) = 0;
    % one of the ends comes at the last found point above baseline
    ends(end+1) = length(above);
    ends = sort(ends);
    % length of each potential event
    lengths = diff(ends);
    % must be longer than 500ms but shorter than 15sec
    good = find(lengths >= mintime & lengths <= maxtime);
    ends(1) = [];%lose the 0 added before
    e3 = reshape(above(ends(good)),[length(good) 1]);
    l3 = reshape(lengths(good)-1,[length(good) 1]);
    % event ends according to the averaged reading
    aboveperiods(:,2) = e3;
    % event beginnings according to averaged reading
    aboveperiods(:,1) = e3-l3;
else
    aboveperiods = [];
end