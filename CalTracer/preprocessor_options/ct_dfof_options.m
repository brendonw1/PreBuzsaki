function options = ct_dfof_options
%options = struct;

options.startTime.value = 0;		% intentionally 0
options.stopTime.value = .5;		% intentionally large

options.function.prompt = 'Enter the function used on data (min|max|mean|std).';
options.function.value = 'mean';

options.startTime.prompt = 'Enter the start time for the baseline period.';
options.stopTime.prompt = 'Enter the stop time for the baseline period.';