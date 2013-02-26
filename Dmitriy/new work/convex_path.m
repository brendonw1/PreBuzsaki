function curr_path = convex_path(coords)
%uses the convex hull algorithm to construct the path around the points

set(gcf,'position',[1          29        1024         672]);

centr = mean(coords);
ncrds = coords-repmat(centr,size(coords,1),1);
thetas = atan(ncrds(:,2)./ncrds(:,1))+pi*(sign(ncrds(:,1)<0));
conv_poly = sortrows([thetas (1:size(thetas,1))']);
conv_poly = conv_poly(:,2);

curr_path = 1:size(conv_poly,1);
while 1
   isgood = ones(1,size(curr_path,2));
   for c = 1:size(curr_path,2)
      lft = ncrds(conv_poly(curr_path(c-1+size(curr_path,2)*(c==1))),:);
      cen = ncrds(conv_poly(curr_path(c)),:);
      rgh = ncrds(conv_poly(curr_path(c+1-size(curr_path,2)*(c==size(curr_path,2)))),:);
      if abs(det([0 0 1; rgh 1; lft 1])) >= abs(det([0 0 1; cen 1; lft 1])) + abs(det([0 0 1; cen 1; rgh 1]))
         isgood(c) = 0;
      end
   end
   curr_path = curr_path(find(isgood==1));
   if prod(isgood)==1
      break
   end
end
ncrds = coords(conv_poly,:);

for c = 1:size(coords,1)-size(curr_path,2)
   pts_left = setdiff(1:size(coords,1),curr_path);
   [np pt] = meshgrid(ncrds(pts_left,1),ncrds(curr_path,1));
   xs = np-pt;
   [np pt] = meshgrid(ncrds(pts_left,2),ncrds(curr_path,2));
   ys = np-pt;
   ld1 = (xs.^2+ys.^2).^0.5;
   if size(ld1,2)>1
      ld2 = ld1([2:end 1],:);
   else
      ld2 = ld1;
   end
   hd = repmat(sum((ncrds([curr_path(2:end) curr_path(1)],:)-ncrds(curr_path,:)).^2,2),1,size(ld1,2));
   dst = (ld1+ld2)-hd;
   rs = mod(find(dst==repmat(min(dst),size(dst,1),1)),size(dst,1));
   rs(find(rs==0)) = size(dst,1);
   
   v = diag(ld1(rs,1:size(ld1,2)));
   w = diag(ld2(rs,1:size(ld2,2)));
   k = diag(hd(rs,1:size(hd,2)));
   ind = (v.^2+w.^2-k.^2)./(2*v.*w);
   
   f = find(ind==min(ind));
   curr_path = [curr_path(1:rs(f)) pts_left(f) curr_path(rs(f)+1:end)];
   
   plot(ncrds(:,1),ncrds(:,2),'.k');
   hold on;
   plot(ncrds(curr_path([1:end 1]),1),ncrds(curr_path([1:end 1]),2))
   hold off;
   drawnow;
end

plot(ncrds(:,1),ncrds(:,2),'.k');
hold on;
plot(ncrds(curr_path([1:end 1]),1),ncrds(curr_path([1:end 1]),2));