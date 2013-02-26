function x = ct_dfof(x, options)
[nrecordings len] = size(x);
%means = mean(x,2);
%means_mat = repmat(means, [1 len]);
%x = 100*((x-means_mat)./means_mat);


time_res = options.timeRes.value;
% The start and stop idx are important because we want to get the
% quiet peroid.  F0 = Frest + Fback
% We'd like to get

% /\F / (Frest - Fback)
% where /\F = Fi - F0
%       

% so (Fi - (Frest + Fback)) / (Frest - Fback)

% I don't know how to measure Fback so if we assume it's zero, then
% we get

% (Fi - Frest)/Frest

start_idx = ceil(options.startTime.value/time_res);
stop_idx = floor(options.stopTime.value/time_res);

% BP
if (start_idx < 1)
    start_idx = 1;
    %warndlg('Starting index less than one. Please readsjust settings.');
end
if (stop_idx > len)
    stop_idx = len;
    %warndlg('Stop index is less than one. Please readjust settings.');
end

% for i = 1:nrecordings %loop slow... get rid... use repmat below
    % Get Frest.
    switch options.function.value
     case {'mean', 'MEAN'}
      norm_factor = mean(x(:,start_idx:stop_idx),2);
     case {'min', 'MIN'}
      norm_factor = min(x(:,start_idx:stop_idx),[],2);
     case {'max', 'MAX'}
      norm_factor = max(x(:,start_idx:stop_idx),[],2);
     case {'std', 'STD'}
      norm_factor = std(x(:,start_idx:stop_idx),1,2);
     otherwise
      warningdlg('Couldn''t understand function.  Using the mean.');
      norm_factor = mean(x(:,start_idx:stop_idx),2);
    end
    norm_factor = repmat(norm_factor,[1 len]);
%     norm_factor = norm_factor(1);
%     x(i,:) = (x(i,:) - norm_factor) / norm_factor;%not what people
%     usually use... change to simple division, below
    x = x ./ norm_factor;%simple ratio/percent change
% end
