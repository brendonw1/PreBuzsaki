function denoisezplot
%Denoises intensity vs time plot of individual pixels over time in movie files using a
%moving average.  Opens only first 10 images.

global inputarray outputarray;

number = 5;
%input ('enter number of images in stack (l0 or less): ');
filebase = '011603#2000';
%input ('enter base name of images upto number "9", without the final index number, without suffix: ','s');
fileindex = 0;
%input ('enter (index) number of first image: ');
%filetype = input ('enter filetype suffix of images: ','s')
inputarray = zeros(256,256,number);
outputarray = inputarray;
r=0
n=fileindex;
m=fileindex+1;


while n <= number;
    index = num2str (n);
    name = [filebase, index];
    inputarray(:,:,n-fileindex+1) = imread (name,'tif');
    n=n+1;
    r=r+1;
end


for i=1:256;
    for j = 1:256;
        for k = 2:number-1;
            outputarray (i,j,k) = inputarray (i,j,k);
            %.5*inputarray (i,j,k) + .25*inputarray (i,j,k-1) + .25*inputarray (i,j,k+1);
        end
    end
end

while m <= number-1;
    index = num2str (m);
    %index = [index, '.']
    name = ['denoisedz', index,'.tif'];
    imwrite (outputarray(:,:,m),[name]);
    m=m+1;
end


end

%take all of a particular 3rd dimensional column
%set each spot equal to some moving average
%repeat for each column (actually do all at once in first place)
%unconcatenate
%save each as separate tif file
%put back together as movie in ImageJ