[x y butt] = ginput(1);
if butt > 1
    return
end
x = round(x);
if x < 1 | x > size(nt,2)
    return
end
if length(find(spk{num}<x)) > length(find(dec{num}<x))
    return
end

[x2 y butt] = ginput(1);
if butt > 1
    return
end
x2 = round(x2);
if x2 < 1 | x2 > size(nt,2)
    return
end
if length(find(spk{num}<x2)) > length(find(dec{num}<x2))
    return
end
if x2 <= x
    return
end

spk{num} = sort([spk{num} x]);
dec{num} = sort([dec{num} x2]);
hevPlotTrace