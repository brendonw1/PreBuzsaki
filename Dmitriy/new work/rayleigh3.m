function params = rayleigh3(x,y,n,iter)
%params = rayleigh3(x,y,n,iter)
%   fits n Rayleigh curves to the data


for c = 1:iter
   [j{c} fval(c)] = fminsearch('rayfit',rand(1,n).*repmat([mean(y); mean(x); mean(x)],1,n),[],[x; y]);
end
f = find(fval==min(fval));
params = j{f(1)};

bar(x,y);
hold on
m = zeros(1,size(x,2));
for c = 1:size(params,2)
    s = abs(params(c));
    m = m + x.*exp(-x.^2/(2*s^2))/s^2;
end

plot(x,m,'-r','linewidth',2);