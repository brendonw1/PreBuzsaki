function pixels=opentif(moviename);
%Opens tiff stacks much more quickly than inputmovie.m... output is 3D
%pixel matrix

%%%preallocate matrix
[fid,message]=fopen(moviename,'rb','ieee-le');
[a,count]=fread(fid,inf,'uint16');
info=imfinfo(moviename);
numframes=size(info,2);
height=info(1).Height;
width=info(1).Width;
totalpixels=width*height*numframes;
a(1:(size(a,1)-totalpixels))=[];
a=(reshape(a,[width height])');

figure;imagesc(a);colormap gray

pixels=a;

% header at beginning of each frame