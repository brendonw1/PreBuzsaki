function newons2 = changeframespace(ons1,ons2)
%Takes correlated (lockstep) activity in ons2 which also occurs in ons1 and
%replaces it with the lockstep-shared activity from ons1.  
%Make this algorithm smarter:(?)
%   - Choose which movie to replace and which to keep, instead of always "keeping" 1 and changing 2
%   - Choose better which frame to insert in?  Right now insert start of new lockstep at start of old
%       lockstep in changed movie.
% Aug 20, 2007 BW


[lock1,lock2] = findbestrepeats(ons1,ons2);
newons2 = ons2;
newons2(lock2) = 0;
%need to know where to implant lock1 activations into lock2... need to know
%offset of start of lock1
startframe2 = sum(lock2,2);%
startframe2 = find(startframe2,1,'first');
%find first of activity... place that at first frame found above
tempvar1 = sum(lock1,2);%
startframe1 = find(tempvar1,1,'first');
stopframe1 = find(tempvar1,1,'last');
length1 = stopframe1 - startframe1;
tempstart = startframe2;
if startframe2+length1 > size(newons2,1)
    tempstop = size(newons2,2);
    length1 = size(newons2,2) - tempstart;
    stopframe1 = startframe1+length1;
else
    tempstop = startframe2+length1;
end
template = zeros(size(newons2));
template(tempstart:tempstop,:) = lock1(startframe1:stopframe1,:);
newons2(logical(template)) = 1;
% load sorted2
% sons=sorted2{1}.spont(1).ons;
% tons=sorted2{1}.tstrain(1).ons;
% ons1=sons;
% ons2=tons;
% [s,t]=findbestrepeats(sons,tons);
% ons12=zeros(size(ons1));
% s2=zeros(size(s));
% s2(5:29,:)=s(1:25,:);
% ons12(5:29,:)=ons1(1:25,:);
% non=s2.*t;
% non2=s2;
% non2(logical(non))=0;
% ons12(logical(non2))=0;
% non2=logical(non2);
% non2=circshift(non2,1);
% non2=logical(non2);
% ons12(logical(non2))=1;
% t2=t;
% t2=logical(t2);
% t2=t2.*ons12;
% [ttt1,ttt2]=find(t2);
% [i1,j1]=find(ons12);
% [i2,j2]=find(ons2);
% figure
% plot(i1,j1,'.','color','g')
% hold on
% plot(ttt1,ttt2,'o','color','r')
% xlim([0 10])
% xlim([3 13])
% figure
% plot(i2,j2,'.','color','k')
% hold on
% plot(ttt1,ttt2,'o','color','r')
% xlim([3 13])
% 
% c=t2;%core
% s=ons12;%spont
% t=ons2;%train