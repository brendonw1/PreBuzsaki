function readframes(numberofmovies,numberofframes)

basename='rop';
movienumber=1;
period='.';
% framenumber=1;
tifsuffix='.tif';

moviesmatrix=zeros(256,256,numberofframes,numberofmovies);


while movienumber <= numberofmovies;
    framenumber=1;
    while framenumber <=numberofframes; 
        moviestring = num2str(movienumber);
        framestring = num2str(framenumber);
        filename = strcat(basename,moviestring,period,framestring,tifsuffix); 
        moviesmatrix(:,:,framenumber,movienumber) = imread(filename);
        
        framenumber = framenumber+1;
    end
    movienumber=movienumber+1;
end


averagemovie = mean (moviesmatrix,4);
make equivalent of lim.tif? (make each point equal to avg of 25 points around)

run "findcells"
close each matrix, by adding a last value equal to the first
use inpolygon once on each contour to set up which points to look at for that contour
    -> gives boolean 
    -> for mean, set .5 = 0, then sum to find total number for each contours       
    -> from each movie, use "if" to make a new "movie", each "frame" is a vector with values from within the contour (same number of frames as original movie, just extract from big vector)
    -> actually make a big matrix for each orignal movie... ie make another dimension be index of all contours (cell array?)
avg the values within each contour, for each frame
then plot those as graph of mean contour value across frames

use the graphing thing to point out cells, as in "showzplots" (don't forget to add grid)
save avg movie as series of frames? (Then put together as stack with ImageJ)
still save contours file?


%input negative movies, subtract one from each 8 positives
%set up new matrix with dimensions = number of traces x number of movies

%use contours to read specific pixels within moviesmatrix, find
%   MEANS within those areas -> into new matrix created
%above is equivalent to traces.trc file


%interp2 to smooth contours?




