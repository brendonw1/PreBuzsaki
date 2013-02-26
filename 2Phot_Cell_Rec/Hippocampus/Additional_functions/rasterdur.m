function rasterdur(spk,endpt)
%rasterplot(spk,endpt)
%   creates a raster plot from a spike time cell array

hold on
for c = 1:length(spk)
   for s = 1:length(spk{c})
      plot([spk{c}(s)*.143 endpt{c}(s)*.143],[c c],'-k','linewidth',1);
   end
end

allspk = cat(2,endpt{:});
xlim([0 max(allspk)*.143]);