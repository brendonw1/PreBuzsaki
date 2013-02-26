function spkdet200 = spkdet200(tr,fl)

nt = fitexp(tr);
mn = intersect(find(nt(2:end-1)-nt(1:end-2)<0),find(nt(2:end-1)-nt(3:end)<0))+1;
mx = intersect(find(nt(2:end-1)-nt(1:end-2)>0),find(nt(2:end-1)-nt(3:end)>0))+1;
if size(mn,2)>size(mx,2)
   mn = mn(1:end-1);
end
if size(mx,2)>size(mn,2)
   mx = mx(2:end);
end
if mn(1)<mx(1)
   mx = [1 mx];
   mn = [mn size(tr,2)];
end
f = find((tr(mn)-tr(mx))./tr(mx)<-0.1);
plot(nt);
hold on
for c=f
   plot([mn(c) mn(c)],ylim,'r:');
end