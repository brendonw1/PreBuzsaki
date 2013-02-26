function distm = distm(a,b,c);
%distm(a,b,q)
%   Finds spike time distance between spike trains a and b.
%   q is the cost/sec parameter
%   written by Dmitriy Aronov, 9/4/2000
%   based on Victor and Purpura (1997)

sa = size(a,2);
sb = size(b,2);
m = zeros(sa+1,sb+1);
m(1,:) = 0:sb;
m(:,1) = (0:sa)';

for y = 2:(sa+1)
   for x = 2:(sb+1)
      p = m(y-1,x) + 1;
      q = m(y,x-1) + 1;
      r = m(y-1,x-1) + c*abs(a(y-1)-b(x-1));
      m(y,x) = min([p q r]);
   end
end

distm = m(sa+1,sb+1);