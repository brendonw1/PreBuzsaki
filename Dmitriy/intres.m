function intres = intres(x,tm)
%intres = intres(x,tm)
%   performs interval resampling on the spike train

x = [0 x tm];
ints = x(2:end)-x(1:end-1);
ints = ints(randperm(size(ints,2)));
xs = cumsum(ints);
intres = xs(1:end-1);