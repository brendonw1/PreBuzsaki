fig = figure('Name','ThickPeak','NumberTitle','off','MenuBar','none','position',[258 235 734 615]);

warning off

godesk
load movies/peaks.mat
cd analysis
mt = dir('*mat');
if not(size(mt,1)==size(isp,2))
    isp = zeros(1,size(mt,1));
    for c = 1:size(mt,1)
        load(mt(c).name);
        isp(c) = ispeak;
    end
end
save ../movies/peaks.mat isp
mt = mt(find(isp==1));

st = mt(1).name(1:8);
for c = 2:size(mt,1)
    st = [st '|' mt(c).name(1:8)];
end

fmenu = uicontrol('Style','listbox','units','normalized','string',st,'position',[0 0 .125 1],'fontsize',11,'callback','LoadThick');
tx = uicontrol('Style','text','units','normalized','string','0','position',[0.2 0.94 0.05 0.035],'fontsize',13,'backgroundcolor',[0.8 0.8 0.8],...
    'horizontalalignment','left');
pslide = uicontrol('Style','slider','units','normalized','position',[0.25 0.94 0.5 0.035],'SliderStep',[1/10 1/10],'Min',-5,'Max',5,'callback','DrawFrame',...
    'BackgroundColor',[0 0.6 0.8]);
ppopup = uicontrol('Style','popupmenu','units','normalized','position',[0.8 0.925 0.15 0.05],'string','','fontsize',11,'Callback','DrawFrame');

LoadThick