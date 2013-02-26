function [zstack, param] = ct_standard_deviation(filename, pathname)
param.frameType = 'standard_deviation';

%[tc_average, param] = epo_average(filename, pathname);

fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);

%zstack = zeros(info(1).Height,info(1).Width);
%h = waitbar(0, 'Creating standard deviation zstack.  Please wait.');
%for c = 1:numframes
%    I = double(imread(fnm,c));   
%    zstack = zstack + (I-tc_average).^2;
%    waitbar(c/numframes);
%end
%close(h);
%zstack = zstack / numframes;


zstack = zeros(info(1).Height, info(1).Width);
zsum = zeros(info(1).Height, info(1).Width);
zsumsquared = zeros(info(1).Height, info(1).Width);
h = waitbar(0, 'Creating standard deviation zstack.  Please wait.');
N = numframes;
for c = 1:N
    I = double(imread(fnm,c));
    zsum = zsum + I;
    zsumsquared = zsumsquared + I.^2;
    waitbar(c/numframes);
end
close(h);
zstack = sqrt(1/N*zsumsquared-1/N^2*zsum.*zsum);
