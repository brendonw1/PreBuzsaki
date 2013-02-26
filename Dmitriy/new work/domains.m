function z = domains(ct,s1,s2)
%z = domains(ct,s1,s2)
%   makes a domain plot of cells s1 and s2

z = zeros(fix(max(ct(:,2)))+10,fix(max(ct(:,1)))+10);
[x y] = meshgrid(1:size(z,2),1:size(z,1));
fprintf(num2str(prod(size(s1))));
for c = 1:prod(size(s1))
   z = z + exp(-sqrt((x-ct(s1(c),1)).^2+(y-ct(s1(c),2)).^2)/60);
   fprintf('.');
end
fprintf(num2str(prod(size(s2))));
for c = 1:prod(size(s2))
   z = z - exp(-sqrt((x-ct(s2(c),1)).^2+(y-ct(s2(c),2)).^2)/60);
   fprintf('.');
end

%zz = z;
%[i j] = find(zz>2.75);
%zz(i,j) = 2.75;
%[i j] = find(zz<-2.75);
%zz(i,j) = -2.75;
%cl = colormap;
%rng = [min(min(zz)) max(max(zz))]+2.75;
%rng = rng/5.5*size(cl,1);
%cl = cl(fix(rng(1)):fix(rng(2)),:);
%imagesc(z);
%colormap(cl);