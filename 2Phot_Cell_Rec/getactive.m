function cells=getactive(filename);

[spk,tr,cn]=bprintout(filename);%determine potentially spiking cells
figure;
bar(sum(spk));%plot active cells per frame
set(gcf,'position',[5 500 1275 450])%make window a wide window across top of monitor
title('Click left and right bounds of frames of interest');%add title
[framenum,trash]=ginput(2);%record two points (only care about x values)
framenum=round(framenum);%round x values, these indicate the first and last frames to be analyzed
framenum=framenum(1):framenum(end);%create an integer sequence of the first frame number to the last

% framenum=input('Which frame are you interested in seeing? ');
cells=blookthru(tr,spk,framenum);%display potentially active cells for evaluation
figure;
tphighlightons(cn,cells);%show active cells

ons=spk;%rename
eval(['save ',filename,' framenum cells ons tr cn']);%save potential spikes to disk along with other variables
