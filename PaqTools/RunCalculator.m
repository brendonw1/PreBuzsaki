function probability=RunCalculator(r,n,p)
% Adam Packer 2009
% probability=RunCalculator(r,n,p)
% Outputs the probability of seeing a run of r consecutive successes in n
% trials given the probability of seeing one success is 0<p<1

% F=(p^r * n^r * (1 - (p * n))) / (1 - n + ((1 - p) * p^r * n^(r + 1))); 
z = BetaCalculator(r,n,p) - ((p^r) * BetaCalculator(r,n-r,p));
probability=1-z;

function betaNR=BetaCalculator(r,n,p)
q = 1 - p;
betaNR=0;
for l = 0:floor(n/(r+1))
    betaNR = betaNR + (((-1)^l) * nchoosek((n - (l*r)),l) * (q * (p^r))^l);
end