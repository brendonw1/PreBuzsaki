function [statistic, pval, H] = shapirowilks(x,tails,probability)
% PURPOSE:
%   This function performs that Shapiro-Wilks Test for normality of the data
%   This is an omnibus test, and is generally considered relatively powerful against 
%   a variety of alternatives, and better than the S-Francia tst for Platy-kurtotic Sample
% 
% 
% USAGE:
%   x: an Nx1 vector of deviates from an unknown distribution
%   tails(optional): 0 for a two tailed test(Default)
%   probability: The significance level for the test(.05 by default)
% 
% 
% INPUTS:
%  statistic:A N(0,1) teststatistic transformed form the W
%  pval: The significance of the statistic
%  H: 0 for fail to reject the null at the sig level, 1 otherwise
% 
% OUTPUTS:
% 
% 
% COMMENTS:
%  See Royston(1993) for details in the approximation
%  Not for censored data
% 
% 
% Author: Kevin Sheppard
% kksheppard@ucsd.edu
% Revision: 2    Date: 12/31/2001
%
%
%Modified by Emiliano Rial Verde
%emiliano@rialverde.com
%April 2006


                  

% First, calculate the a's for weights as a function of the m's
% See Royston(1993) for details in the approximation
if nargin<2
    tails=0;
    probability=.05;
end
if nargin<3
    probability=.05;
end

x=unique(x);
n=size(x,1);
mtilde=norm_inv(([1:n]'-(3/8))/(n+.25));


c=(sqrt(mtilde'*mtilde)^-1)*mtilde;

weights=ones(size(x))*-999;
u=n^(-0.5);
weights(n)=c(n)+ .221157*u - .147981 * u^2 - 2.071190 * u^3 + 4.434685 * u^4 - 2.706056 * u^5;
weights(n-1)=c(n-1)+ .042981*u - .293762 * u^2 - 1.752461 * u^3 + 5.682633 * u^4 - 3.582633 * u^5;
weights(1)=-weights(n);
weights(2)=-weights(n-1);

phi=(mtilde'*mtilde - 2 * mtilde(n)^2 - 2 * mtilde(n-1)^2)/(1- 2*weights(n)^2 - 2*weights(n-1)^2);

weights(3:n-2)=mtilde(3:n-2)*phi^(-0.5);

W=(sum(weights.*x))^2/((x-mean(x))'*(x-mean(x)));


newu=log(n);

if n>3 & n<12
    gamma=-2.273+.459*newu;
    mu=.5440-.39978*newu+.025054*newu^2-.0006714*newu^3;
    sigma=exp(1.3822-.77857*newu+.062767*newu^2-.0020322*newu^3);
    newstatistic=-log(gamma-log(1-W));
    z=(newstatistic-mu)/sigma;
    pval=min(norm_cdf(z),1-norm_cdf(z));
elseif n>11 & n <5000
    mu=-1.5861 - .31082 *newu - .083751*newu^2 + .0038915 * newu^3;
    sigma = exp(-.4803 - .082676 * newu + .0030302 * newu^2);
    newstatistic=log(1-W);
    z=(newstatistic-mu)/sigma;        
    pval=min(norm_cdf(z),1-norm_cdf(z));
end

H=pval<probability;
statistic=z;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function invp = norm_inv(x, m, v)
% PURPOSE: computes the quantile (inverse of the CDF) 
%          for each component of x with mean m, variance v
%---------------------------------------------------
% USAGE: invp = norm_inv(x,m,v)
% where: x = variable vector (nx1)
%        m = mean vector (default=0)
%        v = variance vector (default=1)
%---------------------------------------------------
% RETURNS: invp (nx1) vector
%---------------------------------------------------
% SEE ALSO: norm_d, norm_rnd, norm_inv, norm_cdf
%---------------------------------------------------

% Written by KH (Kurt.Hornik@ci.tuwien.ac.at) on Oct 26, 1994
% Copyright Dept of Probability Theory and Statistics TU Wien
% Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu

if nargin > 3
    error ('Wrong # of arguments to norm_inv');
end

[r, c] = size (x);
s = r * c;

if (nargin == 1)
    m = zeros(1,s);
    v = ones(1,s);
end



x = reshape(x,1,s);
m = reshape(m,1,s);
v = reshape(v,1,s);

invp = zeros (1,s);

invp = m + sqrt(v) .* stdn_inv(x);

invp = reshape (invp, r, c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cdf = norm_cdf (x, m, v)
% PURPOSE: computes the cumulative normal distribution 
%          for each component of x with mean m, variance v
%---------------------------------------------------
% USAGE: cdf = norm_cdf(x,m,v)
% where: x = variable vector (nx1)
%        m = mean vector (default=0)
%        v = variance vector (default=1)
%---------------------------------------------------
% RETURNS: cdf (nx1) vector
%---------------------------------------------------

% Written by TT (Teresa.Twaroch@ci.tuwien.ac.at) on Jun 3, 1993
% Updated by KH (Kurt.Hornik@ci.tuwien.ac.at) on Oct 26, 1994
% Copyright Dept of Probability Theory and Statistics TU Wien
% Updated by James P. Lesage, jpl@jpl.econ.utoledo.edu 1/7/97

[r, c] = size(x);

if (r*c == 0)
    error('norm_cdf: x must not be empty');
end;

if (nargin == 1)
    m = zeros(r,1);
    v = ones(r,1);
end;

cdf = zeros(r, 1);
cdf(1:r,1) = stdn_cdf((x(1:r,1) - m(1:r,1)) ./ sqrt (v(1:r,1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ninv = stdn_inv (x)  
% PURPOSE: computes the quantile (inverse of the CDF) 
%          for each component of x with mean 0, variance 1
%---------------------------------------------------
% USAGE: ninv = stdn_inv(x)
% where: x = variable vector (nx1)
%---------------------------------------------------
% RETURNS: ninv = (nx1) vector containing quantiles at each x-element
%---------------------------------------------------

% Written by KH (Kurt.Hornik@ci.tuwien.ac.at) 
% Converted to MATLAB by JP LeSage, jpl@jpl.econ.utoledo.edu

if (nargin ~= 1)
    error ('Wrong # of arguments to stdn_inv');
end

ninv = sqrt(2) * erfinv(2 * x - 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cdf = stdn_cdf(x)  
% PURPOSE: computes the standard normal cumulative
%          distribution for each component of x
%---------------------------------------------------
% USAGE: cdf = stdn_cdf(x)
% where: x = variable vector (nx1)
%---------------------------------------------------
% RETURNS: cdf (nx1) vector
%---------------------------------------------------

% written by:
% James P. LeSage, Dept of Economics
% University of Toledo
% 2801 W. Bancroft St,
% Toledo, OH 43606
% jpl@jpl.econ.utoledo.edu

  if (nargin ~= 1)
    error('Wrong # of arguments to stdn_cdf');
  end;

  cdf = .5*(1+erf(x./sqrt(2)));