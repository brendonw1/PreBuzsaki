function pixels=readtifstack(moviename,varargin);
%This function reads tifstack movies into matlab.  You must direct matlab
%to the directory your file is in and in quotes type the name of the file
%to be loaded in.  The output, "pixels" will be a 3D matrix of pixel values, first two
%dimensions are height and width, third dimension is frame number. 
%   First argument in is always the moviename.  The second argument does
%   not have to be there... if it is there it specifies "outputmode" it 
%   specifies the nature of the output frames... as 2d frames (images) 
%   or as linear vectors (as strings of values).  This can save memory later.  
%   The default outputmode is "frames", user may specify "linear"



% tic
%could generalize bitdepth and matrix precision (8 vs 16 etc)
if isempty(varargin);
    outputmode='frames';
else
    outputmode=lower(varargin{1});
end

i=imfinfo(moviename);%get basic info about the movie... including size of frames and number of frames
% [i,trash]=imtifinfo(moviename);%get basic info about the movie... including size of frames and number of frames
stacksize=size(i,2);
height=i(1).Height;
width=i(1).Width;
bitdepth=i(1).BitsPerSample;
if strcmp(i(1).ByteOrder,'little-endian');
	readspec='ieee-le';
elseif strcmp(i(1).ByteOrder,'big-endian');
	readspec='ieee-be';
end

bitdepth=['uint',num2str(bitdepth)];%will be "*uintX"... should be pretty universal
        
% if strcmp(bitdepth,'little-endian');
% 	readspec='ieee-le';
% elseif strcmp(i(1).ByteOrder,'big-endian');
% 	readspec='ieee-be';
% end

eval(['pixels=',bitdepth,'(zeros(1));']);
switch outputmode
    case 'frames'
        pixels=repmat(pixels,[height,width,size(i,2)]);%establishing a blank matrix of the size necessary to hold the entire movie... this saves time
    case 'linear'
        pixels=repmat(pixels,[height*width,size(i,2)]);%establish a blank matrix of pixelnumber x framenumber
end
[fid,message]=fopen(moviename,'rb',readspec);
for a=1:stacksize;
    fseek(fid,i(a).StripOffsets(1),'bof');
    switch outputmode
        case 'frames'
            eval(['[im,count]=fread(fid,[width height],''*',bitdepth,''');'])
            pixels(:,:,a)=im';
        case 'linear'
            eval(['[im,count]=fread(fid,[width*height],''*',bitdepth,''');'])
            pixels(:,a)=im';
    end
end
fclose('all');
% toc


% tic
% i=imfinfo(moviename);%get basic info about the movie... including size of frames and number of frames
%% [i,trash]=imtifinfo(moviename);%get basic info about the movie... including size of frames and number of frames
% 
% pixels=uint16(zeros(1));
% pixels=repmat(pixels,[i(1).Height,i(1).Width,size(i,2)]);%establishing a blank matrix of the size necessary to hold the entire movie... this saves time
% for a=1:size(i,2);%for each frame
%     [pixels(:,:,a),trash]=readtif(moviename,a);%read in that frame
% end
% toc