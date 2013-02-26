function [theta, mag] = orientation(cn,ct)
%[theta mag] = orientation(cn,ct)
%   determines the orientation of a contour

c = cov(cn);
if isempty(ct)
   ct = centroid(cn);
end
[v,d] = eig(c);
if abs(d(1,1))>abs(d(2,2))
   m = v(:,1);
else
   m = v(:,2);
end
mag = max(diag(d))/sum(diag(d));
theta = atan(m(2)/(m(1)+eps));
if sum(cn(:,1)-ct(1)) < 0
   theta = theta + pi;
end
if theta < 0
   theta = theta + 2*pi;
end