function spk = spkdet(tr)
%spk = spkdet(tr)
%    detects spikes in the trace matrix tr
%    temporal resolution must be >~1000 ms/frame

warning off
for c = 1:size(tr,1)
ctr = (tr(c,:)-mean(tr(c,1:50)))/mean(tr(c,1:50));
ctr = ctr - calcbase(ctr,20);
ctr = ctr / std([ctr(find(ctr>0)) -ctr(find(ctr>0))]);
spk{c} = find(ctr<-3.5);
end
warning on