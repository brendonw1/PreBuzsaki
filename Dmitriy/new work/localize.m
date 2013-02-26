function localize = localize(m,num)

fl = ones(1,2*num+1)/(2*num+1);

sz = size(m,2);
[x1 y] = meshgrid(1:sz,1:num);
y = flipud(y);
x1 = x1-y;
x1 = x1.*((sign(x1-.5)+1)/2)+(1-(sign(x1-.5)+1)/2);
x2 = fliplr(flipud((sz+1)*ones(num,sz)-x1));
x = [x1; 1:sz; x2];
x = m(x);
x = fl*x;

localize = m./x;
