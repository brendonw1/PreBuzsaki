function rayfit = rayfit(params,xy)
%function used by rayleigh

x = xy(1,:);
y = xy(2,:);
m = zeros(1,size(xy,2));
for c = 1:size(params,2)
    s = abs(params(c));
    m = m + x.*exp(-x.^2/(2*s^2))/s^2;
end

rayfit = (sum(m.*y)/norm(m+eps))^-1;