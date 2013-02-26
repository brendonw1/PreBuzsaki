function [datapt, deltat, pos] = text2mat(fin)
%[datapt, deltat, pos] = text2mat(fin)
%   extracts data from BuQuin's text trace files

fclose('all');
fid = fopen(fin);
st = fgetl(fid);
numt = str2num(st(18:20));
numdp = str2num(st(55:60));
deltat = str2num(st(78:end));

st = fgetl(fid);
st = st(2:end);
for c = 0:numt-1
   pos(c+1) = str2num(st((13*c+4):(13*c+11)));
end

mt = fscanf(fid,[' ' repmat('%i,',1,numt)]);
datapt = reshape(mt,numt,size(mt,1)/numt);

fclose('all');