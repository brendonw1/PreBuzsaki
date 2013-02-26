function results = jarquebera(data, k, alpha)
% PURPOSE:
%     Performs a Jarque-Bera test for normality.  Uses the skewness and kurtosis to determine if a
%     distribution is normal.  Has good power against skewness and kurtoisi problems, but little elsewhere
% 
% USAGE:
%     results = jarquebera(data, k, alpha)
% 
% INPUTS:
%     data     - A set of data from a presumed normal distribution
%     k        - the number of dependant variables if any used in creating the data(must be >= 2)(optional)
%     alpha    - The level of the test used for the hypothesis(H)(optional)
% 
% OUTPUTS:
%   results, a structure with fileds:
%         statistic - A scalar representing the statistic
%         pval      - A scalar pval of the null
%         H         - A hypothesis dummy(0 for fail to reject the null of normality, 1 otherwise)
% 
% COMMENTS:
% 
% Author: Kevin Sheppard
% kksheppard@ucsd.edu
% Revision: 2    Date: 12/31/2001
%
%
%Modified by Emiliano Rial Verde
%emiliano@rialverde.com
%April 2006


[t,c]=size(data);

if nargin <2
   k = 2;
end

if nargin < 3
   alpha = .05;
end


val = skewness(data)^2;
val = val + (1/4)*(kurtosis(data)-3)^2;
results.statistic = ((t-k)/6)* val;

results.pval = 1-chis_cdf(results.statistic,k);
results.H=results.pval<alpha;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = chis_cdf (x, a)
% PURPOSE: returns the cdf at x of the chisquared(n) distribution
%---------------------------------------------------
% USAGE: cdf = chis_cdf(x,n)
% where: x = a vector
%        n = a scalar parameter
% NOTE: chis_cdf(x,n) = gamm_cdf(x/2,n/2)
%---------------------------------------------------
% RETURNS:
%        a vector pdf at each element of x from chisq(n) distribution      
% --------------------------------------------------
% SEE ALSO: chis_d, chis_pdf, chis_rnd, chis_inv
%---------------------------------------------------

%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg
% documentation modified by LeSage to
% match the format of the econometrics toolbox

if (nargin ~= 2)
    error ('Wrong # of arguments to chis_cdf');
end

if any(any(a<=0))
   error('chis_cdf: dof is wrong')
end

F = gamm_cdf(x/2,a*0.5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cdf = gamm_cdf (x, a)
% PURPOSE: returns the cdf at x of the gamma(a) distribution
%---------------------------------------------------
% USAGE: cdf = gamm_cdf(x,a)
% where: x = a vector 
%        a = a scalar gamma(a)
%---------------------------------------------------
% RETURNS:
%        a vector of cdf at each element of x of the gamma(a) distribution      
% --------------------------------------------------
% SEE ALSO: gamm_d, gamm_pdf, gamm_rnd, gamm_inv
%---------------------------------------------------

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

if nargin ~= 2
error('Wrong # of arguments to gamm_cdf');
end;

if any(any(a<=0))
   error('gamm_cdf: parameter a is wrong')
end

cdf = gammainc(x,a);
I0 = find(x<0);
cdf(I0) = zeros(size(I0));