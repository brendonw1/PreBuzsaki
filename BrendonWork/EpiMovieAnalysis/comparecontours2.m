function [refons,testons]=comparecontours2(refconts,testconts)
% Takes centers of "testconts" contours and detects if each one is inside any
% of the "refconts" contours.  If so, a 1 is entered into the "refconts

centers=[];
for b=1:length(testconts);%for each contour just created
    centers(b,:)=centroid(testconts{b});%get centroid, put in "centers", which will have height b, width 2
end    
i=[];
for c=1:length(refconts);%for each contour from original image...
    i(:,c)=inpolygon(centers(:,1),centers(:,2),refconts{c}(:,1),refconts{c}(:,2));%determine if any centroid 
    % is in that contour
    % i will have a column for each refcont, a row for each testcont
end
testons=logical(sum(i,2))';%produces a horizontal vector, width equals index of refconts: 1 if that cell turned on, 0 if not
refons=logical(sum(i,1));%makes sure nothing more than 1
    
    
    
    
    
    
    
    
    
    
    
    
    
%     
%     
%     
% 
% centroidsmatrix=[];
% for centroidsfiller = 1:length(bigenoughs);
%     centroidsmatrix(centroidsfiller,:)=centroid(bigenoughs{centroidsfiller});
% end
% 
% if movienumber==1;
%     keepermatrix = bigenoughs;
%     figure(10)
%     plot (centroidsmatrix (:,1),centroidsmatrix(:,2),'o')
%     axis([0 255 0 255])
%     
% else 
%     for polygonnumb = 1:(length(keepermatrix));
%         in=inpolygon(centroidsmatrix(:,1),centroidsmatrix(:,2),keepermatrix{polygonnumb}(:,1),keepermatrix{polygonnumb}(:,2));
%         if polygonnumb==1;
%             finalin=in;
%         else
%             finalin=finalin+in;    
%         end    
%      end
%      for n = 1:prod(size(finalin));
%         if finalin(n)==0;
%             keepermatrix{length(keepermatrix)+1}=bigenoughs{n};
%         end
%      end    
%  end
%  
% whos