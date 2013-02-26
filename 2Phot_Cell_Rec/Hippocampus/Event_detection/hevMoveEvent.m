[x y butt] = ginput(1);
if butt > 1
    return
end
x = round(x);

if x < 1
    return
end
if selev > 1 & x <= dec{num}(selev-1)
    return
end
if x >= dec{num}(selev)
    return
end

spk{num}(selev) = x;
hevPlotTrace