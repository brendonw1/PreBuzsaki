function activities(values);
% determines from slopes of changes in brightness between means of
% individual cells from frame to frame whether each cell turned on (ie
% decreased it's fura/Calcium signal).  Also carries out and plots analyses
% on that data.

slopes=diff(values,1,1);
figure(1);

ons=find(slopes<-1000);
on=zeros(size(slopes));
on(ons)=1;

[a b c]=size(values);

activecells=sum(ons,1);
activecells=squeeze(activecells);
activecells2=logical(activecells);
activecells3=double(activecells2);

movietotals=sum(activecells3,2);
%a matrix which is 2D: movienumber x cellnumber.  1 appears if a cell is
%active at any point in a movie, 0 if it was not.
moviepercentoftotals=movietotals/c;
%gives proportion of all traced cells that were in each movie
plot (moviepercentoftotals);

everactives=sum(activecells2);
everactives=logical(everactives);
everactives=sum(everactives);
%total number of cells active at any point in any movie
moviepercentofactives=movietotals/everactives;
%proportion of above which are active in each movie










% 
% offs=find(slopes>500);
% off=zeros(size(slopes));
% off(offs)=1;
% 
% 
% state