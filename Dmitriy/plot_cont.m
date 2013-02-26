function plot_cont(cn,f,col,isa)
%plot_cont(cn,f,col)
%   plots the contours of cells in cn
%   emphasizes cells in f

hold on;

for c = 1:size(cn,2)
    %k = centroid(cn{c});
    if mean(cn{c}(:,2))>0
        plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'color',[0.6 0.6 0.6]);
        %plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'color',[1 0 0]);
    end
end

for c = 1:prod(size(f))
    h = patch(cn{f(c)}(:,1),cn{f(c)}(:,2),col);
    set(h,'edgecolor',col,'facecolor',col);
end


axis equal
axis tight

%axis off

set(gca,'ydir','reverse');