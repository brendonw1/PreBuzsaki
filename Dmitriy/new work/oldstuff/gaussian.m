function gaussian(r)
%gaussian(r)
%   Plots a ring of Gaussian primes of radius r

for a = 1:r
   for b = 1:a
      m(a,b) = (isprime(a^2 + b^2) & a^2 + b^2 < r^2);
      m(b,a) = m(a,b);
   end
end

w = isprime(1:r);
for c = find(w==1)
   w(c) = (rem(c,4) == 3);
end

m = cat(1,flipud(m),w,m);
m = cat(2,fliplr(m),zeros(2*r+1,1),m);

imagesc(~m);
axis equal;
axis tight;
set(gca,'XTickLabel','');
set(gca,'YTickLabel','');
set(gca,'ZTickLabel','');