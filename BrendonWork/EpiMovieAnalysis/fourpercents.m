function [avgpercentover1,overallpercentover1,avgpercentover2,overallpercentover2,stdpercentover1,stdpercentover2]=fourpercents(nums,dens1,dens2);
%input is 3 matrices: one for numerators and 2 for denominators.  The
%numerators indicate overlapping elements between two groups, the
%denominators indicate the total elements available for overlap from the
%two compared groups.  The same element of each matrix represents
%information pertaining to the same comparison.  
%this program figures 4 different numbers: mean of elementwise (numerator/denominator1)
%                                          mean of elementwise (numerator/denominator2)
%standard devs calculated from the above 2 are also outputted
%                                          sum(numerator)/sum(denominator1)
%                                          sum(numerator)/sum(denominator2)


gooddens1=find(dens1);
gooddens2=find(dens2);

avgpercentover1=mean(nums(gooddens1)./dens1(gooddens1));
overallpercentover1=sum(nums(gooddens1))/sum(dens1(gooddens1));
avgpercentover2=mean(nums(gooddens2)./dens2(gooddens2));
overallpercentover2=sum(nums(gooddens2))/sum(dens2(gooddens2));

stdpercentover1=std(nums(gooddens1)./dens1(gooddens1));
stdpercentover2=std(nums(gooddens2)./dens2(gooddens2));