function dist2old = dist2old(sa,la,sb,lb,q,k)

sa = [sa; la];
sb = [sb; lb];

lst = unique([sa(2,:),sb(2,:)]);
for c = 1:size(lst,2)
   j = find(sa(2,:)==lst(c));
   sa(2,j) = c;
   j = find(sb(2,:)==lst(c));
   sb(2,j) = c;
end
l = size(lst,2);
for c = 1:l
   j = find(sa(2,:)==c);
   ma(c) = size(j,2)+1;
   a{c} = sa(1,j);
   j = find(sb(2,:)==c);
   mb(c) = size(j,2)+1;
   b{c} = sb(1,j);
end
inda = [];
indb = [];
for c = 1:l
   ka = repmat(0:ma(c)-1,prod(ma(c+1:end)),1);
   ka = reshape(ka,prod(size(ka)),1);
   ka = repmat(ka,prod(ma(1:c-1)),1);
   inda = [inda ka];
   kb = repmat(0:mb(c)-1,prod(mb(c+1:end)),1);
   kb = reshape(kb,prod(size(kb)),1);
   kb = repmat(kb,prod(mb(1:c-1)),1);
   indb = [indb kb];
end
inda = sortrows([sum(inda,2) inda]);
inda = inda(:,2:end);
indb = sortrows([sum(indb,2) indb]);
indb = indb(:,2:end);
m = zeros(size(inda,1),size(indb,1));

if l > 1
   m(:,1) = sum(inda,2);
   m(1,:) = sum(indb');
else
   m(:,1) = inda;
   m(1,:) = indb';
end

for j = 4:sum(size(m))
   for na = max([2,j-size(m,2)]):min([j-2,size(m,1)])
      nb = j - na;
      ps = [];
      ta = inda(na,:);
      tb = indb(nb,:);
      for c = 1:l
         if ta(c)>0
            th = ta;
            th(c) = th(c)-1;
            n = find(sum(abs(repmat(th,size(m,1),1)-inda),2)==0);
            ps = [ps m(n,nb)+1];
         end
         if tb(c)>0
            th = tb;
            th(c) = th(c)-1;
            n = find(sum(abs(repmat(th,size(m,2),1)-indb),2)==0);
            ps = [ps m(na,n)+1];
         end
      end
      for c = 1:l
         for d = 1:l
            if ta(c)>0 & tb(d)>0
               th = ta;
               th(c) = th(c)-1;
               n1 = find(sum(abs(repmat(th,size(m,1),1)-inda),2)==0);
               th = tb;
               th(d) = th(d)-1;
               n2 = find(sum(abs(repmat(th,size(m,2),1)-indb),2)==0);
               if c == d
                  pr = 0;
               else
                  pr = k;
               end
               tma = a{c};
               tmb = b{d};
               ps = [ps m(n1,n2)+q*abs(tma(ta(c))-tmb(tb(d)))+pr];
            end
         end
      end      
      m(na,nb) = min(ps);
   end
end
dist2old = m(end,end);