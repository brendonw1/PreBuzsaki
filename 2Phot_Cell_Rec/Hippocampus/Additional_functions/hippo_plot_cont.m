function hippo_plot_cont(region,f)
% hippo_plot_cont(region,f)
%    plots the cells in structure region, coloring the cells in f

hold on;
cl = hsv(length(region.name));

for c = 1:size(region.contours,2)
    if isempty(find(f==c))
        plot(region.contours{c}([1:end 1],1),region.contours{c}([1:end 1],2),'color',cl(region.location(c),:));
    else
        h = patch(region.contours{c}([1:end 1],1),region.contours{c}([1:end 1],2),cl(region.location(c),:));
        set(h,'edgecolor',1-cl(region.location(c),:));
    end
end

axis equal
xlim([0 region.imagesize(2)])
ylim([0 region.imagesize(1)])

set(gca,'ydir','reverse');
box on
set(gca,'color',[0 0 0]);
set(gca,'xtick',[],'ytick',[]);