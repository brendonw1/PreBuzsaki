[filename2, pathname2] = uiputfile([filename(1:end-3) 'mat'], 'Save file as');
if ~isstr(filename2)
    return
end
fnm = [pathname2 filename2];
filename = filename2;

region.onsets = spk;
region.offsets = dec;
save(fnm,'region');