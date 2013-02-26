function centers=cellcenters(contours,selectedcells)

for a=1:length(selectedcells);
    centers(a,:)=centroid(contours{selectedcells(a)});
end