function viewplots(inputimage,contours,cellmeans)
%cellmeans comes from contourvalues and is 3D: frames x movies x cells.
%This function brings up the image used to generate contours of the cells
%in "labelcells" or "findcells" and draws the contours on them and labels
%them by number.  When a contour is clicked a graph of it's profile over
%various movies... the curve for each movie is labeled with the movie
%number.

i=imread(inputimage);
f=figure(10000);
set(gcf,'position',[30, 30, 800, 800]);
imagesc(i);
colormap(gray);
hold on
for x=1:length(contours);
    handle=patch(contours{x}(:,1),contours{x}(:,2),'k');%plot a black patch for each contour
    label=num2str(x);
    h=text(contours{x}(1,1),contours{x}(1,2),label);%create a numeric label for each cell
    set(h,'color','g','hittest','off');%green labels, which will not interfere with clicking on cells
    hn=['handle',num2str(x),'=handle'];
    eval(hn);
    handlename=strcat('handle',num2str(x));%make a unique handle for each cell, with names "handle1","handle2"...
    set(eval(handlename),'hittest','on','tag',num2str(x),'buttondownfcn','cellgraph');%call on cellgraph whenever a cell is clicked on
end