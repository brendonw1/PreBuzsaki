function [zstack, param] = ct_average_nframes(filename, pathname)
% function [zstack, param] = ct_average_nframes(filename, pathname)
% Average the first n frames.

param.frameType = 'average_nframes';
fnm = [pathname filename];
info = imfinfo(fnm);
numframes = length(info);

prompt = {'How many frames should be averaged (starting from 1):'};
def = {'100'};
dlgTitle = 'Average N frames.';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    errordlg('You must enter a valid number.');
    return;
end
nframes = str2num(answer{1});
if (nframes < 1)
    errordlg('You must enter a valid number.');
    return;
end
if (nframes > numframes)
    nframes = numframes;
end

zstack = zeros(info(1).Height,info(1).Width);
h = waitbar(0, 'Creating average zstack.  Please wait.');
for c = 1:nframes
    zstack = zstack + double(imread(fnm,c));
    waitbar(c/nframes);
end
close(h);
zstack = zstack / nframes;