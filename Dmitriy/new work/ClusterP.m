function ClusterP = ClusterP(cn,tp,f,tr)
%ClusterP = ClusterP(cn,tp,f,tr)
%   determines the P value of the cluster arrangement
%   cn = contour coordinates
%   tp: 1 = cluster, 2 = column, 3 = layer
%   f = list of cells active in the pattern
%   tr = number of reshufflings

for c = 1:size(cn,2)
    ct(c,:) = centroid(cn{c});
end
theta = pi/2-PiaDirection(cn);
ct = ct*[cos(theta) sin(theta); -sin(theta) cos(theta)];

switch tp
case 1
    %cluster - do nothing
case 2
    %column
    ct(:,2) = 0;
case 3
    %layer
    ct(:,1) = 0;
end

f = reshape(f,1,prod(size(f)));
if size(f,2) < 2
    ClusterP = 1;
    return;
end


cr = ct(f,1)+i*ct(f,2);
[x y] = meshgrid(cr);
z = reshape(abs(x-y),1,prod(size(x)));
nm = mean(z(find(z>0)));

for t = 1:tr
    j = randperm(size(ct,1));
    f = j(1:size(f,2));
    cr = ct(f,1)+i*ct(f,2);
    [x y] = meshgrid(cr);
    z = reshape(abs(x-y),1,prod(size(x)));
    cm(t) = mean(z(find(z>0)));
end

ClusterP = size(find(cm<nm),2)/tr;