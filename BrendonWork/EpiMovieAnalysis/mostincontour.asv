function [refons,testons]=mostincontour(refconts,testconts,frame);
%this determines which of the refconts contousr each contour from testconts
%overlaps with most. (Both input arrays are cell arrays, each element of
%which is the coordinates for one contour)
warning off MATLAB:conversionToLogical
refons=zeros(1,length(refconts));%establish a matrix to say whether each cell is in or not
testons=zeros(1,length(testconts));
[s1,s2]=size(frame);
xcoords=ones(size(frame));
for b=1:s2;
    xcoords(:,b)=xcoords(:,b)*b;
end
ycoords=ones(size(frame));
for a=1:s1;
    ycoords(a,:)=ycoords(a,:)*a;
end

allcells=zeros(size(frame));
refin={};
for c=1:length(refconts);%for each refcont (conts we will ask whether testconts are inside)
    refin{c}=logical(inpolygon(xcoords,ycoords,refconts{c}(:,1),refconts{c}(:,2)));%find the pixels inside each cont
    refin{c}=refin{c}*c;%assign values of pixels inside cell c with the number c
    allcells=allcells+refin{c};%put together a template the size of the frame which has zeros around but value of
                                %c where pixels are inside contour c (all contours at once)
end
mostcell=zeros(1,length(testons));
for d=1:length(testconts);%for each testcont (cells to ask which testcont they are associated with)
    testin{d}=logical(inpolygon(xcoords,ycoords,testconts{d}(:,1),testconts{d}(:,2)));%find cells in the testcont
    inside{d}=double(testin{d})+allcells;%add the pixels from this test cont to the map of all cells
    inside{d}=inside{d}(testin{d});%extract from that only the pixels that are inside the testcont at hand
    inside{d}=inside{d}-1;%any numbers in inside{d} will now correspond exactly with which refcont is responsible for them
    if sum(inside{d})>0;
        for e=1:length(refconts)%
            found(e)=sum(logical(find(inside{d}==e)));
        end
        [m,mostcell(d)]=max(found);%mostcell is the cell that is more overlapping with the testcont than anyother cell
        thiscell=refin{mostcell(d)};
        thiscell=double(thiscell/mostcell(d));
        if m>.25*sum(sum(thiscell));%if the overlap is more than 25% of the refcell
            refons(mostcell(d))=1;
            testons(d)=1;
        end    
    end
end