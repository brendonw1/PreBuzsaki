function filerev(fin, num)
%filerev(fin, num)
%   Reverses strings representing numbers to make Matlab binary files
%   compatible with ImageJ binary files. Num is the string length.

fid = fopen(fin);
st = fread(fid,[num inf],'char');
fclose(fid);
delete(fin);
fid = fopen(fin,'w');
fwrite(fid,flipud(st),'char');
fclose(fid);