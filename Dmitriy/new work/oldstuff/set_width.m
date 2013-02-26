function set_width(input,output,width)
%set_width(input,output,width)
%   Adds spaces at the end of all lines in the file to make them the same width.
%   If width is empty, it is set to the longest line in the file

fin = fopen(input,'r');
if fin == -1
   error('Error reading input file!');
end
fout = fopen(output,'w');
if fout == -1
   error('Error creating output file!');
end

st = fread(fin,'char')';
f = find(st == 13);
g = find(st == 10);
rp = f - [-1 f(1:end-1)] - 2;
st(f) = rp;
if isempty(width)
   width = max(rp);
end

st = char(st);
for c = min(rp):max(rp)
   st = strrep(st,[char(c) char(10)],[repmat(' ',1,width-c) char(13) char(0) char(10)]);
end

st = strrep(st,char(0),'');
fwrite(fout,st);
fclose(fin);
fclose(fout);