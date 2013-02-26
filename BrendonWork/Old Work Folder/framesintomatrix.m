function moviematrix=framesintomatrix;
% opens a series of saved frames from multiple movies (each frame is an image) and puts pixel values from
% each into a 2D matrix... then each of those frames is piled on top of
% eachother to make a 3D matrix and then the 3D matrices of many movies are
% also combined to make a 4D matrix output containing the pixel values from
% each frame of each movie specified by the intial inputs.

% example frame file names: 032503#220001.tif
% basename = 032503#2
% movienumber = 2(will increase for each movie... to 3, 4, 5...)
% middle (unchanging) = 000 (if there will a transition in the framenumber
% from single to double digits, ie 9 to 10... make middle = "00" only, and the other digit will be handled automatically by this program
% framenumber = 1 (will increase to framenumber + number of frames - 1 for each movie
% suffix = .tif


numberofmovies= input ('enter number of movies to be analyzed: ');
maxframes = input ('enter number of frames in the movie with the most frames: ');

basename = input ('enter base name of movies to be opened, up until any sort of counting index in the names: ','s');
initialmovie= input ('enter first number of index that changes over the movies to be opened: ');
% middle = input ('enter static part of the file names between the two counter indices: ','s');
% initialframe =input ('enter first number of frame index: ');
suffix = input ('enter suffix associated with the file type, including the period before it (ie ".tif"): ','s');

% initialframe=framenumber;

moviematrix=zeros(256,256,maxframes,numberofmovies);
[width height frames movies]=size(moviematrix)
moviecounter=1;
for movienumber = initialmovie : (initialmovie + numberofmovies - 1); 
    moviestring = num2str(movienumber);
    filename = strcat(basename,moviestring,suffix)%establishing name of movie to be opened
    
    info=imfinfo(filename); 
    numberofframes=size(info,2);%gives number of frames in the current movie
    
%     framecounter=1;
%     for framenumber = initialframe : (initialframe + numberofframes - 1); 
      for framenumber = 1 : numberofframes; 
          
%         framestring = num2str(framenumber);

%         if (initialframe+numberofframes-1>9 & initialframe<10 & framenumber<10);
%             filename = strcat(basename,moviestring,middle,'0',framestring,suffix); 
% 		else
% 			filename = strcat(basename,moviestring,middle,framestring,suffix);
% 		end

%         filename = strcat(basename,moviestring,suffix);
        moviematrix(:,:,framenumber,moviecounter) = imread(filename,framenumber);
%         framecounter=framecounter+1;
    end 
     moviecounter=moviecounter+1;
end