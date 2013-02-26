function [statistic, pval, H] = shapirofrancia(x,tails,probability)
% PURPOSE:
%   This function performs that Shapiro-Francia Test for normality of the data
%   This is an omnibus test, and is generally considered relatively powerful against 
%   a variety of alternatives, and better than the S-Wilks tst for Lepto-kurtotic Sample
% 
% 
% USAGE:
%     [statistic, pval, H] = shapirofrancia(x,tails,probability)
% 
% INPUTS:
%   x: an Nx1 vector of deviates from an unknown distribution
%   tails(optional): 0 for a two tailed test(Default)
%                    1 for a one sided(upper) test
%                    -1 for a one sided(lower) test
%   probability: The significance level for the test(.05 by default)
% 
% 
% OUTPUTS:
%  statistic:A N(0,1) teststatistic transformed form the W
%  pval: The significance of the statistic
%  H: 0 for fail to reject the null at the sig level, 1 otherwise
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
%
%Modified by Emiliano Rial Verde
%emiliano@rialverde.com
%April 2006



% First, calculate the a's for weights as a function of the m's
% See Royston(1993) for details in the approximation
x=unique(x);
n=size(x,1)
mtilde=norm_inv(([1:n]'-(3/8))/(n+.25));
weights=(sqrt(mtilde'*mtilde)^-1)*mtilde;

W=(sum(weights.*x))^2/((x-mean(x))'*(x-mean(x)));

nu=log(n);
u1=log(nu)-nu;
mu=-1.2725+1.0521*u1;
u2=log(nu)+2/nu;
sigma=1.0308-.026758*u2;

newstatistic=log(1-W);
z=(newstatistic-mu)/sigma;

pval=min(norm_cdf(z),1-norm_cdf(z))
H=pval<.05;
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