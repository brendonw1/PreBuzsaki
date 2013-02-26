function city = city(n,q)
%city(n,q)
%   Gives a distance matrix for all n-bin spike trains
%   with the cost parameter q

a = (0:2^n-1)';
a = dec2bin(a) - 48;
for c = 1:2^n
   r{c} = find(a(c,:) == 1);
end

m = 0;
for c = 1:2^n
   for d = 1:c-1
      m(c,d) = dist(r{c},r{d},q);
      m(d,c) = m(c,d);
   end
end

city = m;