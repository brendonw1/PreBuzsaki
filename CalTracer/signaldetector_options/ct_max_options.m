function options = ct_max_options(handles);
options = struct;
options.preprocessStrings{1} = 'halo_subtract';
options.preprocessStrings{2} = 'zscore';
options.preprocessStrings{3} = 'moving_average';

options.preprocessOptions{1} = {};
options.preprocessOptions{2} = {};
options.preprocessOptions{3} = {'windowLength', 10, 'window', 'rectwin'};

% Particular options for the signal detection routine, seperate from
% those that are fed to the preprocessor.  These options take exactly
% the same format as the preprocessor options for continuity.

options.threshold.value = 1;
options.threshold.prompt = 'Number of standard deviations above which the max must be.';

options.bunchCutoff.value = 1;
options.bunchCutoff.prompt = ...
    ['How many seconds between each max (on average).'];
