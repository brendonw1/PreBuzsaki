function pickcells(contours,pixels,framenumber,movienumber);

% Takes raw movie data, and allows user to click on cells which are active
% as show in df/f0 frames with contours drawn over.  Each time a cell is
% clicked, it is recorded as being "active" in that particular
% frame.  Output is the matrix of cells which were on.

% movienumber=floor((framenumber-1)/size(pixels,3))+1;
assignin('base','framenumber',framenumber);
assignin('base','movienumber',movienumber);

% denominator=pixels(1:size(pixels,1),1:size(pixels,2),1:(size(pixels,3)-1),1:size(pixels,4));
df=diff(pixels,1,3);
% df=df./denominator;
% df=normalize(df);%normalized each df movie within itself
% df2=reshape(df,[size(df,1) size(df,2) (size(df,3)*size(df,4))]); %a series of df frames, not broken into movies

% oncells=zeros(size(df2,3),length(contours));
% assignin('base','oncells',oncells);

figure;imagesc(-(df(:,:,framenumber,movienumber)));
colormap gray;
hold on;
axis equal;
axis off;
set(gcf,'units','normalized');
set(gcf,'position',[0.4398    0.1689    0.6516    0.6465]);
for x=1:length(contours);
    handle=plot(contours{x}(:,1),contours{x}(:,2),'k');%plot a black patch for each contour
    hn=['handle',num2str(x),'=handle;'];
    eval(hn);
    handlename=strcat('handle',num2str(x));%make a unique handle for each cell, with names "handle1","handle2"...
    set(eval(handlename),'tag',num2str(x),'buttondownfcn','insertactive');%sets value in oncells to 1 when contour is clicked
end


function insertactive

oncells=evalin('base','oncells');%bring in "oncells" matrix from base workspace

framenumber=evalin('base','framenumber');
movienumber=evalin('base','movienumber');
numb=str2num(get(gco,'tag'));

oncells(framenumber,movienumber,numb)=1;%assign a "1" in the frame and movie where a paricular cell is active 
assignin('base','oncells',oncells);%call 

numb2=num2str(numb);%display acknowledgement of assignment of active cell
display=strcat('cell #',numb2,' assigned as on');
disp(display)

    
    %put wait until hits return to advance to next frame
