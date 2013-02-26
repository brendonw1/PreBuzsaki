function hippo_plot_traces(region)

tr = region.traces;
nt = zeros(size(tr,1),size(tr,2));
nt = dfoverf(tr);
for c = 1:size(tr,1)
    nt(c,:) = myfilter(nt(c,:),2);
    %skn{c} = (spk{c}-1)/(size(tr,2)-1)*20;
end

cl = hsv(length(region.coords));

hold on;
xlim([0 region.imagesize(2)])
ylim([0 region.imagesize(1)])
set(gca,'ydir','reverse');
box on
set(gca,'color',[0 0 0]);
set(gca,'xtick',[],'ytick',[]);
set(gcf,'doublebuffer','on');

for c = 1:length(region.contours)
    ct = HippoCentroid(region.contours{c});
    h = plot(linspace(ct(1),ct(1)+20,size(tr,2)),-20*nt(c,:)+ct(2),'color',cl(region.location(c),:));
    set(h,'ButtonDownFcn',['fprintf([''' num2str(c) ''' char(13)])']);
%     for d = skn{c}
%         plot([ct(1)+d ct(1)+d],[ct(2) ct(2)+10],':w')
%     end
    drawnow
end