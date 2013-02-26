delete(bnext);
set(bopenimage,'enable','off');

%Contour functions
bord_title = uicontrol('Style','text','Units','normalized','String','Regions','Position',[.87 .755 .11 0.025],'FontSize',12,'FontWeight','Bold','BackgroundColor',[.8 .8 .8]);
bord_add = uicontrol('Style','pushbutton','Units','normalized','String','Add','Position',[.90 .595 .05 .03],'FontSize',12, ...
    'Enable','on','Callback','HippoAddBorder');
bord_edit = uicontrol('Style','pushbutton','Units','normalized','String','Edit','Position',[.90 .555 .05 .03],'FontSize',12, ...
    'Enable','off');
bord_delete = uicontrol('Style','pushbutton','Units','normalized','String','Delete','Position',[.90 .515 .05 .03],'FontSize',12, ...
    'Enable','off','Callback','HippoDeleteBorder');
bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .415 .05 .03],'FontSize',12, ...
    'Enable','on','Callback','HippoNameRegions');

%Initial info
bord = [];
bhand = [];

HippoDetermineRegions