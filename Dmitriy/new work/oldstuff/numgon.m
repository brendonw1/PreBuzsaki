function numgon = numgon(n,varargin)
%numgon(n)
%   returns the nth triangular number
%numgon(n,r)
%   returns the nth r-gonal number

if size(varargin,2) == 1
   r = varargin{1};
else
   r = 3;
end
numgon = r.*n.*(n-1)/2+2.*n-n.^2;