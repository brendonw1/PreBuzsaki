hold off
num = str2num(get(txcellnum,'string'));
if isempty(num)
    return
end
if num < 1
    num = size(nt,1);
    set(txcellnum,'string',num2str(num));
end
if num > size(nt,1)
    num = 1;
    set(txcellnum,'string',num2str(num));
end

trmenu = uicontextmenu;
uimenu(trmenu, 'Label', 'Add event', 'Callback', 'hevAddEvent');
plot(nt(num,:),'uicontextmenu',trmenu)

hold on
cmenu = [];
coffmenu = [];
for c = 1:length(spk{num})
    cmenu(c) = uicontextmenu;
    uimenu(cmenu(c), 'Label', 'Delete event', 'Callback', ['selev = ' num2str(c) '; hevDeleteEvent;']);
    uimenu(cmenu(c), 'Label', 'Move onset', 'Callback', ['selev = ' num2str(c) '; hevMoveEvent;']);
    if c > 1
        uimenu(cmenu(c), 'Label', 'Combine with previous', 'Callback', ['selev = ' num2str(c) '; hevCombineEvent;']);
    end
    h = plot(spk{num}(c),nt(num,spk{num}(c)),'or','uicontextmenu',cmenu(c));
    
    coffmenu(c) = uicontextmenu;
    uimenu(coffmenu(c), 'Label', 'Move offset', 'Callback', ['selev = ' num2str(c) '; hevMoveEventOff;']);
    plot(dec{num}(c),nt(num,dec{num}(c)),'og','uicontextmenu',coffmenu(c));
end

xlim(xlimits);

set(gca,'buttondownfcn','hevZoom')
set(gcf,'KeyPressFcn','hevButtonDown')
%zoom on