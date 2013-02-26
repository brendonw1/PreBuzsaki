function [pixels, laststackidx, truestacksize] = ct_readtifstack(moviename,varargin)
%This function reads tifstack movies into matlab.  You must direct matlab
%to the directory your file is in and in quotes type the name of the file
%to be loaded in.  The output, "pixels" will be a 3D matrix of pixel
%values, first two
%dimensions are height and width, third dimension is frame number. 
%   First argument in is always the moviename.  The second argument does
%   not have to be there... if it is there it specifies "outputmode" it 
%   specifies the nature of the output frames... as 2d frames (images) 
%   or as linear vectors (as strings of values).  This can save memory
%   later.  
%   The default outputmode is "frames", user may specify "linear"
% tic
%could generalize bitdepth and matrix precision (8 vs 16 etc)
pixels = [];
outputmode='frames';
maxstacksize = Inf;
startstackidx = 1;
nargs = length(varargin);
for i = 1:2:nargs
    switch(varargin{i})
     case 'outputmode'
      outputmode = varargin{i+1};
     case 'maxstacksize'
      maxstacksize = varargin{i+1};
     case 'startstackidx'
      startstackidx = varargin{i+1};
    end
end
i=imfinfo(moviename);%get basic info about the movie... including size of frames and number of frames
% [i,trash]=imtifinfo(moviename);%get basic info about the movie...
% including size of frames and number of frames
truestacksize=size(i,2);
stacksize = min([maxstacksize truestacksize]);
laststackidx = startstackidx+stacksize-1;
if (laststackidx > truestacksize)
    stacksize = stacksize - (laststackidx - truestacksize);
    laststackidx = truestacksize;
end
height=i(1).Height;
width=i(1).Width;
bitdepth=i(1).BitsPerSample;
if strcmp(i(1).ByteOrder,'little-endian');
	readspec='ieee-le';
elseif strcmp(i(1).ByteOrder,'big-endian');
	readspec='ieee-be';
end
bitdepth=['*uint',num2str(bitdepth)];%will be "*uintX"... should be pretty universal
        
if strcmp(bitdepth,'little-endian');
	readspec='ieee-le';
elseif strcmp(i(1).ByteOrder,'big-endian');
	readspec='ieee-be';
end
pixels=uint16(zeros(1));
switch outputmode
    case 'frames'
        pixels=repmat(pixels,[height,width,stacksize]);%establishing a blank matrix of the size necessary to hold the entire movie... this saves time
    case 'linear'
        pixels=repmat(pixels,[height*width,stacksize]);%establish a blank matrix of pixelnumber x framenumber
end
[fid,message]=fopen(moviename,'rb',readspec);
fidx = 1;
for a=startstackidx:laststackidx
    fseek(fid,i(a).StripOffsets(1),'bof');
    switch outputmode
    case 'frames'
     [im,count]=fread(fid,[width height],bitdepth);
     pixels(:,:,fidx)=im';
    case 'linear'
     [im,count]=fread(fid,[width*height],bitdepth);
     pixels(:,fidx)=im';
     %pixels(:,a) = fread(fid,[width*height],bitdepth)';
    end
    fidx = fidx+1;
end
fclose(fid);
laststackidx = a;