function [zstack, param] = ct_average_10frames(filename, pathname)
% function [zstack, param] = ct_average_nframes(filename, pathname)
% Average the first n frames.

param.frameType = 'average_10frames';
fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);

nframes=min([numframes 10]);%number to be averaged

zstack = zeros(info(1).Height,info(1).Width);
h = waitbar(0, 'Creating average zstack.  Please wait.');
for c = 1:nframes
    zstack = zstack + double(imread(fnm,c));
    waitbar(c/nframes);
end
close(h);
zstack = zstack / nframes;