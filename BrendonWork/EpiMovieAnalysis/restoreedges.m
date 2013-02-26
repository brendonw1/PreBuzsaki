function edgesagain=restoreedges(noedges,rowselim,colselim,edgeval)
%this function will take rows eliminated in "elimbadedges" and restore them
%around the image.  The pixels kept from the original image will return to
%their original positions and all removed pixels will be placed in their
%old positions and will be given the value of the mean of the "noedges"
%pixels.
sizerows=size(noedges,1)+length(rowselim);
sizecols=size(noedges,2)+length(colselim);
edgesagain=edgeval*ones(sizerows,sizecols);%make a new image the size of 
%the original one that had its edges removed.  Values will be equal to the
%mean of the original original image... only the edges will keep this value
dr=diff(rowselim);
dr=find(dr>1);%tells us where there is a big jump in the rows... ie which portion refers to left of image vs right
dc=diff(colselim);
dc=find(dc>1);%tells us where there is a big jump in the rows... ie which portion refers to left of image vs right
edgesagain(rowselim(dr)+1:rowselim(dr+1)-1,colselim(dc)+1:colselim(dc+1)-1)=noedges;