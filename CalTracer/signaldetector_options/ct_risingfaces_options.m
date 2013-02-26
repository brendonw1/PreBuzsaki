function options = ct_risingfaces_options(handles);
% Use preprocessed signals by not making field options.preprocessStrings
% The options below will be used by
% user_check_options to create a dialogbox to get user input.
% Use preprocessed signals by not making field options.preprocessStrings
%find out whether "ct_detectspikesintegrals" was done before on this experiment

options = struct;

options.preprocessStrings{1} = 'dfof';
options.preprocessStrings{2} = 'halo_subtract';
options.preprocessStrings{3} = 'baseline_subtract';

for idx=1:size(handles.exp.detections,2);
    match(idx)=strcmpi('ct_risingfaces',handles.exp.detections(idx).detectorName);
end
options = struct;
if sum(match)>0;
    match=find(match);
    %if was done before, find the index number of the most recent such
    %detection
    match=max(match);
    options.RiseIntegralHardThreshLo.value = handles.exp.detections(match).params.RiseIntegralHardThreshLo;
    options.RiseIntegralTimesNoise.value = handles.exp.detections(match).params.RiseIntegralTimesNoise;
    options.BasicFiltLenInSec.value = handles.exp.detections(match).params.BasicFiltLenInSec;
else
    options.RiseIntegralHardThreshLo.value = .01;
    options.RiseIntegralTimesNoise.value = 3;
    options.BasicFiltLenInSec.value = .2;%200ms = default)
end

options.RiseIntegralHardThreshLo.prompt = 'Minimum size of a signal in df units';
options.RiseIntegralTimesNoise.prompt = 'Minimum amount times noise a signal must be';
options.BasicFiltLenInSec.prompt = 'Filter length in seconds';
% ask 
% use current preprocessing or use default preprocessing(dfoverf,
% halo_subtract, baseline_subtract)