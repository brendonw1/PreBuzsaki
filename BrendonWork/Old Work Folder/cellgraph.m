function cellgraph
% this is called on by "viewplots" whenever a "cell" is clicked on in the
% figure made by that function this is executed.  It plots a series of
% lines: one for each movie, the x axis is the frame number in each movie,
% the y axis for the mean brightness value of that contour in a frame.

cellmeans=evalin('caller','cellmeans');%bring in matrix of cell values from the calling function
numb=str2num(get(gco,'tag'));%numb equals the number of the cell contour
figure(numb); %creates a figure with a figure number equal to the cell number of the picked
hold on;
plot(cellmeans(:,:,numb));
legendmatrix=[];
for z=1:size(cellmeans,2)
    a=num2str(z);
    leg=strcat('Movie ',a);
    legendmatrix=strvcat(legendmatrix,leg);
end
legend(legendmatrix,-1);%creates a legend, labelling each line as representing one movie
titlestring=strcat('Plots for cell',num2str(numb));
title=titlestring;