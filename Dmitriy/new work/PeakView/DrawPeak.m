%Draws the selected peak

subplot('position',[0.0725+2*0.9275/3 0.05 0.9275/3 0.4])
title(['Histogram (threshold = ' num2str(th) ' contours)']);

if size(tpk,2) == 0
    return
end

for c = 1:size(tpk,2)
    set(pbut(c),'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);
    set(tx(c),'color',[0 0 0]);
end
set(pbut(n),'backgroundcolor',[0 0 0.75],'foregroundcolor',[1 1 1]);
set(tx(n),'color',[1 0 0]);

subplot('position',[0.0725 0.5 0.9275/3 0.4])
title(['Automatic (' num2str(sum(s(:,tpk(n)))) ' contours)']);
if curr > 0
    set(ha{curr},'color',[0 0 0],'linewidth',1);
end
set(ha{n},'color',[1 0 0],'linewidth',2);

if curr > 0
    rcurr = find(pk==tpk(curr));
end
if isempty(rcurr)
    rcurr = 0;
end

if rcurr > 0
    set(hd{rcurr},'color',[0 0 0],'linewidth',1);
end
if rcurr > 0
    set(hr{rcurr},'color',[0 0 0],'linewidth',1);
end
if rcurr > 0
    set(hi{rcurr},'color',[0 0 0],'linewidth',1);
end
if rcurr > 0
    set(hu{rcurr},'color',[0 0 0],'linewidth',1);
end

if ~isempty(find(pk==tpk(n)))
    
    rn = find(pk==tpk(n));
    
    subplot('position',[0.0725+1*0.9275/3 0.5 0.9275/3 0.4])
    title(['Dmitriy (' num2str(size(md{rn},1)) ' contours)']);
    set(hd{rn},'color',[1 0 0],'linewidth',2);
    
    subplot('position',[0.0725+2*0.9275/3 0.5 0.9275/3 0.4])
    title(['Rosa (' num2str(size(mr{rn},1)) ' contours)']);
    set(hr{rn},'color',[1 0 0],'linewidth',2);
    
    subplot('position',[0.0725 0.05 0.9275/3 0.4])
    title(['Intersection (' num2str(size(intersect(md{rn},mr{rn}),1)) ' contours)']);
    set(hi{rn},'color',[1 0 0],'linewidth',2);
    
    subplot('position',[0.0725+1*0.9275/3 0.05 0.9275/3 0.4])
    title(['Union (' num2str(size(union(md{rn},mr{rn}),1)) ' contours)']);
    set(hu{rn},'color',[1 0 0],'linewidth',2);
    
else
    subplot('position',[0.0725+1*0.9275/3 0.5 0.9275/3 0.4])
    title(['Dmitriy (not done)']);
    subplot('position',[0.0725+2*0.9275/3 0.5 0.9275/3 0.4])
    title(['Rosa (not done)']);
    subplot('position',[0.0725 0.05 0.9275/3 0.4])
    title(['Intersection (not done)']);
    subplot('position',[0.0725+1*0.9275/3 0.05 0.9275/3 0.4])
    title(['Union (not done)']);
end

curr = n;