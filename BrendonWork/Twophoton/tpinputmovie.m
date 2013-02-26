function pixels=tpinputmovie(moviename);
%This function reads tifstack movies into matlab.  You must direct matlab
%to the directory your file is in and in quotes type the name of the file
%to be loaded in.  The output, "pixels" will be a 3D matrix of pixel values, first two
%dimensions are height and width, third dimension is frame number. 
  
% tic
i=imfinfo(moviename);%get basic info about the movie... including size of frames and number of frames
totalframes=size(i,2);%record the number of frames

pixels=zeros(i(1).Height,i(1).Width,size(i,2));%establishing a blank matrix of the size necessary to hold the entire movie... this saves time
pixels=uint16(pixels);
for a=1:totalframes%for each frame
    a
    pixels(:,:,a)=imread(moviename,a);
end
% pixels=double(pixels);%make double precision
% toc