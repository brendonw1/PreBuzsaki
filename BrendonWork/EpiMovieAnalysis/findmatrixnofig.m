function conts= findmatrixnofig(a,cutoff,areath,maxarea)
% function [conts,outconts,contsthresh]= findfrommatrix(a,cutoff,areath,maxarea)
%conts = findcells(fin, cutoff,areath)
%   takes image data from matrix input (a), detects cells with a given cutoff, and
%   outputs a cell array containing coordinates of all contours


figure;imagesc(a);
colormap(gray);
set(gcf,'position',[532   378   746   569]);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[c h] = contour(a,[cutoff cutoff],'-r');
conts = {};
% outconts = {};
for c = 1:size(h,1)
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:)
   pa= poly_area(round(coords(1:end-1,:)));
      if pa > areath & pa < maxarea;
         conts{size(conts,2)+1} = coords(1:end-1,:);
         conts{size(conts,2)}=[conts{size(conts,2)};conts{size(conts,2)}(1,:)];
%          center=centroid(coords);
%          outconts{end+1}=pixellatedcircle(center(1),center(2),60);%generate a circle of area 60 around each 
         %kept contour 
      else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end
delete(gcf);
% contsthresh=[cutoff areath maxarea];