function lfit = lfit(x0,mt)
%function used by linfit
x0 = x0/norm(x0);
vc = [mt*x0 mt*(-x0)];
vc = min(vc');
lfit = 1/norm(vc);