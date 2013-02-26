fig = figure('Name','PeakView','NumberTitle','off','MenuBar','none','position',[1 31 1280 968]);

warning off

godesk
cd analysis

ispk = [];
iscontrol = [];
mt = dir('*mat');
for c = 1:size(mt,1)
    blocker = 'Nah-nah-nah';
    load(mt(c).name);
    ispks(c) = ispk;
    iscontrol(c) = strcmp(blocker,'Control');
end
mt = mt(intersect(find(ispks==1),find(iscontrol==1)));

st = mt(1).name(1:8);
for c = 2:size(mt,1)
    st = [st '|' mt(c).name(1:8)];
end

pk = [];
arlim = 5;

fmenu = uicontrol('Style','listbox','units','normalized','string',st,'position',[0 0 .075 1],'fontsize',11,'callback','loadpeaks');
LoadPeaks