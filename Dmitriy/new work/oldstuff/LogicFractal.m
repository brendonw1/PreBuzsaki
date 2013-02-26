function LogicFractal = LogicFractal(n)

for c = 0:(2^n-1)
   for d = 0:(2^n)-1
      vc = str2num(dec2bin(c)')';
      vd = str2num(dec2bin(d)')';
      if size(vc,2) < n
         vc = cat(2,vc,zeros(1,n-size(vc,2)));
      end
      if size(vd,2) < n
         vd = cat(2,vd,zeros(1,n-size(vd,2)));
      end
      rs = vc & vd;
      m(c+1,d+1) = sum(2.^(n-(1:n)).*rs(1:n));
   end
end

imagesc(m);
axis equal;
axis tight;
colormap colorcube;
set(gca,'Visible','off');