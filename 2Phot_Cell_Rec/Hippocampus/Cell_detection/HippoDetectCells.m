for c = 1:length(reg)
    region.name{c} = get(inpt(c),'String');
end

delete(txlab)
delete(inpt)
delete(bnext)

handl = {};

det_tx1 = uicontrol('Style','text','Units','normalized','String','Cell diameter','Position',[.87 .60 .11 0.02],'FontSize',10,...
    'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
det_diam = uicontrol('Style','edit','Units','normalized','String','12','Position',[.87 .57 .11 0.03],'FontSize',10,...
    'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
det_loc = uicontrol('Style','pushbutton','Units','normalized','String','Localize','Position',[.87 .535 .05 .03],'FontSize',12, ...
    'Callback','locdm = str2num(get(det_diam,''string'')); loca = HippoLocalize(a,locdm,gcf); num=1; set(det_view,''enable'',''off''); HippoInputParams;');
det_view = uicontrol('Style','pushbutton','Units','normalized','String','View','Position',[.93 .535 .05 .03],'FontSize',12, ...
    'Callback','HippoViewLoc','enable','off');