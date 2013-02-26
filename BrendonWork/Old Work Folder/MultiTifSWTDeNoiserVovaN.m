% 
% * @author Volodymyr Nikolenko 
% * Department of Biological Sciences, Columbia University
% * @version 0.10
% */
% clear all;
fnm=input('File name ? (in multi tif-format 16-bit) ');
startframe=input('Start frame ? ');
lastframe=input('Number of the last frame to process ? ');
% mkdir('Raw2matsOutput');
for Frame=startframe:lastframe;
    x = imread(fnm, 'tif', Frame);
    x = double(x);
    [thr,sorh,keepapp] = ddencmp('den','wv',x);
    [swa,swh,swv,swd] = swt2(x,4,'sym6');
    dswh = wthresh(swh,sorh,thr);
    dswv = wthresh(swv,sorh,thr);
    dswd = wthresh(swd,sorh,thr);
    xd = iswt2(swa,dswh,dswv,dswd,'sym6');
    xd = uint16(round(xd));
    fout = strcat(fnm, '_denoisedSWT.tif');
    imwrite(xd, fout, 'tif','Compression','none','WriteMode','append');
    Frame
    % cd ..;
end;
clear all;