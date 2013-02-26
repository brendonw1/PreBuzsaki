function hippoprintout(fname)
% hippoprintout(fname)

spres = 0.6; %%% NEEDS CHANGE

load(fname,'region')

scrsize = get(0,'screensize');
set(gcf,'position',[scrsize(3)/2-8.5/11*0.86*scrsize(4)/2 0.07*scrsize(4) 8.5/11*0.86*scrsize(4) 0.86*scrsize(4)]);
set(gcf,'color',[1 1 1]);

f = strfind(fname,'.');
if isempty(f)
    str = fname;
else
    f = f(1);
    str = fname(1:f-1);
end

tmpres = str2num(str(7:end))/1000;  %%% NEEDS CHANGE

uicontrol('Style','text','units','normalized','string',str,'position',[.02 0.95 0.43 .05],'FontSize',14,'BackgroundColor',[1 1 1]);

cl = hsv(length(region.coords));

subplot('position',[0.02 0.75 0.43 0.195])
hold on
for c = 1:length(region.coords)
    patch(region.coords{c}(:,1),region.coords{c}(:,2),'w');
    ct = centroid(region.coords{c});
    tx = text(ct(1),ct(2),region.name{c});
    set(tx,'color',cl(c,:));
end
plot([region.imagesize(2)-15-100/spres region.imagesize(2)-15],[region.imagesize(1)-15 region.imagesize(1)-15],'-k','LineWidth',2)
xlim([0 region.imagesize(2)])
ylim([0 region.imagesize(1)])
axis equal
set(gca,'ydir','reverse');
axis off

subplot('position',[0.47 0.75 0.51 0.23])
hold on
for c = 1:length(region.contours)
    plot(region.contours{c}([1:end 1],1),region.contours{c}([1:end 1],2),'color',cl(region.location(c),:));
end
xlim([0 region.imagesize(2)])
ylim([0 region.imagesize(1)])
axis equal
axis tight
set(gca,'ydir','reverse','xtick',[],'ytick',[]);
box on

uicontrol('Style','text','units','normalized','string','Region','position',[.01 .7 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','Area (mm²)','position',[.21 .7 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','# Of cells','position',[.41 .7 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','Density (1/mm²)','position',[.61 .7 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','Cell size (µm²)','position',[.81 .7 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
subplot('position',[0 .69 1 .005])
plot(xlim,[0 0],'-k')
axis tight
axis off
for c = 1:length(region.contours)
    ars(c) = polyarea(region.contours{c}(:,1),region.contours{c}(:,2))*(spres^2);
end
for c = 1:length(region.coords)
    ar = polyarea(region.coords{c}(:,1),region.coords{c}(:,2))/10^6*(spres^2);
    ncells = length(find(region.location==c));
    dens = ncells/ar;
    tx(1) = uicontrol('Style','text','units','normalized','string',region.name{c},'position',[.01 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    tx(2) = uicontrol('Style','text','units','normalized','string',num2str(ar,'%6.3f'),'position',[.21 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    tx(3) = uicontrol('Style','text','units','normalized','string',num2str(ncells),'position',[.41 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    tx(4) = uicontrol('Style','text','units','normalized','string',num2str(round(dens)),'position',[.61 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    str = [num2str(round(mean(ars(find(region.location==c))))) '±' num2str(round(std(ars(find(region.location==c)))/sqrt(ncells))) ' (' num2str(round(min(ars(find(region.location==c))))) '-' num2str(round(max(ars(find(region.location==c))))) ')'];
    tx(5) = uicontrol('Style','text','units','normalized','string',str,'position',[.81 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    set(tx,'foregroundcolor',cl(c,:));
end

c = c+1;
ar = prod(region.imagesize)/10^6*(spres^2);
ncells = length(region.contours);
dens = ncells/ar;
uicontrol('Style','text','units','normalized','string','Total','position',[.01 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string',num2str(ar,'%6.3f'),'position',[.21 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string',num2str(ncells),'position',[.41 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string',num2str(round(dens)),'position',[.61 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
str = [num2str(round(mean(ars))) '±' num2str(round(std(ars)/sqrt(ncells))) ' (' num2str(round(min(ars))) '-' num2str(round(max(ars))) ')'];
uicontrol('Style','text','units','normalized','string',str,'position',[.81 .7-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
subplot('position',[0 .69-.03*c 1 .005])
plot(xlim,[0 0],'-k')
axis tight
axis off

pt = 0.65-0.03*c;
subplot('position',[0.08 pt-0.15 0.29 0.15])
s = rast2matdur(region.onsets,region.offsets,size(region.traces,2));
x = [0 reshape(repmat(1:size(s,2)-1,2,1),1,2*size(s,2)-2) size(s,2)];
x = [x fliplr(x)];
y = reshape(repmat(sum(s)/size(s,1)*100,2,1),1,2*size(s,2));
y = [y zeros(1,2*size(s,2))];
h = patch(x,y,[0 0 0.5]);
set(h,'edgecolor',[0 0 0.5]);
xlim([0 size(region.traces,2)])
set(gca,'xtick',[]);
title('Network activity','FontWeight','bold')
ylabel('% Of cells active')

subplot('position',[0.08 pt-0.3 0.29 0.15]);
hold on
for c = 1:length(region.contours)
    for d = 1:length(region.onsets{c})
        plot([region.onsets{c}(d):region.offsets{c}(d)],repmat(c,1,region.offsets{c}(d)-region.onsets{c}(d)+1),'color',cl(region.location(c),:));
    end
end
ylim([0 length(region.contours)+1]);
xlim([0 size(region.traces,2)]);
set(gca,'xtick',[]);
ylabel('Cell #')
set(gca,'ytick',(1:fix(length(region.contours)/100))*100)
set(gca,'ydir','reverse')
box on

subplot('position',[0.08 0.045 0.29 0.15]);
nt = dfoverf(region.traces);
imagesc(nt)
set(gca,'xtick',[]);
ylabel('Cell #')
set(gca,'ytick',[1 (1:fix(length(region.contours)/100))*100])
set(gca,'ydir','reverse')
set(gca,'xtick',[1 size(nt,2)]);
mins = fix(size(nt,2)*tmpres/60);
secs = fix(size(nt,2)*tmpres - fix(size(nt,2)*tmpres/60)*60);
if secs == 0
    str = '00';
elseif secs < 10
    str = ['0' num2str(secs)];
else
    str = num2str(secs);
end
set(gca,'xticklabel',{'0', [num2str(mins) ':' str]});
box on
xlabel('Time (min)')

subplot('position',[0.5 pt-0.16 0.25 0.16])
k = 1000*ones(length(region.onsets),71);
for c = 1:length(region.onsets)
    for d = region.onsets{c}
        strp = max([1 d-10 max(region.offsets{c}(find(region.offsets{c}<d)))]);
        endp = min([size(nt,2) d+60 min(region.onsets{c}(find(region.onsets{c}>d)))]);
        k(c,11-(d-strp):11+(endp-d)) = nt(c,strp:endp);
    end
end
mk = zeros(1,71);
for c = 1:71
    mk(c) = mean(k(find(k(:,c)<1000),c));
end
plot(mk,'linewidth',1.5)

[mn i] = min(mk(11:end));
rt = -mk(i+10:end);
mn = min(rt);
rt = rt-mn;
f = find(rt>0);
rt = rt(f);
rt = log(rt);
m = [f' ones(length(f),1)]\rt';
hold on;
plot(i+10:71,-mn-exp(m(2))*exp(m(1)*(1:62-i)),'-r','Linewidth',1);

axis tight
set(gca,'xtick',[],'ytick',[],'xcolor',[1 1 1],'ycolor',[1 1 1]);
title('Average signal','FontWeight','bold')

ps = zeros(size(k,1),1);
mn = 1000*ones(size(k,1),1);
for c = 1:size(k,1)
    f = find(k(c,2:end-1)<k(c,1:end-2) & k(c,2:end-1)<=k(c,3:end))+1;
    f = f(find(f>11));
    f = f(find(k(c,f)<1000));
    if ~isempty(f)
        ps(c) = f(1);
        mn(c) = k(c,ps(c));
    end
end
    
uicontrol('Style','text','units','normalized','string','Amplitude (DF/F)','position',[.8 pt-0.01 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
f = find(ps>0 & k(:,11)<1000);
mn = (k(f,11)-mn(f))*100;
str = [num2str(mean(mn),'%6.1f') '±' num2str(std(mn)/sqrt(length(mn)),'%6.1f') '%'];
uicontrol('Style','text','units','normalized','string',str,'position',[.8 pt-0.035 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1],'Foregroundcolor',[0 0 1]);

uicontrol('Style','text','units','normalized','string','Onset (ms)','position',[.8 pt-0.07 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
ton = (ps(f)-11)*tmpres*1000;
str = [num2str(round(mean(ton))) '±' num2str(round(std(ton)/sqrt(length(ton))))];
uicontrol('Style','text','units','normalized','string',str,'position',[.8 pt-0.095 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1],'Foregroundcolor',[0 0 1]);

uicontrol('Style','text','units','normalized','string','Tau (sec)','position',[.8 pt-0.13 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
str = num2str(-tmpres/m(1),'%6.2f');
uicontrol('Style','text','units','normalized','string',str,'position',[.8 pt-0.155 .15 .02],'FontSize',12,'BackgroundColor',[1 1 1],'Foregroundcolor',[0 0 1]);

uicontrol('Style','text','units','normalized','string','% Active','position',[.41 pt-0.2 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','Frequency (mHz)','position',[.61 pt-0.2 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
uicontrol('Style','text','units','normalized','string','Duration (sec)','position',[.81 pt-0.2 .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
subplot('position',[0.40 pt-0.21 0.60 .005])
plot(xlim,[0 0],'-k')
axis tight
axis off
s = rast2mat(region.onsets,size(nt,2));
for c = 1:length(region.coords)
    f = find(region.location==c);
    actv = sum(s(f,:),2);
    pact = length(find(actv>0))/length(f)*100;
    tx(1) = uicontrol('Style','text','units','normalized','string',num2str(round(pact)),'position',[.41 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    actv = actv/(size(nt,2)*tmpres);
    actv = actv(find(actv>0))*1000;
    str = [num2str(round(mean(actv))) '±' num2str(round(std(actv)/sqrt(length(actv)))) ' (' num2str(round(min(actv))) '-' num2str(round(max(actv))) ')'];
    tx(2) = uicontrol('Style','text','units','normalized','string',str,'position',[.61 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    dur = [];
    for d = f
        dur = [dur region.offsets{d}-region.onsets{d}];
    end
    dur = dur*tmpres;
    str = [num2str(mean(dur),'%6.2f') '±' num2str(std(dur)/sqrt(length(f)),'%6.2f') ' (' num2str(min(dur),'%6.1f') '-' num2str(max(dur),'%6.1f') ')'];
    tx(3) = uicontrol('Style','text','units','normalized','string',str,'position',[.81 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
    set(tx,'foregroundcolor',cl(c,:));
end
c = c+1;
actv = sum(s,2);
pact = length(find(actv>0))/size(s,1)*100;
uicontrol('Style','text','units','normalized','string',mean(round(pact)),'position',[.41 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
actv = actv/(size(nt,2)*tmpres);
actv = actv(find(actv>0))*1000;
str = [num2str(round(mean(actv))) '±' num2str(round(std(actv)/sqrt(length(actv)))) ' (' num2str(round(min(actv))) '-' num2str(round(max(actv))) ')'];
uicontrol('Style','text','units','normalized','string',str,'position',[.61 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
dur = [];
mxdur = zeros(1,length(region.contours));
mndur = zeros(1,length(region.contours));
for d = 1:length(region.contours)
    dur = [dur region.offsets{d}-region.onsets{d}];
    if ~isempty(region.offsets{d})
        mxdur(d) = max(region.offsets{d}-region.onsets{d});
        totdur(d) = sum(region.offsets{d}-region.onsets{d});
    end
end
dur = dur*tmpres;
str = [num2str(mean(dur),'%6.2f') '±' num2str(std(dur)/sqrt(length(dur)),'%6.2f') ' (' num2str(min(dur),'%6.1f') '-' num2str(max(dur),'%6.1f') ')'];
uicontrol('Style','text','units','normalized','string',str,'position',[.81 pt-0.2-.03*c .18 .02],'FontSize',12,'BackgroundColor',[1 1 1]);
subplot('position',[0.40 pt-0.21-0.03*c 0.60 .005])
plot(xlim,[0 0],'-k')
axis tight
axis off

sdur = rast2matdur(region.onsets,region.offsets,size(nt,2));
mxdur(find(sdur(:,size(nt,2))==1)) = 0;
[mx ilong] = max(mxdur);
[mx imax] = max(sum(s,2));
indx = abs(totdur-size(nt,2)/5);
indx(find(sum(s,2)<10))=inf;
[mx iavg] = min(indx);

subplot('position',[0.41 0.01 0.18 0.10]);
plot(nt(ilong,:))
xlim([1 size(nt,2)]);
ylim([min(nt(ilong,:))*1.05 max(nt(ilong,:))]);
set(gca,'xtick',[],'ytick',[]);
box off

subplot('position',[0.61 0.01 0.18 0.10]);
plot(nt(imax,:))
xlim([1 size(nt,2)]);
ylim([min(nt(imax,:))*1.05 max(nt(imax,:))]);
set(gca,'xtick',[],'ytick',[]);
title('Examples','FontWeight','bold')
box off

subplot('position',[0.81 0.01 0.18 0.10]);
plot(nt(iavg,:))
xlim([1 size(nt,2)]);
ylim([min(nt(iavg,:))*1.05 max(nt(iavg,:))]);
set(gca,'xtick',[],'ytick',[]);
box off

set(gcf,'papertype','A4');
set(gcf,'paperunits','normalized');
set(gcf,'paperposition',[0.05 .05 .90 .90]);

bprint = uicontrol('Style','pushbutton','Units','normalized','String','Print!','Position',[0 0.97 .10 0.03],'FontSize',12,...
    'Callback','set(findobj(''style'',''pushbutton''),''visible'',''off''); printdlg(gcf); set(findobj(''style'',''pushbutton''),''visible'',''on'');');