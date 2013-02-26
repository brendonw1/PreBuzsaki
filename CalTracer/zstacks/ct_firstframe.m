function [zstack, param] = ct_firstframe(filename, pathname)
param.frameType = 'firstframe';

fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);
zstack = double(imread(fnm,1));