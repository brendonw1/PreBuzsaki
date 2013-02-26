function g=gaussian(points,mean,sigma);
%outputs a gaussian centered at "mean", with sd of "sigma" and evaluated at
%all points in "points"

g=exp(-((points-mean).^2)/(2*sigma^2));