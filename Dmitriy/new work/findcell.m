function findcell = findcell(cn,x,y,tol)
%findcell = findcell(cn,x,y,tol)
%   finds the cell at coordinates (x,y) with tolerance tol

ct = [];
for c = 1:size(cn,2)
    ct(c,:) = centroid(cn{c});
end

findcell = intersect(find(abs(ct(:,1)-x)<tol),find(abs(ct(:,2)-y)<tol));