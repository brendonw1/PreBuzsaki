function findsingleactives(numberofmovies,numberofframes,cutoff,areath)
% Takes in movies from frames, assuming frames have names of
% "positiveX(framenumber).tif".  You must enter the number of movies and the
% number of frames in the series of files (with names that are indexed such
% that "X" above increases with each movie number taken, and the frame
% number increases within each movie... ie after you save a movie of the
% format "positive2" with "Save As... Image Sequence" in Image J.
% Then runs a subtraction between the first frame and last frame of
% each movie and then draws a contour around that.
% Too slow, it's faster to use the "evaldf0s" macro for ImageJ and just look
% by eye

movienumber=1;
basename='positive';
%period='.';
framenumber=1;
tifsuffix='.tif';

moviesmatrix=zeros(256,256,numberofframes,numberofmovies);
df0matrix = zeros(256,256,numberofmovies);

while movienumber <= numberofmovies;
    framenumber=1;
    while framenumber <=numberofframes; 
        moviestring = num2str(movienumber);
        framestring = num2str(framenumber);
        filename = strcat(moviestring,basename,framestring,tifsuffix); 
        moviesmatrix(:,:,framenumber,movienumber) = imread(filename);
        
        framenumber = framenumber+1;
    end
    df0matrix(:,:,movienumber) = moviesmatrix(:,:,numberofframes,movienumber)-moviesmatrix(:,:,1,movienumber);
    movienumber=movienumber+1;
end


movienumber=1;
while movienumber <= numberofmovies;
    figure(movienumber);
    imagesc(df0matrix(:,:,movienumber));
	colormap(gray);
	set(gcf,'position',[1, 29, 1024, 672]);
	set(gca,'ydir','reverse');
	axis equal;
	axis off;
	hold on;
	[c h] = contour(df0matrix(:,:,movienumber),[cutoff cutoff],'-r');
	a = {};
	for c = 1:size(h,1);
       coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
       if coords(1,:) == coords(end,:);
          if poly_area(round(coords(1:end-1,:))) > areath;
             a{size(a,2)+1} = coords(1:end-1,:);
          else
             delete(h(c));
          end
       else
          delete(h(c));
       end
	end
    
    movienumber=movienumber+1;
end
whos
    


% then show figure of last frame with contours... label with movie number
% 
% later... apply same contours found in each movie to all other movies...
% look for repeaters?