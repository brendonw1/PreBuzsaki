function MakeMovie(raster,coords,fout)
%MakeMovie(raster,coords,fout)
%   Makes a movie from a rasterplot and a set of coordinates

for c = 1:size(raster,2)
   f = find(raster(:,c)==1);
   plot(coords(:,1),coords(:,2),'.k');
   hold on
   plot(coords(f,1),coords(f,2),'ok','MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',6);
   hold off
   set(gca,'xtick',[],'ytick',[],'ydir','reverse');
   xlim([0 max(coords(:,1))+10]);
   ylim([0 max(coords(:,2))+10]);
   a = getframe;
   imwrite(a.cdata(:,:,1),fout,'Compression','none','WriteMode','Append');
end

delete(gcf);