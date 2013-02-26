function lesscontours=opticalspiketrigger(movies,contours);
%   Finds and displays information preceding, following or during the
%   firing of each cell throughout the course of a set of movies.  "Movies"
%   is a matrix of pixel values from a collection of movies.  Contours is
%   the traces of the cells in those movies.

% idea: elim cells which were active less than 3 times?


movies=double(movies);
[a b c d]=size(movies);%a is x, b is y, c is frames, d is movies
movies2=reshape(movies,[a b c*d]); %movies2 is now a matrix of a series of frames of all movies... 
%... 3D matrix with D1 and D2 being x and y axes of frame, D3 is the frame
% number... in series, not divided up into movies... movie 1 frames come
% first, movie 2 frames next, in order, movie 3, etc...

diffmovies=diff(movies,1,3);
diffmovies2=reshape(diffmovies,[a b ((c-1)*d)]);

means=contourvalues (contours,movies);
%output is a matrix of mean pixel values for a number of cells from
%a number of movies (each with multiple frames).  Format is 
%(frames) x (movies) x (cells).

[slopes, on, activeon, activemeans] = ons(means);
[e f g]=size(activeon); 

moviecells=sum(on,1);
moviecells=squeeze(moviecells);
moviecells2=logical(moviecells);
moviecells3=double(moviecells2);
%(movies by cells) matrix... 1 if cell was active in that movie, 0 if it
% wasn't

inactivecells=sum(moviecells3);
inactivecells=logical(inactivecells); %1's and 0's for whether each cell was active at least 3 times
inactivecells2=find(inactivecells==0); %gives trace numbers which show no activity
% inactivecells2=find(inactivecells<3);

lesscontours=celldelete(contours,inactivecells);
    
activemeans2=ipermute(activemeans,[2 3 1]);
activemeans2=reshape(activemeans2,[g (e+1)*f]);
activemeans2=activemeans2';%reshaped so activemeans2 = (all frames (not divided up into movies)) x (cells)

activeon2=ipermute(activeon,[2 3 1]);
activeon2=reshape(activeon2,[g e*f]);
activeon2=activeon2';%same as above

[r ce]=find(activeon2==1); %ce gives cell number on in a particular frame, r gives the corresponding frame number for that event

minusone=cell(g,1);%cell array containing one matrix for each cell
plusone=cell(g,1);
sameone=cell(g,1);
% minusframe=cell(g,1);%cell array containing one matrix for each cell
% plusframe=cell(g,1);
% sameframe=cell(g,1);
minusdiffframe=cell(g,1);
samediffframe=cell(g,1);
plusdiffframe=cell(g,1);

% ce will be number within the cell array... use r to get the right frame;
for counter=1:length(ce);
    cellnumb=ce(counter);
    framenumber=r(counter)+floor(r(counter)/(e+1));%accounts for fact that "activeon" movies are each one frame less than non-subtracted movies
    frameformovie=rem(framenumber,c); 
%     if frameformovie==0;
%         frameformovie=8;
%     end
%     movieformovie=floor(framenumber/c)+1;
    if rem(framenumber,c)~=1; %make sure not to use first frame of one movie to call on the last frame of another
        minusone{cellnumb}(:,size(minusone{cellnumb},2)+1)=squeeze(activemeans2(framenumber,:));%gives cell brightness values for the frame just preceeding the one where a cell is active
%         minusframe{cellnumb}(:,:,size(minusframe{cellnumb},3)+1)=squeeze(movies2(:,:,framenumber));%inputs into the cell array the movieframe of raw pixel values just preceeding the frame where a cell turned on
        minusdiffframe{cellnumb}(:,:,size(minusdiffframe{cellnumb},3)+1)=squeeze(diffmovies2(:,:,r(counter)-1));%adds preceding df image into cell array
    end
    
    sameone{cellnumb}(:,size(sameone{cellnumb},2)+1)=squeeze(activemeans2(framenumber+1,:));%same as above, but for same frame as cell became active
%     sameframe{cellnumb}(:,:,size(sameframe{cellnumb},3)+1)=squeeze(movies2(:,:,framenumber+1));%inputs frame where cell turned on
    samediffframe{cellnumb}(:,:,size(samediffframe{cellnumb},3)+1)=squeeze(diffmovies2(:,:,r(counter)));%collects df frames where cell turned on
    
    if rem(framenumber,c)~=0; %make sure not to use last frame of one movie to call on the first frame of another
        plusone{cellnumb}(:,size(plusone{cellnumb},2)+1)=squeeze(activemeans2(framenumber+2,:));%again, one frame later... just change the amount added or subtracted from framenumber to generate diff matrices
%         plusframe{cellnumb}(:,:,size(plusframe{cellnumb},3)+1)=squeeze(movies2(:,:,framenumber+2));%inputs frame after the one where cell turned on
        plusdiffframe{cellnumb}(:,:,size(plusdiffframe{cellnumb},3)+1)=squeeze(diffmovies2(:,:,r(counter)+1));%adds following df image into cell array    
    end 
end

for counter2=1:length(minusdiffframe);%to be used for a number of element-by-element operations on the cell arrays created above
%     minusframe{counter2}(:,:,1)=[];%eliminating the first frame of each matrix, since they are equal to zeros... an artifact
%     sameframe{counter2}(:,:,1)=[];
%     plusframe{counter2}(:,:,1)=[];
    minusdiffframe{counter2}(:,:,1)=[];%eliminating the first frame of each matrix, since they are equal to zeros... an artifact
    samediffframe{counter2}(:,:,1)=[];
    plusdiffframe{counter2}(:,:,1)=[];    
    minusone{counter2}(:,:,1)=[];%eliminating the first frame of each matrix, since they are equal to zeros... an artifact
    sameone{counter2}(:,:,1)=[];
    plusone{counter2}(:,:,1)=[];
%     avgminusframe(:,:,counter2)=mean(minusframe{counter2},3);%averaging all the frames found from each cell
%     avgsameframe(:,:,counter2)=mean(sameframe{counter2},3);
%     avgplusframe(:,:,counter2)=mean(plusframe{counter2},3);
    avgminusdiffframe(:,:,counter2)=mean(minusdiffframe{counter2},3);%averaging all the df frames found from each cell
    avgsamediffframe(:,:,counter2)=mean(samediffframe{counter2},3);
    avgplusdiffframe(:,:,counter2)=mean(plusdiffframe{counter2},3);
    figure(counter2);
    subplot(2,2,1);imagesc(avgminusdiffframe(:,:,counter2));colormap(gray);title('Prior frame'); hold on;
    plot(lesscontours{counter2}([1:end 1],1),lesscontours{counter2}([1:end 1],2),'-r');
    subplot(2,2,2);imagesc(avgsamediffframe(:,:,counter2));colormap(gray);title('Frame of cell firing'); hold on;
    plot(lesscontours{counter2}([1:end 1],1),lesscontours{counter2}([1:end 1],2),'-r');
    subplot(2,2,3);imagesc(avgplusdiffframe(:,:,counter2));colormap(gray);title('Following frame'); hold on;
    plot(lesscontours{counter2}([1:end 1],1),lesscontours{counter2}([1:end 1],2),'-r');
end
