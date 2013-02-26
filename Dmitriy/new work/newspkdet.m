function newspkdet = newspkdet(trc,rs)

tr = myfilter(trc,round(1000/rs));
base = baseline(tr,15);
dx = tr(2:end)-tr(1:end-1);
flt = myfilter(trc,round(2000/rs));
dx2 = flt(2:end)-flt(1:end-1);

ind = 0.065*mean(abs(dx))/mean(abs(dx2));
nt = tr - base;
f = find(-nt/mean(nt)/ind<-15);
f = intersect(f,find(nt<min(nt)*1/3));
mn = intersect(find(nt(3:end)-nt(2:end-1)>0),find(nt(1:end-2)-nt(2:end-1)>0))+1;
f = intersect(f,mn);


k = [];
for c = 1:size(f,2)
   vl = [1 find(nt>0.5*nt(f(c))) size(nt,2)];
   sl = vl(find(vl<f(c)));
   bf(c) = sl(end);
end
for c = 1:size(f,2)
   k(c) = 1;
   ch = 0;
   bg1 = 0;
   bg2 = 0;
   if c>1 & k(c-1)==1 & f(c-1) > bf(c)
      ch = 1;
      bg1 = f(c-1);
   end
   if min(nt(bf(c):f(c)-1))<nt(f(c))
      ch = 1;
      bg2 = find(nt(bf(c):f(c))==min(nt(bf(c):f(c))))+bf(c)-1;
   end
   if ch == 1
      bf(c) = max([bg1 bg2]);
   end
   fn = find(nt(bf(c)+1:f(c))==max(nt(bf(c)+1:f(c))))+bf(c);
   bf(c) = fn(end);
   
   ch = 0;
   bg1 = size(nt,2)+1;
   vl = [find(nt>nt(bf(c))) size(nt,2)];
   sl = vl(find(vl>f(c)));
   af(c) = sl(1);
   if min(nt(f(c)+1:af(c)))<nt(f(c))
      ch = 1;
      bg1 = find(nt(f(c):af(c))==min(nt(f(c):af(c))))+f(c)-1;
   end
   if ch == 1
      af(c) = bg1;
   end
   fn = find(nt(f(c):af(c)-1)==max(nt(f(c):af(c)-1)))+f(c)-1;
   af(c) = fn(1);
   
   ar = sum(1-tr(bf(c):af(c))/mean([tr(bf(c)) tr(af(c))]))/abs(mean(nt))/ind*rs;
   if ar < 50
      k(c) = 0;
   end
end
if ~isempty(k)
   f = f(find(k==1));
   bf = bf(find(k==1));   
   af = af(find(k==1));
end
   
   
   
newspkdet = f;

%return
plot(tr)
hold on
for c = 1:size(newspkdet,2)
   plot([newspkdet(c) newspkdet(c)],ylim,':r');
   %plot([bf(c) bf(c)],ylim,':g');
   %plot([af(c) af(c)],ylim,':k');
end