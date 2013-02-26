region.imagesize = size(a);
region.diameter = locdm;
region.cutoff = thres;
region.lowarea = lowar;
region.higharea = highar;
region.isdetected = isdetected;
region.pilimit = pilim;
region.isadjusted = isadjust;
region.contours = {};
region.location = [];
for c = 1:length(cn)
    for d = 1:length(cn{c})
        if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c)
            region.contours{length(region.contours)+1} = cn{c}{d};
            region.location = [region.location c];
        end
    end
end

[filename2, pathname2] = uiputfile([filename(1:end-3) 'mat'], 'Save file as');
if ~isstr(filename2)
    return
end
fnm = [pathname2 filename2];

save temp.mat region fnm
delete(gcf)
clear
load temp.mat region fnm
delete temp.mat
save(fnm,'region');
clear fnm