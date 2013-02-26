function pixels=readtiff(moviename);
%reads tiff stacks with multiple frames and puts them into a 3D output 
%matrix (pixels).
%Dimension 1 of the output matrix is width of each frame.  Dimension 2 is
%height.  Dimension 3 is frame number.  

i=imfinfo(moviename);%gets basic info on the file
totalframes=size(i,2);%# of frames in stack

for a=1:totalframes%for each frame...
    pixels(:,:,a)=imread(moviename,a);%... read into one 2D slice of the matrix "pixels"
end
pixels=double(pixels);%converting to a different precision data type, so calculations can be performed more easily