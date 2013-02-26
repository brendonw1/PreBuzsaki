%Loads a peak file

for c = 1:size(pk,2)
    delete(pbut(c));
end

n = get(fmenu,'value');
load(mt(n).name);

for c = 1:size(tpk,2)
    st = [num2str(tpk(c)) ' (-' num2str(wd(c,1)) ', +' num2str(wd(c,2)) ')'];
    pbut(c) = uicontrol('style','pushbutton','units','normalized','string',st,'callback',['n=' num2str(c) '; DrawPeak'],'fontweight','bold',...
        'position',[0.075+(c-1)*0.925/size(tpk,2) 0.95 0.925/size(tpk,2) 0.05]);
end

subplot('position',[0.0725 0.05 0.9275 0.9]);
delete(gca);

warning off

s = rast2mat(spk,sz);
subplot('position',[0.0725 0.5 0.9275/3 0.4])
hold on;
ha = cell(1,size(tpk,2));
for c = 1:size(cn,2)
    h = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
    for d = 1:size(tpk,2)
        if s(c,tpk(d))==1
            ha{d} = [ha{d} h];
        end
    end
end
set(gca,'xtick',[],'ytick',[],'ydir','reverse');
title('Automatic')
axis equal
box on

subplot('position',[0.0725+1*0.9275/3 0.5 0.9275/3 0.4])
hold on;
hd = cell(1,size(pk,2));
dd = zeros(1,size(cn,2));
for c = 1:size(cn,2)
    h = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
    dd(c) = h;
    for d = 1:size(pk,2)
        if ~isempty(find(md{d}==c))
            hd{d} = [hd{d} h];
        end
    end
end
set(gca,'xtick',[],'ytick',[],'ydir','reverse');
title('Dmitriy')
axis equal
box on

subplot('position',[0.0725+2*0.9275/3 0.5 0.9275/3 0.4])
hold on;
hr = cell(1,size(pk,2));
rr = zeros(1,size(cn,2));
for c = 1:size(cn,2)
    h = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
    rr(c) = h;
    for d = 1:size(pk,2)
        if ~isempty(find(mr{d}==c))
            hr{d} = [hr{d} h];
        end
    end
end
set(gca,'xtick',[],'ytick',[],'ydir','reverse');
title('Rosa')
axis equal
box on

subplot('position',[0.0725 0.05 0.9275/3 0.4])
hold on;
hi = cell(1,size(pk,2));
ii = zeros(1,size(cn,2));
for c = 1:size(cn,2)
    h = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
    ii(c) = h;
    for d = 1:size(pk,2)
        if ~isempty(find(intersect(md{d},mr{d})==c))
            hi{d} = [hi{d} h];
        end
    end
end
set(gca,'xtick',[],'ytick',[],'ydir','reverse');
title('Intersection')
axis equal
box on

subplot('position',[0.0725+1*0.9275/3 0.05 0.9275/3 0.4])
hold on;
hu = cell(1,size(pk,2));
uu = zeros(1,size(cn,2));
for c = 1:size(cn,2)
    h = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
    uu(c) = h;
    for d = 1:size(pk,2)
        if ~isempty(find(union(md{d},mr{d})==c))
            hu{d} = [hu{d} h];
        end
    end
end
set(gca,'xtick',[],'ytick',[],'ydir','reverse');
title('Union')
axis equal
box on

subplot('position',[0.0725+2*0.9275/3 0.05 0.9275/3 0.4])
hold on
hst = bar(sum(s));
set(hst,'edgecolor',[0 0 1],'facecolor',[0 0 1]);
xlim([-10 size(s,2)+10]);
ylim([0 max(sum(s))*1.1]);
set(gca,'xtick',[],'ytick',[]);
title('Histogram')
plot(xlim,[th th],':r');
for c = 1:size(tpk,2)
    if isempty(find(pk==tpk(c)))
        st = 'o';
        si = 10;
    else
        st = '*';
        si = 16;
    end
    tx(c) = text(tpk(c),sum(s(:,tpk(c)))+0.05*range(ylim),st,'color',[0 0 0],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',si);
end
box on

warning on

rcurr = 0; curr = 0; n = 1; DrawPeak