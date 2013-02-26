function phasepolar = phasepolar(cell)

cell1 = cell(1:8);
cell2 = [cell(1:7) cell(9)];

load(['c:\windows\desktop\paper\hist\' cell1 '.mat']);
sz = size(hst)/16;
for c = 1:16
   hs1(c,:) = mean(hst((c-1)*sz+1:c*sz,:));
end
hs1 = [hs1; hs1(1,:)];
mx1 = max(sum(hs1,2));
load(['c:\windows\desktop\paper\hist\' cell2 '.mat']);
for c = 1:16
   hs2(c,:) = mean(hst((c-1)*sz+1:c*sz,:));
end
hs2 = [hs2; hs2(1,:)];
mx2 = max(sum(hs2,2));
if mx2>mx1
   t = hs1;
   hs1 = hs2;
   hs2 = t;
end
polar((0:16)'/8*pi,sum(hs1,2),'-r');
hold on;
polar((0:16)'/8*pi,sum(hs2,2),'-b');
a = sum(hs1,2);
b = sum(hs2,2);
a = a - mean(a);
b = b - mean(b);
phasepolar = sum(a.*b)/(norm(a)*norm(b));