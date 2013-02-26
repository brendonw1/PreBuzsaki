function filtered = bwbpimage2(img, small, big)
% bpimage2
% 
% Filter the image according to a bandpass filter arranged around the size
% of the neurons we are trying to find.
% mpp is pixels per micron.
% Search for neurons of size diameter, allowing for a range of frequencies
% of range.
% Cell might be diameter=25 at 40X range~=10 and mpp=5



% The length of the filter.  I was under the impression that this would
% only make the filter better to increase this, but it also seems to change
% things in a qualitative way.  Have to get back to this.
firlen = 100;

% Compute the normalized frequency values based on 
% the type of data itself.
%mpp = 5;    %microns per pixel
maxfreq = size(img, 1);
minfreq = 2;    % two pixels
% dp = diameter  / mpp;     % Compute the diameter in pixels.
% rp = range / mpp;      % 10 microns divided by pixels.
% How to relate the diameter in pixels to the normalized freqency?

% Let's say the maximum frequency is 1 and the minimum is zero.
bigfreq = 1 / (big); 
smallfreq = 1 / (small);

% These are the good test values.
%bigfreq = 0.1;
%wc_h = 0.3;


% So the maximum frequency we can detect is.

[f1,f2] = freqspace(firlen,'meshgrid');
% imagesc(f1);
% pause;
% imagesc(f2);
% pause;
Hd = ones(firlen); 
r = sqrt(f1.^2 + f2.^2);        % make a circle.
% imagesc(r);
% pause;
Hd((r<bigfreq)|(r>smallfreq)) = 0;        % make a dougnut.
h = fwind1(Hd,hamming(firlen)); % create a smooth filter from the doughnut.

% Create the filtered image by convolving the filter with the original.
filtered = filter2(h, img, 'same');
% figure;imagesc(filtered);