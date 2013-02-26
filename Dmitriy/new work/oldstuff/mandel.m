function mandel(xs,ys,sz,num)

z = zeros(sz(1),sz(2));
cnt = z;
sz = sz - [1 1];
[a b] = meshgrid(xs(1):(xs(2)-xs(1))/sz(2):xs(2),ys(1):(ys(2)-ys(1))/sz(1):ys(2));
c = a + b*i;

for j = 1:num
   z = z.^2 + c;
   m = (sign(abs(z)-2+eps)+1)/2;
   cnt = cnt + m;
   m = (z - 3).*m;
   z = z - m;
end

imagesc(cnt);