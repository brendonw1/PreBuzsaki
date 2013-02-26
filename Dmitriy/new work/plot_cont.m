function plot_cont(cn,f,col,isa)
%plot_cont(cn,f,col)
%   plots the contours of cells in cn
%   emphasizes cells in f

hold on;

for c = 1:size(cn,2)
    k =  centroid(cn{c});
    if k(2)>0
        plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'color',[0.6 0.6 0.6]);
        plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'color',[0 0 0]);
    end
end

for c = 1:prod(size(f))
    %plot(cn{f(c)}([1:end 1],1),cn{f(c)}([1:end 1],2),'color',col,'linewidth',2);
    h = patch(cn{f(c)}(:,1),cn{f(c)}(:,2),col);
    set(h,'edgecolor',col,'facecolor',col);
    %if isa(c)==0
    %    set(h,'edgecolor','k','facecolor','k');
    %else
    %    set(h,'edgecolor','r','facecolor','r');
    %end
end

%plot([0 485 485 0 0],[0 0 395 395 0],'-k')

axis equal
axis tight

%axis off

set(gca,'ydir','reverse');