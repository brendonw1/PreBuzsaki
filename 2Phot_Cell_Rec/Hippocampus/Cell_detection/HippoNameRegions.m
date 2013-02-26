delete(bord_add);
delete(bord_edit);
delete(bord_delete);
delete(bnext);

for c = 1:length(reg)
    region.coords{c} = reg{c};
    txlab(c) = uicontrol('Style','text','Units','normalized','String',['Region ' num2str(c)],'Position',[.87 .60-(c-1)*.07 .11 0.025],'FontSize',10,...
        'HorizontalAlignment','left','BackgroundColor',cl(c,:));
    inpt(c) = uicontrol('Style','edit','Units','normalized','String',['Name ' num2str(c)],'Position',[.87 .60-(c-1)*.07-0.035 .11 0.03],'FontSize',10,...
        'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
end

bnext = uicontrol('Style','pushbutton','Units','normalized','String','Next >>','Position',[.93 .60-(length(reg)-1)*.07-0.1 .05 .03],'FontSize',12, ...
    'Enable','on','Callback','pi, HippoDetectCells');