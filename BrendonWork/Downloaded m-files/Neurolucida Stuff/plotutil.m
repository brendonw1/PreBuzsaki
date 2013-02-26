


for i=1:k,
 x = X{i}; y = Y{i}; d = D{i};
 lmin(1) = min([lmin(1), min(x)]);
 lmin(2) = min([lmin(2), min(y)]);
 lmax(1) = max([lmax(1), max(x)]);
 lmax(2) = max([lmax(2), max(y)]);
 if (PLOTPOINTS) plot(x, y, 'o'); end;
 for h=2:length(x),
  if (PLOTDIAMS), 
   drawtube(x(h),y(h),x(h-1),y(h-1),d(h),d(h),SP); 
  else
   drawtube(x(h),y(h),x(h-1),y(h-1),.3,.3,SP);
  end
 end
end;
