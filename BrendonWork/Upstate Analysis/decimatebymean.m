function newvect=decimatebymean(vect,factor);


remain=rem(length(vect),factor);
if remain>0;%if number of points is not divisible by factor
%     remvals=vect(end-(remain-1):end);%find remainders
%     remmean=mean(remvals);
    newvect=vect(1:end-remain);
    newvect=reshape(newvect,[factor length(newvect)/factor]);%set up for factor fold decimation of data  
    newvect=mean(newvect);%decimation to 1 point per 10ms is complete
    newvect=newvect(1:end);
%     newvect(end+1)=remmean;
else%if divisible by factor
    newvect=reshape(vect,[factor size(vect,1)/factor]);%set up for factor fold decimation of data  
    newvect=mean(newvect);%decimation to 1 point per 10ms is complete
    newvect=newvect(1:end)';
end