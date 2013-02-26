str = sum(get(gcf,'currentcharacter'));

if str == 28 | str == 44
    num = num - 1;
    set(txcellnum,'string',num2str(num));
    hevPlotTrace;
    xlimits = [0 size(nt,2)+1];
end

if str == 29 | str == 46
    num = num + 1;
    set(txcellnum,'string',num2str(num));
    hevPlotTrace;
    xlimits = [0 size(nt,2)+1];
end