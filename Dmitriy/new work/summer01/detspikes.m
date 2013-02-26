function detspikes = detspikes(x,nstp1,th,nstp2,hg)
%detspikes = detspikes(x,nstp1,th,nstp2,hg)
%    spike detection algorithm
%    x - trace
%    nstp1 - number of data points over which to average the derivative
%    th - threshold for the derivative (fraction of the minimum)
%    nstp2 - number of data points over which to average the trace
%    hg - threshold for the trace (fraction of the minimum)

oldx = x;
ni = 10;
ind = fix([1 (1:ni)/ni*size(x,2)]);
for c = 1:ni
   vl = x(ind(c):ind(c+1));
   mx(c) = max(vl);
end
mx = [max(x(1:fix(ind(2)/ni))) mx];
xs = repmat(ind',1,4).^repmat((0:3),size(ind,2),1);
coeff = xs\mx';
app = (repmat((1:size(x,2))',1,4).^repmat((0:3),size(x,2),1))*coeff;
x = x-app';

x0 = [x(1) x(1:end-1)];
dx = x-x0;
dx0 = [dx(1) dx(1:end-1)];

thr = min(dx)*th;
j = intersect(find(dx0>thr),find(dx<thr));
for c = 1:size(j,2)
   cns1(c) = mean(dx(j(c):min([j(c)+nstp1 size(x,2)])));
end
thr = min(cns1)*th;
j = j(find(cns1<thr));
cns1 = cns1(find(cns1<thr));
for c = j
   f = find(abs(j-c)<125);
   j(f) = j(find(cns1==min(cns1(f))));
end
j = unique(j);

thr = min(x)*hg;
k = intersect(find(x0>thr),find(x<thr));
k = union(k,intersect(find(x0>thr*2),find(x<thr*2)));
for c = 1:size(k,2)
   cns2(c) = mean(x(k(c):min([k(c)+nstp2 size(x,2)])));
end
thr = min(cns2)*th;
k = k(find(cns2<thr));
cns2 = cns2(find(cns2<thr));
for c = k
   f = find(abs(k-c)<125);
   if ~isempty(f)
      k(f) = k(find(cns2==min(cns2(f))));
   end
end

spk = [];
for c = j
   f = k(find(k-c>-75 & k-c<150));
   if size(f,2)>1
      f = sortrows([(f-c)' f']);
      f = f(1,2);
   end
   if prod(size(f))>0
      spk = [spk c];
   end
end

x0 = [oldx(1) oldx(1:end-1)];
dx = oldx-x0;
thr = min(dx)*th*0.8;
for c = 1:size(spk,2)
   cnsf = dx([max([1 spk(c)-100]) spk(c)]);
   f = find(cnsf<thr);
   f = spk(c)-(size(cnsf)-f(1));
   spk(c) = f(1);
end

detspikes = spk;