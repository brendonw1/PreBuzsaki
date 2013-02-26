function intres = intres(x,tm)
%intres = intres(x,tm)
%   performs interval resampling on the spike train

x1 = x(2:end);
x0 = x(1:end-1);
ints = x1 - x0;
ints = ints(randperm(prod(size(ints,2))));
beg = fix(rand*(tm-sum(ints)))+1;
intres = cumsum([beg ints]);
if isempty(x)
    intres = [];
end