function averagedmovies=averageframes(inputmatrix)
% inputmatrix should be the output of the framesintomatrix function... each
% element is a pixel brightness value, and the dimensions are (width x
% height x frame number x movienumber)... ie it's a series of movies in a
% 4D matrix.  This function will average adjacent frames to make new movies 
% composed of averaged frames.  Each movie is 1 frame shorter than the original movies.

[a,b,c,d]=size(inputmatrix);
inputmatrix=double(inputmatrix);

firsts=inputmatrix(:,:,1:c-1,:);
seconds=inputmatrix(:,:,2:c,:);

averagedmovies=firsts+seconds;
averagedmovies=averagedmovies./2;
