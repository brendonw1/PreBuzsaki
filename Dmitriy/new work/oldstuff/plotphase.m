function mx = plotphase(hst,varargin)
%plotphase(hist1,[hist2])
%   plots responses of 1 or 2 cells to spatial phase

set(gcf,'color',[1 1 1]);
set(gcf,'position',[128    31   500   500]);
switch size(varargin,2)
case 0
   sz = size(hst,1)/16;
   for c = 1:16
      hs(c,:) = mean(hst((c-1)*sz+1:c*sz,:));
   end
   for c = 0:15
      theta = c/8*pi;
      subplot('position',[0.445+0.375*cos(theta) 0.445+0.375*sin(theta) 0.11 0.11]);
      box on;
      h = bar(1:size(hst,2),hs(c+1,:));
      set(h,'facecolor',[0 0 0]);
      set(h,'edgecolor',[0 0 0]);
      xlim([0.5 size(hst,2)+0.5]);
      ylim([0 max(max(hs))*1.1]);
      hold on;
      plot([max(xlim)/2 max(xlim)/2],ylim,':k');
      set(gca,'xtick',[]);
      set(gca,'ytick',[]);
      set(gca,'handlevisibility','off');
   end
   subplot('position',[0.175 0.175 0.65 0.65]);
   rs = mean(hs');
   rs = [rs rs(1)];
   x = cos((0:16)/8*pi).*rs;
   y = sin((0:16)/8*pi).*rs;
   mx = 5*(fix(max(rs+eps)/5)+1);
   hold on;
   theta = 0:pi/50:2*pi;
   plot(cos(theta)*mx,sin(theta)*mx,'-k');
   plot(cos(theta)*mx/2,sin(theta)*mx/2,':k');
   for theta = (0:7)/8*pi
      plot([-cos(theta)*mx cos(theta)*mx],[-sin(theta)*mx sin(theta)*mx],':k');
   end
   plot(x,y,'-sr','linewidth',2,'markerfacecolor',[0 0 0],'markersize',7);
   xlim([-mx*1.16 mx*1.16]);
   ylim([-mx*1.16 mx*1.16]);
   axis off;
   subplot('position',[0.93,0.475,0.05,0.05]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'0','fontsize',16,'horizontalalignment','right');
   axis off;
   subplot('position',[0.45,0.93,0.1,0.045]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'90','fontsize',16,'horizontalalignment','center');
   axis off;
   subplot('position',[0,0.475,0.07,0.05]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'180','fontsize',16,'horizontalalignment','center');
   axis off;
   subplot('position',[0.45,0.025,0.1,0.045]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'270','fontsize',16,'horizontalalignment','center');
   axis off;
case 1
   hst2 = varargin{1};
   sz = size(hst,1)/16;
   for c = 1:16
      hs1(c,:) = mean(hst((c-1)*sz+1:c*sz,:));
      hs2(c,:) = mean(hst2((c-1)*sz+1:c*sz,:));
   end
   for c = 0:15
      theta = c/8*pi;
      subplot('position',[0.445+0.375*cos(theta) 0.445+0.375*sin(theta) 0.11 0.055]);
      h = bar(1:size(hst,2),hs1(c+1,:));
      set(h,'facecolor',[0 0 0]);
      set(h,'edgecolor',[0 0 0]);
      hold on;
      plot([0.5 0.5],[0 max(max(hs1))*1.1],'-k');
      plot([size(hst,2)+0.5 size(hst,2)+0.5],[0 max(max(hs1))*1.1],'-k');
      plot([0.5 size(hst,2)+0.5],[0 0],'-k');
      xlim([0.5 size(hst,2)+0.5]);
      ylim([0 max(max(hs1))*1.1]);
      plot([max(xlim)/2 max(xlim)/2],ylim,':k');
      axis off;
      set(gca,'handlevisibility','off');
      subplot('position',[0.445+0.375*cos(theta) 0.5+0.375*sin(theta) 0.11 0.055]);
      h = bar(1:size(hst,2),hs2(c+1,:));
      hold on;
      set(h,'facecolor',[0 0 0]);
      set(h,'edgecolor',[0 0 0]);
      plot([0.5 0.5],[0 max(max(hs2))*1.1],'-k');
      plot([size(hst,2)+0.5 size(hst,2)+0.5],[0 max(max(hs2))*1.1],'-k');
      plot([0.5 size(hst,2)+0.5],[max(max(hs2))*1.1 max(max(hs2))*1.1],'-k');
      xlim([0.5 size(hst,2)+0.5]);
      ylim([0 max(max(hs2))*1.1]);
      plot([max(xlim)/2 max(xlim)/2],ylim,':k');
      axis off;
      set(gca,'handlevisibility','off');
   end
   subplot('position',[0.175 0.175 0.65 0.65]);
   rs1 = mean(hs1');
   rs1 = [rs1 rs1(1)];
   rs2 = mean(hs2');
   rs2 = [rs2 rs2(1)];
   x1 = cos((0:16)/8*pi).*rs1;
   y1 = sin((0:16)/8*pi).*rs1;
   x2 = cos((0:16)/8*pi).*rs2;
   y2 = sin((0:16)/8*pi).*rs2;
   mx = 5*(fix(max([rs1+eps rs2+eps])/5)+1);
   hold on;
   theta = 0:pi/50:2*pi;
   plot(cos(theta)*mx,sin(theta)*mx,'-k');
   plot(cos(theta)*mx/2,sin(theta)*mx/2,':k');
   for theta = (0:7)/8*pi
      plot([-cos(theta)*mx cos(theta)*mx],[-sin(theta)*mx sin(theta)*mx],':k');
   end
   plot(x1,y1,'-sk','linewidth',2,'markerfacecolor',[0 0 0],'markersize',7);
   plot(x2,y2,'-ok','linewidth',2,'markerfacecolor',[1 1 1],'markersize',8);
   text(0,0,'0','verticalalignment','baseline','fontsize',14);
   text(mx*cos(pi/3),mx*sin(pi/3),num2str(mx),'verticalalignment','baseline','fontsize',14);
   xlim([-mx*1.16 mx*1.16]);
   ylim([-mx*1.16 mx*1.16]);
   axis off;
   subplot('position',[0.93,0.475,0.05,0.05]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'0','fontsize',14,'horizontalalignment','right');
   axis off;
   subplot('position',[0.45,0.93,0.1,0.045]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'90','fontsize',14,'horizontalalignment','center');
   axis off;
   subplot('position',[0,0.475,0.07,0.05]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'180','fontsize',14,'horizontalalignment','center');
   axis off;
   subplot('position',[0.45,0.025,0.1,0.045]);
   xlim([-1 1]);
   ylim([-1 1]);
   text(0,0,'270','fontsize',14,'horizontalalignment','center');
   axis off;
end