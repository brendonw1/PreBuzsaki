function [axis_rat, errs, ang, sig] = fitell(v,nproj);
%[axis_rat, errs, ang, sig] = fitell(coords,nproj)
%
%   Finds the best-fit ellipse for given coordinates
%   Input:
%      COORDS   -  coordinate matrix (N x D)
%      NPROJ    -  number of projections to analyze for significance testing
%   Output:  
%      AXIS_RAT -  2 x 1 array containing axis ratios of the best-fit ellipses
%      ERRS     -  2 x 2 matrix containing mean squared errors
%      ANG      -  Cosine of the dihedral angle between the plane of the first 2 dimensions
%                     and the plane of the best-fit ellipse in D dimensions
%      NPROJ    -  2 x 1 array containing significance levels (P) of the elliptical fits
%
%   ** 1st entry measures the best-fit ellipse in the first two dimensions
%      2nd entry measures the best-fit ellipse in D dimensions
%
%   Dmitriy Aronov, 7/6/01. Based on Victor and Purpura (1998, Appendix 2, Unpublished)

n = size(v,1);
v = v - repmat(mean(v,1),n,1);
theta = (0:(n-1))'/n*2*pi;
w = [cos(theta) sin(theta)];

%analysis of the ellipse in the first 2 dimensions
p = inv(w'*w)*w'*v(:,1:2);
m1 = trace(p*p')/2;
m2 = sqrt(trace(p*p')^2-4*det(p*p'))/2;
axis_rat(1,1) = sqrt((m1-m2)/(m1+m2));
errs(1,1) = trace((v(:,1:2)-w*p)*(v(:,1:2)-w*p)')/trace(v(:,1:2)*v(:,1:2)');
app = [w*p zeros(n,size(v,2)-2)];
errs(1,2) = trace((v-app)*(v-app)')/trace(v*v');

phi = acos(sqrt((norm(app(1,:))^2-(m1-m2))/((m1+m2)-(m1-m2)+eps)));
crd = v(:,1:2)*p'*inv(p*p');
crd = crd * [cos(phi) sin(phi); -sin(phi) cos(phi)];
crd(:,2) = -crd(:,2);
crd = crd * [cos(-phi) sin(-phi); -sin(-phi) cos(-phi)];
crd = crd*p;
for c = 1:nproj
   rn = repmat(sign(sign(rand(n,1)-.5)+1),1,2);
   crd2 = v(:,1:2).*rn + crd.*(1-rn);
   p = inv(w'*w)*w'*crd2;
   crd2 = crd2*p'*inv(p*p');
   crd2 = crd2(:,1:2)*p;
   ar(c) = trace((crd2-w*p)*(crd2-w*p)')/trace(crd2*crd2');
end
sig(1,1) = size(find(ar <= errs(1,1)),2)/nproj;

%analysis of the ellipse in the D-dimensional space
p = inv(w'*w)*w'*v;
r = p;
m1 = trace(p*p')/2;
m2 = sqrt(trace(p*p')^2-4*det(p*p'))/2;
axis_rat(2,1) = sqrt((m1-m2)/(m1+m2));
crd = v*p'*inv(p*p');
crd = crd(:,1:2)*p;
errs(2,1) = trace((crd-w*p)*(crd-w*p)')/trace(crd*crd');
errs(2,2) = trace((v-w*p)*(v-w*p)')/trace(v*v');

app = w*p;
phi = acos(sqrt((norm(app(1,:))^2-(m1-m2))/((m1+m2)-(m1-m2)+eps)));
crd = v*p'*inv(p*p');
crd = crd * [cos(phi) sin(phi); -sin(phi) cos(phi)];
crd(:,2) = -crd(:,2);
crd = crd * [cos(-phi) sin(-phi); -sin(-phi) cos(-phi)];
crd = crd*p;
for c = 1:nproj
   rn = repmat(sign(sign(rand(n,1)-.5)+1),1,size(v,2));
   crd2 = v.*rn + crd.*(1-rn);
   p = inv(w'*w)*w'*crd2;
   crd2 = crd2*p'*inv(p*p');
   crd2 = crd2(:,1:2)*p;
   ar(c) = trace((crd2-w*p)*(crd2-w*p)')/trace(crd2*crd2');
end
sig(2,1) = size(find(ar <= errs(2,1)),2)/nproj;

%angle between the first two dimensions and the plane of the best-fit ellipse in D-dimensions
x1 = [0 1 zeros(1,size(v,2)-2)];
x2 = [1 0 zeros(1,size(v,2)-2)];
v1 = [0 1]*r;
v2 = [1 0]*r;
y1 = (sum(v2.*(v2-v1))/norm(v2-v1))*v1 + (sum(v1.*(v1-v2))/norm(v1-v2))*v2;
y2 = v1 - v2;
y1 = y1/norm(y1);
y2 = y2/norm(y2);
ang = abs(det([sum(x1.*y1) sum(x1.*y2); sum(x2.*y1) sum(x2.*y2)]));