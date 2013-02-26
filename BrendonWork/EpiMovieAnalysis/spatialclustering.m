function [avgdist,avgdistx,avgdisty]=spatialclustering(ons,conts)
%ons is a 1D vector corresponding to a whether or not each contour
%was on in a single frame.  Conts are the contour traces for each cell.

warning off MATLAB:conversionToLogical

ons=logical(ons);
onsconts=conts(ons);
for a=1:length(onsconts);
    centroids(a,:)=centroid(onsconts{a});
end
centroidsx=centroids(:,1);
centroidsy=centroids(:,2);

counter=1;
for b=1:length(centroidsx);%for each member of oncentriods
    for c=b+1:length(centroidsx);%compare with each member after that one
        avgdistx(counter)=abs(centroidsx(b)-centroidsx(c));
        avgdisty(counter)=abs(centroidsy(b)-centroidsy(c));
        avgdist(counter)=((avgdistx(counter))^2+(avgdisty(counter))^2)^.5;
        counter=counter+1;
    end
end

avgdistx=mean(avgdistx);
avgdisty=mean(avgdisty);
avgdist=mean(avgdist);

