function image=localize2(image,filt);
% This function does the same thing as Dmitriy Aronov's "localize" function
% but it is faster.  Each pixel in the original image is divided by the mean
% value of a square of pixels surrounding it.  The area of the square is 
% specified by the "filt", which gives the "radius" of a square surrounding
% each point.  The square will be (2 x filt) + 1 in width.
% Here by mean filtering is used to create a second image, and then doing pixel-wise
% division of the original image by the mean filtered image.

image=double(image);
filt=2*filt+1;%width of square (must be an odd number)
filt=ones(filt)./(filt^2);%making a square filter;
image2=imfilter(image,filt);%create a mean-filtered image... each pixel equals the mean of the surrounding pixels in the original image
image=image./image2;%divide original pixels by their local mean