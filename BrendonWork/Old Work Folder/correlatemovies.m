function corr=correlatemovies(values);

%correlates matrices reflecting the average numerical values of all
%contours in each frame of multiple movies.  The format of the input matrix
%must be (frame #) x (movie#) x (contour/cell#).  Each movie is correlated
%with each other movie.  Results are in the format of a 4D matrix

% contoursmatrix=ipermute(contoursmatrix,[1 3 2]);  % reformat to (frame#)
% x (contour#) x (movie#)

[a b c]=size(values);

slopes=diff(values,1,1);
slopes2=slopes(1:(size(slopes,1)*size(slopes,2)*size(slopes,3)));

ons=find(slopes<(mean(slopes2)-std(slopes2)));
%address numbers of slopes representing "turning on"
on=zeros(size(slopes));
on(ons)=1;
onlogical=logical(on);

moviecells=sum(on,1);
moviecells=squeeze(moviecells);
moviecells2=logical(moviecells);
moviecells3=double(moviecells2);
%(movies by cells) matrix... 1 if cell was active in that movie, 0 if it
% wasn't

inactivecells=sum(moviecells3);
inactivecells=logical(inactivecells); %1's and 0's for whether each cell was ever active
inactivecells2=find(inactivecells==0); %gives trace numbers which show no activity

activeon=on;
activeon(:,:,inactivecells2)=[];
activeonlogical=logical(activeon);
[d e f]=size(activeon);
%gives a matrix of ons only for cells which have an "on" in some frame of
%some movie

movie=activeon(:,1,:);
movie=squeeze(movie);
% for a movie (of frames,cells)
for counter=1:size(movie,1);
    shifted=circshift(movie,counter-1);
    corr(:,:,counter)=shifted.*movie;
end

corr=sum(corr);
corr=squeeze(corr);
corr=sum(corr);
corr=squeeze(corr);
max=max(corr);
corr=corr./max;

plot (0:size(movie,1)-1,corr);
xlabel('Shift');
ylabel('Correlation');

% for counter1=1:size(contoursmatrix,3);
%     for counter2=1:size(contoursmatrix,3);
%         correlations(:,:,counter1,counter2)=xcorr2(contoursmatrix(:,:,counter1),contoursmatrix(:,:,counter2));
%     end
% end


