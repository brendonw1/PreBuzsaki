function spk = read_txt_spk(fin)
%spk = read_text_spikes(fin)
%    reads spikes times from a text file fin

fid = fopen(fin);
for c = 1:6
    str = fgetl(fid);
end
spk = [];
while 1
    str = fgetl(fid);
    if ~ischar(str)
        break
    end
    spk = [spk str2num(str)];
end

fclose(fid);