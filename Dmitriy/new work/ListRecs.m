%Lists all recordings in Rosa's recordings folder

for c = 1:21; cd(mt(c).name); imt = dir; for d = 3:size(imt,1); if imt(d).isdir; cd(imt(d).name); if ~isempty(dir([imt(d).name '.abf'])); fprintf([imt(d).name ' 1\n']); end; cd ..; end; end; cd ..; end