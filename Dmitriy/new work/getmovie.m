function m = getmovie(fname,nframes)
%m = getmovie(fname,nframes)
%   reads the first nframes frames of a TIF movie

m = moviein(nframes);

colormap gray;
cl = colormap;
%set(gcf,'position',[1, 29, 1024, 672]);
%subplot('position',[0 0 1 1]);
axis equal;
set(gca,'NextPlot','replacechildren');
axis off;

for c = 1:nframes
   a = imread(fname,'tif',c);
   ncl = round(double(max(max(a)))/4096*64);
   colormap(cl(1:ncl,:));
   imagesc(a);
   m(:,c) = getframe;
end

delete(gcf);