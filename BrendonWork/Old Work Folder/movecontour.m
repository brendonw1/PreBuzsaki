function spokes=movecontour(coords1,coords2);
%move coords1 so that it is centered at the centroid of coords2

centroid1=centroid(coords1);
centroid2=centroid(coords2);

spokes=coords1-repmat(centroid1,[size(coords1,1) 1]);
spokes=spokes+repmat(centroid2,[size(coords1,1) 1]);