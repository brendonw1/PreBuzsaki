function [zstack, param] = ct_maximum(filename, pathname)
param.frameType = 'maximum';

fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);
zstack = uint16(zeros(info(1).Height,info(1).Width,2));
h = waitbar(0, 'Creating maximum zstack.  Please wait.');
for c = 1:numframes    
    waitbar(c/numframes);
    zstack(:,:,2) = imread(fnm,c);
    zstack(:,:,1) = max(zstack,[],3);    
end
close(h);
zstack = double(zstack(:,:,1));