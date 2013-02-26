function updateanalysis

godesk
cd new/project
mt = dir('*mat');

for c = 1:size(mt,1)
    fprintf([num2str(c) ' of ' num2str(size(mt,1)) ' ']);
    load(mt(c).name);
    sz = size(tr,2);
    ar = [];
    ct = [];
    for d = 1:size(cn,2)
        ct(d,:) = centroid(cn{d});
        ar(d) = poly_area(cn{d});
    end
    spk = printout(mt(c).name);
    save(mt(c).name,'-append','spk','sz');
    delete(gcf);
    s = rast2mat(spk,sz);
    thr = thresholds(mt(c).name,5,5,1000);
    fprintf('\n');
    th = thr(6);
    ispk = 0;
    [tpk,wd] = findpeaks(s,thr,6);
    blocker = 'Unknown';
    save(['../../newanalysis/' mt(c).name],'cn','tr','spk','sz','ar','ct','s','thr','th','ispk','tpk','wd','blocker');
    delete(mt(c).name);
end