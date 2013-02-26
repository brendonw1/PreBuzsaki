[x y butt] = ginput(2);
if max(butt) > 1
    return
end

r = sqrt((x(2)-x(1)).^2+(y(2)-y(1)).^2);
theta = 0:pi/50:2*pi-pi/50;
newcn = [r*cos(theta)'+x(1) r*sin(theta)'+y(1)];

ct = HippoCentroid(newcn);
reg = 0;
for c = 1:length(region.coords)
    if inpolygon(ct(1),ct(2),region.coords{c}(:,1),region.coords{c}(:,2))
        if reg == 0
            reg = c;
        elseif polyarea(region.coords{c}(:,1),region.coords{c}(:,2)) < polyarea(region.coords{reg}(:,1),region.coords{reg}(:,2))
            reg = c;
        end
    end
end

if pi*r^2 < lowar(reg) | pi*r^2 > highar(reg)
    errordlg('Attempted contour area is not within limits!','Bad contour');
    return
else
    cn{reg}{length(cn{reg})+1} = newcn;
end

tmp = num;
num = reg;
HippoDrawCells
num = tmp;