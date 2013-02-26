function infoplot1(cell)

cell1 = cell(1:8);
cell2 = [cell(1:7) cell(9)];

load(['c:\windows\desktop\paper\info1\' cell1 '.mat']);
pl1 = resno-res10;
load(['c:\windows\desktop\paper\info1\' cell2 '.mat']);
pl2 = resno-res10;

hold on;
plot(0:10,pl1,'-sk','linewidth',2,'markerfacecolor',[0 0 0],'markersize',7);
plot(0:10,pl2,'-ok','linewidth',2,'markerfacecolor',[1 1 1],'markersize',8);
set(gca,'xtick',[0 1 log(10)/log(2)+1 log(100)/log(2)+1]);
set(gca,'xticklabel',[0 1 10 100]);
yl(1) = 0;
yl(2) = max([pl1 pl2]);
yl(2) = fix(yl(2)/0.1+1)*0.1;
ylim(yl);
set(gca,'fontsize',20,'fontweight','bold');