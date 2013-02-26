function rasterplot(spk)
%rasterplot(spk)
%   creates a raster plot from a spike time cell array

if prod(size(get(gcf,'children'))) == 0
   ylim([0 size(spk,2)]);
end
hold on;
yl = ylim;
for c  = 1:size(spk,2)
   ymin = yl(1) + (c-1)/size(spk,2)*(yl(2)-yl(1));
   ymax = yl(1) + c/size(spk,2)*(yl(2)-yl(1));
   for s = spk{c}
      plot([s s],[ymin ymax],'-k','linewidth',1);
   end
end

allspk = cat(2,spk{:});
xlim([0 max(allspk)]);