function mat2tlist(spk,tlist)
%mat2tlist(matfile,tlist)
%   converts a rasterplot mat file into a tlist file

fid = fopen(tlist,'w');

for c = 1:size(spk,2)
    for d = 1:size(spk{c},2)
        fprintf(fid,num2str(spk{c}(d)));
        fprintf(fid,char(13));
    end
    if c<size(spk,2)
        fprintf(fid,'-1');
        fprintf(fid,char(13));
    else
        fprintf(fid,'-2');
    end
end

fclose(fid);