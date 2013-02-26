function tms = readstates(fin)
%tms = readstates(fin)
%   reads the times of the up states in file fin

fid = fopen(fin);
for c = 1:3
    st = fgetl(fid);
end
st = fgetl(fid);
nst = str2num(st(15:end-1));
for c = 1:2;
    st = fgetl(fid);
end
for c = 1:nst
    st = fgetl(fid);
    num = str2num(st);
    nm(c) = num(1);
end
nm = sort(nm);

fclose(fid);

tms = reshape(nm,2,size(nm,2)/2)';