clear;

opengl neverselect;
fig = figure('Name','Hippo','NumberTitle','off','MenuBar','none','doublebuffer','on','units','normalized');
set(fig,'position',[0 .08/3 1 2.86/3]);

%Image functions
uicontrol('Style','text','Units','normalized','String','Image','Position',[.87 .955 .11 0.025],'FontSize',12,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
bopenimage = uicontrol('Style','pushbutton','Units','normalized','String','Open','Position',[.87 .91 .05 .03],'FontSize',12, ...
    'Callback','HippoOpenImage');
bzoom = uicontrol('Style','pushbutton','Units','normalized','String','Zoom','Position',[.93 .91 .05 .03],'FontSize',12, ...
    'Callback','zoom on','Enable','off');
uicontrol('Style','text','units','normalized','string','Brightness','position',[.87 .88 .11 .02],'FontSize',12,'BackgroundColor',[.8 .8 .8]);
bbright = uicontrol('Style','slider','Units','normalized','Position',[.87 .86 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','off','Callback','HippoContrast');
uicontrol('Style','text','units','normalized','string','Contrast','position',[.87 .83 .11 .02],'FontSize',12,'BackgroundColor',[.8 .8 .8]);
bcontrast = uicontrol('Style','slider','Units','normalized','Position',[.87 .81 .11 .02],'Min',0,'Max',1,'Sliderstep',[.01 .05],'Value',1/3, ...
    'Enable','off','Callback','HippoContrast');

bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .71 .05 .03],'FontSize',12, ...
    'Enable','off','Callback','HippoDefineBorders');