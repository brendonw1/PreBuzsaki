function actives(on);
% Carries out and plots analyses on that data in a 4-subplot figure.

% [slopes, on, activeon, activevalues] = ons(values);

moviecells=sum(on,1);
moviecells=squeeze(moviecells);
moviecells2=logical(moviecells);
moviecells3=double(moviecells2);
%(movies by cells) matrix... 1 if cell was active in that movie, 0 if it
% wasn't

onlogical=logical(on);
activeonlogical=logical(activeon);

[a b c]=size(values);
[d e f]=size(activeon);
% calculating some basic values from the matrices above



movietotals=sum(moviecells3,2);
%a matrix which is 2D: movienumber x cellnumber.  1 appears if a cell is
%active at any point in a movie, 0 if it was not.
moviepercentoftotals=movietotals/c;
%gives proportion of all traced cells that were in each movie

everactives=sum(moviecells2);
everactives=logical(everactives);
everactives=sum(everactives);
%total number of cells active at any point in any movie
moviepercentofactives=movietotals/everactives;
%proportion of above which are active in each movie
subplot(2,2,1); plot (moviepercentofactives);
xlabel('Movie number');
ylabel('proportion of cells active'); 
% title 'Percent of all active cells active in each movie';

celltotals=sum(moviecells2,1);
for index=1:e;
    numbers=find(celltotals==index);
    numbers2(index)=length(numbers)*100/f;
end
    %number of movies each cell is active in
subplot(2,2,2);plot(numbers2); ylim ([0 100]);
xlabel('Number of movies each cell is on');
ylabel('% of cells');
% title ('Distribution of number of movies each cell comes on in')

perframe=sum(on,3);
% number of cells on per frame
meanperframe=mean(perframe,2);
subplot(2,2,3);plot(perframe);hold on;plot(meanperframe,'-h');
% title ('Number of cells on in each frame of each movie')
xlabel('Frame number');
ylabel('Number of cells active');




befores=cumsum(perframe);
befores=circshift(befores,1);
befores(1,:)=0;
befores=befores*(-1);

rperframe=flipdim(perframe,1);
afters=cumsum(rperframe);
afters=circshift(afters,1);
afters(1,:)=0;
afters=flipdim(afters,1);

relatives=befores+afters;
relatives=repmat(relatives,[1 1 f]);
relatives2=shiftdim(relatives,2);

activeon2=shiftdim(activeon,2);
% onlogical2=shiftdim(onlogical,2);
oncells=find(activeon2==1);
oncells=rem(oncells,((d-1)*f));
oncells(find(oncells==0))=(d-1)*f;
oncells=rem(oncells,f);
oncells(find(oncells==0))=f;
%finds the contour number corresponding to a "1" representing an active
%cell in activeon2

eachrelative=relatives2(activeonlogical);
%returns the relative value of each active cell in oncells
eachrelative2=[eachrelative oncells];

relativecell={};
for index=1:f;
    cellnumb=find(oncells==index);
    relativecell{index}=eachrelative(cellnumb);
    relativedevs(index)=std(relativecell{index});
end

relativevariance=sqrt(relativedevs);
sortedvariance=sort (relativevariance);
meanvariance=mean (relativevariance);
subplot(2,2,4); hist(sortedvariance,20);
xlabel('Variance of relative position of each cell in each movie (in number of cells)');
ylabel('Number of cells');

%maybe find a way to only look at first occurence within a movie



% 
% offs=find(slopes>500);
% off=zeros(size(slopes));
% off(offs)=1;
% 
% 
% state