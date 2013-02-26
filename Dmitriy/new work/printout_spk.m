function [baseln, spk] = printout_spk(tr,tempres)

spk = [];

baseln = myfilter(tr,round(1/tempres*325));
k = tr - baseln;

spk = find(myfilter(k/std([k(find(k>0)) -k(find(k>0))]),2)<-1);
f = intersect([1 find(k(2:end)-k(1:end-1)<0)+1],[find(k(1:end-1)-k(2:end)<0) size(k,2)]);
spk = intersect(spk,f);