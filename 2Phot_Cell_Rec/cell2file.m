function cell2file(a,fout)
%cell2file(a,fout)
%   writes a contour coordinate cell array into a .ccf file

fid = fopen(fout,'w');
fwrite(fid,size(a,2),'double');
for c = 1:size(a,2)
   a{c} = round(a{c});
   for m = 1:size(a{c},1)-1
      for n = m+1:size(a{c},1)
         if a{c}(m,:) == a{c}(n,:)
            a{c}(n,1) = 100000;
         end
      end
   end
   f = find(a{c}(:,1)<100000);
   a{c} = a{c}(f,:);
   fwrite(fid,size(a{c},1),'double');
   fwrite(fid,a{c}','double');
end
fclose('all');
filerev(fout,8);