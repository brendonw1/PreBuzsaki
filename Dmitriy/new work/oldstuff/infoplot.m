function infoplot = infoplot(cell)

cell1 = cell(1:8);
cell2 = [cell(1:7) cell(9)];

load([ondesk 'paper\info1\' cell1 '.mat']);
pl1 = resno-res10;
load([ondesk 'paper\info1\' cell2 '.mat']);
pl2 = resno-res10;
load([ondesk 'paper\info2\' cell '.mat']);
plt = resno-res10;
pln = plt(1,:);

infoplot(1) = ((max(pl1)+max(pl2))-max(max(pln)))/((max(pl1)+max(pl2))-max([max(pl1) max(pl2)]));
infoplot(2) = ((max(pl1)+max(pl2))-max(max(plt)))/((max(pl1)+max(pl2))-max([max(pl1) max(pl2)]));

pl1(find(pl1<0))=0;
pl2(find(pl2<0))=0;
plt = plt.*(sign(plt+eps)+1)/2;
subplot('position',[.2 .1 0.75 0.85]);
hold on;
[q k] = meshgrid(0:10,[0 0.1 0.2 0.4 0.6 0.8 1 1.25 1.5 1.75 2]);
h = surf(q,k,plt);
contour(q,k,plt);
shading interp;
set(h,'edgecolor',[0 0 0]);
colormap hsv;
plot3(0:10,zeros(1,11),pl1,'-sk','linewidth',2,'markerfacecolor',[0 0 0],'markersize',7);
plot3(0:10,zeros(1,11),pl2,'-ok','linewidth',2,'markerfacecolor',[1 1 1],'markersize',8);
plot3(0:10,zeros(1,11),pl1+pl2,'-+k','linewidth',2,'markerfacecolor',[1 1 1],'markersize',8);
grid on;
zl = get(gca,'zlim');
zl(1) = 0;
zl(2) = max([max(max(plt)) max(pl1+pl2)]);
zl(2) = fix(zl(2)/0.1+1)*0.1;
zlim(zl);
set(gca,'xtick',[0 log(10)/log(2)+1 log(100)/log(2)+1]);
set(gca,'xticklabel',[0 10 100]);
set(gca,'fontsize',14);
set(gcf,'position',[190    32   400   500]);
set(gcf,'color',[1 1 1]);
view([-20 5]);
xlabel('q (1/s)');
ylabel('k');
zlabel('H (bits)');