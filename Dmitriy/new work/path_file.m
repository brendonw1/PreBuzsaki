function paths = path_file(cn,fname,tm)
%PATH_FILE(CN,FID,TM)
%   Uses a modified convex hull algorithm to construct a path around points
%   or contours and outputs the result to a text file used for point
%   recordings.
%   CN - either a cell array containing contours or an Nx2 array containing
%   coordinates
%   FNAME - a string containing the output file name
%   TM - either a scalar containing the number of milliseconds spent for
%   every one of the point or a 1xN array containing the number of
%   milliseconds spent for each point
%
%   by Dmitriy Aronov, 1/17/2003

ct = [];
if iscell(cn)
    for c = 1:prod(size(cn))
        ct(c,:) = center(cn{c});
    end
else
    ct = cn;
end

if prod(size(tm)) == 1
    tm = tm*ones(1,size(ct,1));
end
tm = reshape(tm,prod(size(tm)),1);

[mpth, paths] = min_path(ct);
ct = [ct tm];
ct = ct(mpth,:);

fclose('all');
fid = fopen(fname,'w');
for c = 1:size(ct,1)
    a1 = num2str(ct(c,1),'%1.4f');
    a1 = a1(1:6);
    a2 = num2str(ct(c,2),'%1.4f');
    a2 = a2(1:6);
    a3 = num2str(ct(c,3),'%1.3f');
    a3 = a3(1:5);
    fprintf(fid,[a1 char(9) a2 char(9) a3 char(13) '\n']);
end
    
fclose('all');

function [min_path, paths] = min_path(coords)
%min_path = min_path(coords)
%   uses the convex hull algorithm to construct the path around the points

curr_path = convhull(coords(:,1),coords(:,2));
curr_path = curr_path(1:end-1);

paths{1} = curr_path;

for c = 1:size(coords,1)-size(curr_path,1)
    pts_left = setdiff(1:size(coords,1),curr_path);
    npath = size(curr_path,2);
    nleft = size(pts_left,2);
    
    c1 = coords(curr_path,:);
    c2 = coords(curr_path([2:end 1]),:);
    seg_length = sqrt(sum((c2-c1).^2,2));
    seg_length = repmat(seg_length,1,nleft);
    
    [xpath xleft] = meshgrid(coords(pts_left,1),coords(curr_path,1));
    xdiff1 = abs(xpath-xleft);
    [xpath xleft] = meshgrid(coords(pts_left,1),coords(curr_path([2:end 1]),1));
    xdiff2 = abs(xpath-xleft);
    [ypath yleft] = meshgrid(coords(pts_left,2),coords(curr_path,2));
    ydiff1 = abs(ypath-yleft);
    [ypath yleft] = meshgrid(coords(pts_left,2),coords(curr_path([2:end 1]),2));
    ydiff2 = abs(ypath-yleft);
    xydiff1 = sqrt(xdiff1.^2+ydiff1.^2);
    xydiff2 = sqrt(xdiff2.^2+ydiff2.^2);
    
    indx = xydiff1+xydiff2;
    indx = indx.*tan(asin((xydiff1.^2+xydiff2.^2-seg_length.^2)./(2*xydiff1.*xydiff2)));
    indx = indx+repmat(eps*(1:size(indx,2)),size(indx,1),1);
    indx = indx+repmat(eps*(1:size(indx,1))',1,size(indx,2));
    [i j] = find(indx==min(min(indx)));
    curr_path = [curr_path(1:i); pts_left(j); curr_path(i+1:end)];
    paths{c+1} = curr_path;
end

min_path = curr_path;
    

function centroid = center(coords)
%centroid = center(coords)
%   calculates the center of mass of a polygon with given coordinates

if prod(size(coords))==0
   cx = NaN;
   cy = NaN;
else
   m = [coords; coords(1,:)];
   x = m(:,1);
   y = m(:,2);
   
   a = (sum(x(1:end-1).*y(2:end)) - sum(x(2:end).*y(1:end-1)))/2;
   cx = sum((x(1:end-1)+x(2:end)).*(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)))/(6*a);
   cy = sum((y(1:end-1)+y(2:end)).*(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)))/(6*a);
end

centroid = [cx cy];