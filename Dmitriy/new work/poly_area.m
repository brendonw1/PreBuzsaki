function a = poly_area(coords)
%a = poly_area(coords)
%   calculates the area of a polygon with given vertices

if prod(size(coords))==0
   a = 0;
else
   m = [coords; coords(1,:)];
   x = m(:,1);
   y = m(:,2);
   
   a = abs(sum(x(1:end-1).*y(2:end)) - sum(x(2:end).*y(1:end-1)))/2;
end