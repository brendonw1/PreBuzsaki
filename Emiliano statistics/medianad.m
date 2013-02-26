function y = medianad(x)

%by Emiliano Rial Verde
%11/18/2002
%MAD    Median absolute deviation. 
%   Y = MAD(X) calculates the median absolute deviation (MAD) of X.
%   For matrix X, MAD returns a row vector containing the MAD of each  
%   column.
%
%   The algorithm involves subtracting the median of X from X,
%   taking absolute values, and then finding the median of the result.

[nrow,ncol] = size(x);
med = median(x);
y = abs(x - med(ones(nrow,1),:));
y = median(y);
