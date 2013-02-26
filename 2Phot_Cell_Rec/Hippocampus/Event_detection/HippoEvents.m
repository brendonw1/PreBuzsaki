clear;

opengl neverselect;
sz = get(0,'screensize');
fig = figure('Name','HippoEvents','NumberTitle','off','MenuBar','none','position',[1 0.15*sz(4) sz(3) 0.7*sz(4)],'doublebuffer','on');

[filename, pathname] = uigetfile({'*.mat'}, 'Choose data file to open');
if ~isstr(filename)
    delete(gcf)
    clear
end
fnm = [pathname filename];
load(fnm)

tr = region.traces;
nt = [];
for c = 1:size(tr,1)
    nt(c,:) = dfoverf(tr(c,:))*100;
end
spk = cell(1,size(nt,1));
dec = cell(1,size(nt,1)); 
xlimits = [0 size(nt,2)+1];

trax = subplot('position',[0.03 0.20 0.94 0.75]);
box on
set(gca,'buttondownfcn','hevZoom')

uicontrol('Style','text','Units','normalized','String','Cell #','Position',[.05 .05 .05 0.04],'FontSize',12,'FontWeight','Bold',...
    'HorizontalAlignment','right','BackgroundColor',[.8 .8 .8]);
txcellnum = uicontrol('Style','edit','Units','normalized','String','1','Position',[.11 .05 .05 0.04],'FontSize',12,'FontWeight','Bold',...
    'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback','hevPlotTrace');
bgoto = uicontrol('Style','pushbutton','Units','normalized','String','Go','Position',[.17 .05 .05 0.04],'FontSize',12,...
    'Callback','hevPlotTrace');

progtx = uicontrol('Style','text','Units','normalized','String','','Position',[.70 .05 .15 0.04],'FontSize',12,'FontWeight','Bold',...
    'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);

bdetect1 = uicontrol('Style','pushbutton','Units','normalized','String','Detect current','Position',[.30 .05 .08 0.04],'FontSize',12,...
    'Callback','[s d] = hippodettrial(tr(num,:)); spk{num} = s; dec{num} = d; hevPlotTrace;');
bdetect = uicontrol('Style','pushbutton','Units','normalized','String','Detect all','Position',[.40 .05 .08 0.04],'FontSize',12,...
    'Callback','for c = 1:size(tr,1); [s d] = hippodettrial(tr(c,:)); set(progtx,''String'',[''Detecting '' num2str(c) '' of '' num2str(size(nt,1))]); spk{c} = s; dec{c} = d; end; set(progtx,''String'',''''); hevPlotTrace;');
bdeleteall = uicontrol('Style','pushbutton','Units','normalized','String','Delete events','Position',[.50 .05 .08 0.04],'FontSize',12,...
    'Callback','spk{num} = []; dec{num} = []; hevPlotTrace;');
bsave = uicontrol('Style','pushbutton','Units','normalized','String','Save','Position',[.60 .05 .08 0.04],'FontSize',12,...
    'Callback','hevSave');

hevPlotTrace

