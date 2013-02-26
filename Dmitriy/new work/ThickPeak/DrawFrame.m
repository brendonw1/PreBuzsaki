set(pslide,'value',round(get(pslide,'value')));

if ~isempty(tpk)
    fr = tpk(get(ppopup,'value')) + get(pslide,'value');
    if fr < 1
        fr = 1;
        set(pslide,'value',1-tpk(get(ppopup,'value')));
    end
    if fr > size(s,2)
        fr = size(s,2);
        set(pslide,'value',size(s,2)-tpk(get(ppopup,'value')));
    end
    
    set(tx,'string',num2str(get(pslide,'value')));
    
    set(h,'Color',[0 0 0],'linewidth',1);
    f = find(s(:,fr)==1);
    set(h(f),'Color',[1 0 0],'linewidth',2);
end