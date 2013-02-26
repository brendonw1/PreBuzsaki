function [refons,testons]=centroidoverlapmasks(refmasks,testmasks,img)
%Refmasks are to be tested - ie potential activations or matches.
%Testmasks are areas where cells are known to be.
%Which of the testmasks have centroids in which refmask.  Img is a
%representative image, the size of which will be measured for callibration
%of vector masks.
refons=zeros(1,length(refmasks));
testons=zeros(1,length(testmasks));
for a=1:length(testmasks);%for each object
    t=zeros(size(img));%establish a blank matrix, corresponding to the size of a frame
    if ~isempty(testmasks{a});
        t(testmasks{a})=1;%fill in relevant pixels (no need for bwlabel, since only points will be 1's)
        t=imfeature(t,'Centroid');%find the centroid of the object
        t=round(t.Centroid);%round to an integer
        t=(size(img,1)*(t(1,1)-1))+t(1,2);%determine the pixel number of that point
        for b=1:length(refmasks);%for each known contour... which we want to see if a centroid is in
            if ismember(t,refmasks{b});
                testons(a)=1;
                refons(b)=1;
            end
        end        
    end
end   