function [noedges,rowselim,colselim]=elimbadedges(image)
%this function finds rows and columns that are of a singular value (done by
%alignment program) and erases them.  It then stores a new image without
%those edges.  However, in addition to eliminating the blank rows and
%columns, it eliminates the ones just next to the innermost blank ones,
%and also eliminates all border rows and columns (because some problems
%happen with this).
%Output is "noedges", the new image.  rowselim and colselim are vectors
%listing the eliminated rows and columns, to be used later for restoring
%those pixels using "restoreedges" function.
noedges=image;
rowdevs=std(image,1,2);
coldevs=std(image,1,1);
rowselim=find(rowdevs==0);
if isempty(rowselim);%if no zero rows
    rowselim=[1, size(image,1)];%eliminate all edges
else%if some zero rows
    dr=diff(rowselim);%take difference between them
    if isempty(find(dr>1)) | size(rowselim)==1;%if on just one side of the image OR if just a single row
        if ismember(1,rowselim)%if blanks are at the beginning of the image    
           rowselim(end+1)=rowselim(end)+1;%add a safety row to the right of that
        end
        if ismember(size(image,1),rowselim);% if blanks are on right
            rowselim(end+1)=rowselim(1)-1;%add safety row to the left side
        end
    end
    if ~isempty(find(dr>1));%if zeros on both sides of image (will this happen?)
        nonzero=find(dr>1);%the place where the last of the left half is
        rowselim(end+1)=nonzero+1;%add one more row to the right of the left side
        rowselim(end+1)=rowselim(nonzero+1)-1;%add one more row to the left of the right side
    end
end
if ~ismember(1,rowselim);%the following two loops will eliminate edges
    rowselim(end+1)=1;
end
if ~ismember(size(image,1),rowselim);
    rowselim(end+1)=size(image,1);
end
rowselim=sort(rowselim)';
%if one of the rows is not contiguous with the end, dump it
dr = diff(rowselim);
dr = find(dr>1);
if length(dr)>1%if more than two contiguous clusters of frames... ie if call for elimination in middle
    rowselim(dr(1)+1:dr(end))=[];%eliminate these odd rows
end
if numel(rowselim)==1
    if rowselim == size(image,1) || rowselim == 1
        rowselim=[1, size(image,1)];%eliminate all edges
    end
end 
noedges(rowselim,:)=[];
colselim=find(coldevs==0);
if isempty(colselim);%if no zero cols
    colselim=[1, size(image,1)];%eliminate all edges
end
if ~isempty(colselim);%if some zero cols
    dr=diff(colselim);%take difference between them
    if isempty(find(dr>1));%if on just one side of the image
        if ismember(1,colselim);%if blanks are at the beginning of the image
           colselim(end+1)=colselim(end)+1;%add a safety col to the right of that
        end
        if ismember(size(image,1),colselim);% if blanks are on right
            colselim(end+1)=colselim(1)-1;%add safety col to the left side
        end
    end
    if ~isempty(find(dr>1));%if zeros on both sides of image (will this happen?)
        nonzero=find(dr>1);%the place where the last of the left half is
        colselim(end+1)=nonzero+1;%add one more col to the right of the left side
        colselim(end+1)=colselim(nonzero+1)-1;%add one more col to the left of the right side
    end
end
if ~ismember(1,colselim);%the following two loops will eliminate edges
    colselim(end+1)=1;
end
if ~ismember(size(image,1),colselim);
    colselim(end+1)=size(image,1);
end
colselim=sort(colselim);
%if one of the rows is not contiguous with the end, dump it
dc = diff(colselim);
dc = find(dc>1);
if length(dc)>1%if more than two contiguous clusters of frames... ie if call for elimination in middle
    colselim(dc(1)+1:dc(end))=[];%eliminate these odd rows
end
if numel(colselim)==1
    if colselim == size(image,1) || colselim == 1
        colselim=[1, size(image,1)];%eliminate all edges
    end
end
noedges(:,colselim)=[];