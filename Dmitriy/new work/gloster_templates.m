function gloster_templates(fin,num)
%gloster_templates(fin,num)
%   prints out a figure for the numth template in file fin

fld = pwd;

set(gcf,'position',[280    43   727   901]);

fid = fopen(fin);

fname = fgetl(fid);
tempr = str2num(fname(7:8))/10;

for c = 1:3
    dummy = fgetl(fid);
end

for c = 1:num-1
    dummy = fgetl(fid);
end

k = str2num(fgetl(fid));

pk = 1000;
godesk
cd analysis
load(fname(1:8));

subplot(5,3,10);
bar(sum(s)/size(ar,2)*100);
box off;
hold on;
xlim([0 sz]);
plot(xlim,[th th]/size(ar,2)*100,':r');
yl = ylim;
yl = yl(2);
tp = fix(k(2:3)/tempr)+1;
plot([tp(1)-1 tp(2)],[yl yl],'-k','linewidth',3);
tp = fix(k(5:6)/tempr)+1;
plot([tp(1)-1 tp(2)],[yl yl],'-k','linewidth',3);
set(gca,'xticklabel',[]);
ylabel('% of cells active');

subplot(5,3,13);
ylim([0 size(ar,2)]);
set(gca,'ytick',[1 size(ar,2)]);
rasterplot(spk);
xlabel('Time (frames)');
ylabel('Cell number');

subplot(5,3,7);
plot_cont(cn,[],'r');
xl = xlim;
yl = ylim;
box on;

tp = fix(k(2:3)/tempr)+1;
tp1 = tp(1):tp(2);
tp = fix(k(5:6)/tempr)+1;
tp2 = tp(1):tp(2);
nfr = max([5 size(tp1,2) size(tp2,2)]);

tp = fix(k(2:3)/tempr)+1;
tp = tp(1):tp(2);
for c = 1:size(tp,2)
    subplot(nfr,3,3*c-1);
    hold on;
    f = find(s(:,tp(c))==1);
    for j = 1:size(f,1)
        plot(cn{f(j)}([1:end 1],1),cn{f(j)}([1:end 1],2),'color',[0 0 0],'linewidth',2);
    end
    axis equal;
    box on;
    set(gca,'xlim',xl,'ylim',yl,'xticklabel',[],'yticklabel',[]);
    title(['Fr. ' num2str(tp(c)) ': ' num2str(round((tp(c)-1)*tempr*10)/10) ' to ' num2str(round(tp(c)*tempr*10)/10) ' s.']);
end
xlabel('First occurence');

tp = fix(k(5:6)/tempr)+1;
tp = tp(1):tp(2);
for c = 1:size(tp,2)
    subplot(nfr,3,3*c);
    hold on;
    f = find(s(:,tp(c))==1);
    for j = 1:size(f,1)
        plot(cn{f(j)}([1:end 1],1),cn{f(j)}([1:end 1],2),'color',[0 0 0],'linewidth',2);
    end
    axis equal;
    box on;
    set(gca,'xlim',xl,'ylim',yl,'xticklabel',[],'yticklabel',[]);
    title(['Fr. ' num2str(tp(c)) ': ' num2str(round((tp(c)-1)*tempr*10)/10) ' to ' num2str(round(tp(c)*tempr*10)/10) ' s.']);
end
xlabel('Second occurence');

subplot(10,3,1);
tx = text(0,1,fname(1:8));
set(tx,'verticalalignment','top','fontsize',20);
tx = text(0,0,['Template #' num2str(num)]);
set(tx,'verticalalignment','bottom','fontsize',14);
axis off;

subplot(5,3,4);
m = tpk';
m(:,2) = zeros(size(tpk,2),1);
m = num2str(m);
for c = 1:size(m,1)
    if sum(s(:,tpk(c)))>th
        m(c,end) = '*';
    else
        m(c,end) = ' ';
    end
end
if size(m,2)<18
    m = ['Significant events'; m repmat(' ',size(m,1),18-size(m,2))];
else
    m = ['Significant events' repmat(' ',1,size(m,2)-18); m];
end
tx = text(0,0,m);
set(tx,'verticalalignment','bottom','fontsize',12);
tx = text(1,0,'* peaks');
set(tx,'verticalalignment','bottom','horizontalalignment','right','fontsize',12);
axis off;

fclose('all');

set(gcf,'paperposition',[.25 .25 8 10.5],'paperorientation','portrait');

cd(fld);