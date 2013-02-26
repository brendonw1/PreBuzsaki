if strcmp(get(det_view,'enable'),'off')
    for c = 1:length(handl)
        delete(handl{c});
    end
    cn = cell(1,length(region.name));
    centr = cell(1,length(region.name));
    areas = cell(1,length(region.name));
    handl = cell(1,length(region.name));
    set(det_view,'enable','on');
    
    thres = 10*ones(1,length(region.name));
    old_thres = inf*ones(1,length(region.name));
    lowar = zeros(1,length(region.name));
    highar = repmat(inf,1,length(region.name));
    pilim = 4*ones(1,length(region.name));
    isadjust = zeros(1,length(region.name));
    isdetected = zeros(1,length(region.name));
    ishid = 1;
    
    txlab = uicontrol('Style','text','Units','normalized','String',region.name{num},'Position',[.87 .49 .11 0.025],'FontSize',10,'FontWeight','Bold',...
        'BackgroundColor',cl(num,:));
    uicontrol('Style','text','Units','normalized','String','Cutoff','Position',[.87 .4625 .11 0.02],'FontSize',10,...
        'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
    txthres = uicontrol('Style','edit','Units','normalized','String',num2str(thres(num)),'Position',[.93 .46 .05 0.025],'FontSize',10,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
    uicontrol('Style','text','Units','normalized','String','Min area','Position',[.87 .4325 .11 0.02],'FontSize',10,...
        'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
    txarlow = uicontrol('Style','edit','Units','normalized','String',num2str(lowar(num)),'Position',[.93 .43 .05 0.025],'FontSize',10,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
    uicontrol('Style','text','Units','normalized','String','Max area','Position',[.87 .4025 .11 0.02],'FontSize',10,...
        'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
    txarhigh = uicontrol('Style','edit','Units','normalized','String',num2str(highar(num)),'Position',[.93 .40 .05 0.025],'FontSize',10,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
    
    cmnd = ['thres(num) = str2num(get(txthres,''string'')); lowar(num) = str2num(get(txarlow,''string'')); highar(num) = str2num(get(txarhigh,''string'')); pilim(num) = str2num(get(txpilim,''string''));'];
    btdetect = uicontrol('Style','pushbutton','Units','normalized','String','Detect!','Position',[.87 .355 .05 0.03],'FontSize',12,...
        'Callback',[cmnd 'HippoFindCells']);
    bthide = uicontrol('Style','pushbutton','Units','normalized','String','Hide','Position',[.93 .355 .05 0.03],'FontSize',12,...
        'Callback','ishid=1-ishid; HippoHide');
    
    uicontrol('Style','text','Units','normalized','String','Pi limit','Position',[.87 .3075 .11 0.02],'FontSize',10,...
        'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
    txpilim = uicontrol('Style','edit','Units','normalized','String',num2str(pilim(num)),'Position',[.93 .305 .05 0.025],'FontSize',10,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
    btfindbad = uicontrol('Style','pushbutton','Units','normalized','String','Find','Position',[.87 .26 .05 0.03],'FontSize',12,...
        'Callback','HippoFindBad');
    btadjust = uicontrol('Style','pushbutton','Units','normalized','String','Adjust','Position',[.93 .26 .05 0.03],'FontSize',12,...
        'Callback','HippoAdjust');
    
    btprev = uicontrol('Style','pushbutton','Units','normalized','String','<< Prev','Position',[.87 .205 .05 0.03],'FontSize',12,...
        'Callback',[cmnd 'ishid=1; HippoHide; num=mod(num+length(region.name)-2,length(region.name))+1; HippoInputParams;']);
    btnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .205 .05 0.03],'FontSize',12,...
        'Callback',[cmnd 'ishid=1; HippoHide; thres(num) = str2num(get(txthres,''string'')); num=mod(num,length(region.name))+1; HippoInputParams;']);
    
    btadd = uicontrol('Style','pushbutton','Units','normalized','String','Add','Position',[.87 .15 .05 0.03],'FontSize',12,...
        'Callback','HippoManualAdd');
    btdelete = uicontrol('Style','pushbutton','Units','normalized','String','Delete','Position',[.93 .15 .05 0.03],'FontSize',12,...
        'Callback','HippoManualDelete');
        
    btfinish = uicontrol('Style','pushbutton','Units','normalized','String','Finish','Position',[.93 .05 .05 0.03],'FontSize',12,...
        'Callback','HippoFinish');
    
else
    set(txlab,'String',region.name{num},'BackgroundColor',cl(num,:));
    set(txthres,'String',num2str(thres(num)));
    set(txarlow,'String',num2str(lowar(num)));
    set(txarhigh,'String',num2str(highar(num)));
    set(txpilim,'String',num2str(pilim(num)));
end