function grating(contrast,frequency,orientation,phase)
%grating(contrast,frequency,orientation,phase)
%   contrast: 0 - 100 (%)
%   frequency: positive number
%   orientation: 0 - 180 (deg)
%   phase: 0 - 360 (deg)

theta = orientation * pi / 180;
if theta > pi/2
   lr = 1;
   theta = pi - theta;
else
   lr = 0;
end
if theta > pi/4
   nt = 1;
   theta = pi/2 - theta;
else
   nt = 0;
end
phi = (phase+180) * pi / 180;
a = contrast / 100;
omega = frequency * 2;
omega = omega*cos(theta);
if rem(frequency,2) == 1
   phi = phi + pi;
end

l = -2*theta:theta/150:2*theta;
if theta == 0
   l = zeros(1,601);
end
[v,l] = meshgrid(-pi/2:pi/600:pi/2,l);
vl = a*cos(omega*(v+l)+phi);
clear v l;
x = (-1:1/300:1).^2;
vals = repmat(x',1,601)+repmat(x,601,1);
vals = 1-sign(fix(vals));
vals = vals.*vl;
cmin = 0.5-a/2;
cmax = 0.5+a/2;
step = (cmax-cmin)/63;
clrmap = (cmin:step:cmax)';
clrmap = repmat(clrmap,1,3);
if a == 0
   clrmap = repmat(0.5,64,3);
end
if nt == 0
   vals = rot90(fliplr(vals));
end
if lr == 1
   vals = fliplr(vals);
end

imagesc(vals);
colormap(clrmap);
set(gcf,'Color',[0.5 0.5 0.5]);
axis equal;
axis off;