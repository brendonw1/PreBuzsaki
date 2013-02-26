function poisson = poisson(r,t)
%poisson = poisson(r,t)
%   creates a Poisson spike train with average firing rate r and length t

m = cumsum(random('Exponential',1/(r+eps),1,fix(5*t*r)+10));
poisson = m(find(m<t));