function di=comparebycellsdiff(array1,array2,varargin);
% function rat=comparebycells(array1,array2,varargin);
%this function assumes the inputs are in the format created by
%quantifyuptraces or byfiletobycell... with cell # on D1 and recording
%number on D2.  Output is ratios derived from within-cell comparisons

warning off MATLAB:conversionToLogical

if nargin>2;
    numpercell=varargin{1};
else
    numpercell=1;
end

gooda1=find(sum(logical(array1),2)>=numpercell);%find cells that had recorded values in the first matrix
gooda2=find(sum(logical(array2),2)>=numpercell);%in 2nd matrix
good=intersect(gooda1,gooda2);


for a=1:length(good);
    temp1=find(array1(good(a),:));
    temp2=find(array2(good(a),:));
    m1=mean(array1(good(a),temp1));
    m2=mean(array2(good(a),temp2));
    rat(a)=m1./m2;
    di(a)=m1-m2;
end

%%%%%%FOR SHOWING RATIOS%%%%%%%%
% lrat=log(rat);
% figure;
% subplot(2,1,1)
% [n,xout] = hist(lrat);
% bar(xout,n);
% xlim([-max(abs(xout)) max(abs(xout))])
% title (['Distribution of log(measure1/measure2). Mean log(ratio) = ',num2str(mean(lrat)),'.  SD = ',num2str(std(lrat))]);
% subplot(2,1,2)
% [n,xout] = hist(rat);
% bar(xout,n);
% title (['Distribution of Measure1/Measure2). True ratio mean = ',num2str(exp(mean(lrat))),'.  SD = ',num2str(exp(std(lrat)))]);

%%%%%%%FOR SHOWING DIFFERENCES%%%%%%
figure;
[n,xout] = hist(di);
bar(xout,n);
xlim([-max(abs(xout)) max(abs(xout))])
title (['Distribution of measure1-measure2. Mean diff = ',num2str(mean(di)),'.  SD of diff= ',num2str(std(di))]);