function [zstack, param] = ct_average(filename, pathname)
param.frameType = 'average';

fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);
zstack = zeros(info(1).Height,info(1).Width);
h = waitbar(0, 'Creating average zstack.  Please wait.');
for c = 1:numframes
    zstack = zstack + double(imread(fnm,c));
    waitbar(c/numframes);
end
close(h);
zstack = zstack / numframes;