function options = ct_threshold_options(handles)
% function options = ct_threshold_options(handles)
% The options below will be used by
% user_check_options to create a dialogbox to get user input.
% Use preprocessed signals by not making field options.preprocessStrings
%find out whether "ct_threshold" was done before on this experiment
for idx=1:size(handles.exp.detections,2);
    match(idx)=strcmpi('ct_threshold',handles.exp.detections(idx).detectorName);
end
options = struct;
if sum(match)>0;
    match=find(match);
    %if was done before, find the index number of the most recent such
    %detection
    match=max(match);
    options.AmplitudeThreshold.value=handles.exp.detections(match).params.AmplitudeThreshold;
    options.MinDuration.value=handles.exp.detections(match).params.MinDurationInSeconds;
    options.MaxDuration.value=handles.exp.detections(match).params.MaxDurationInSeconds;
else
    options.AmplitudeThreshold.value=1;
    options.MinDuration.value=handles.exp.timeRes;
    options.MaxDuration.value=Inf;
end
options.AmplitudeThreshold.prompt = 'Minimum value of a signal.';
options.MinDuration.prompt = 'Minimum duration of a signal (in seconds).';
options.MaxDuration.prompt = 'Maximum duration of a signal (in seconds).';