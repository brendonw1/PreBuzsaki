point1 = get(gca,'CurrentPoint');
finalRect = rbbox;
point2 = get(gca,'CurrentPoint');

candx = sort([point1(1) point2(1)]);
if range(candx) > 1
    xlimits = sort([point1(1) point2(1)]);
else
    xlimits = [0 size(nt,2)+1];
end
hevPlotTrace