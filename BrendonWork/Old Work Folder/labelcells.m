function lst = labelcells(fin,cutoff,areath);
%lst = findcells(fin, cutoff,areath)
%   reads in an image file, detects cells with a given cutoff, and
%   outputs a cell array containing coordinates of all contours

a = imread(fin,'tif');
%[i j] = find(a>cutoff);
imagesc(a);
colormap(gray);
% set(gcf,'position',[1, 29, 1024, 672]);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[c h] = contour(a,[cutoff cutoff],'-r');
lst = {};
for c = 1:size(h,1);
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:);
      if poly_area(round(coords(1:end-1,:))) > areath;
         lst{size(lst,2)+1} = coords(1:end-1,:);
         label=num2str(size(lst,2));
         aa=text(coords(1,1),coords(1,2),label);
         set(aa,'color','g');
     else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end

cells=length(lst)

%delete(gcf);