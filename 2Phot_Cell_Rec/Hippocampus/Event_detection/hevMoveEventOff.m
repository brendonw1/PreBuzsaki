[x y butt] = ginput(1);
if butt > 1
    return
end
x = round(x);

if x > size(nt,2)
    return
end
if selev < length(spk{num}) & x >= spk{num}(selev+1)
    return
end
if x <= spk{num}(selev)
    return
end

dec{num}(selev) = x;
hevPlotTrace