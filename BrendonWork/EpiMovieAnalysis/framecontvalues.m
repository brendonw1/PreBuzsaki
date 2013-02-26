function meanvalues=framecontvalues (frame,contoursmatrix)
%finds mean value in each contour (from 2D contoursmatrix
%which is a cell array of coordinates created in "findcells") 
%in the given frame (a 2D matrix).  Output is "meanvalues" which is a 3D matrix
%of (frames)x(movies)x(cellnumber)

warning off MATLAB:conversionToLogical;

for contournumber = 1:(length(contoursmatrix));%for each contour
    for ycounter=1:size(frame,1);%for each line in the image
        yc=ycounter(ones(1,size(frame,2)));
        in=inpolygon(1:size(frame,1),yc,contoursmatrix{contournumber}(:,1),contoursmatrix{contournumber}(:,2));%a 1D line of 
                                                                        %0's and 1's for all x's across 1 y value
        inmatrix(ycounter,:)=in;%a matrix of the pixels inside a given contour... 2D by the time the for-loop is over
	end
    inmatrix=logical(inmatrix); 
    meanvalues(contournumber)=mean(frame(inmatrix));
end