function lst = findcells(fin,cutoff,areamin,areamax)
%lst = findcells(fin, cutoff,areath)
%   reads in an image file, detects cells with a given cutoff, and
%   outputs a cell array containing coordinates of all contours

a = imread(fin,'tif');
%[i j] = find(a>cutoff);
imagesc(a);
colormap(gray);
set(gcf,'position',[1, 29, 1024, 672]);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[c h] = contour(a,[cutoff cutoff],'-r');
lst = {};
for c = 1:size(h,1)
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:)
      if poly_area(round(coords(1:end-1,:))) > areamin & poly_area(round(coords(1:end-1,:))) < areamax;
         lst{size(lst,2)+1} = coords(1:end-1,:);
      else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end
%delete(gcf);