function perimeter = perimeter(coords)
%perimeter = perimeter(coords)
%   calculates the perimeter of a polygon with given coordinates

coords2 = [coords(end,:); coords(1:end-1,:)];

dst = (coords-coords2).^2;
dst = sum(dst,2).^(1/2);
perimeter = sum(dst);