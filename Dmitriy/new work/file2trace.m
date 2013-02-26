function a = file2trace(fin)
%a = file2trace(fin)
%   converts a *.trc files into a trace matrix

filerev(fin,8);
fid = fopen(fin);
nc = fread(fid,1,'double');
ns = fread(fid,1,'double');
m = fread(fid,[ns nc],'double');
a = m';
filerev(fin,8);