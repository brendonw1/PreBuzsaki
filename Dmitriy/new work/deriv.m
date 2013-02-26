function deriv = deriv(a)
%deriv = deriv(a)
%   approximation of the derivative

deriv = a(2:end) - a(1:end-1);