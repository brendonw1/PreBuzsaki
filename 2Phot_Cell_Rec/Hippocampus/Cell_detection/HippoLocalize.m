function loca = HippoLocalize(a,rad,cfig)

m = findobj('type','uicontrol');
for c = 1:length(m)
    f = get(m(c),'position');
    if f(1) > 0.86 & f(2) < 0.50
        set(m(c),'visible','off');
    end
end

pr = zeros(1,2*rad+2,3);

aat = [repmat(a(:,1),1,rad) a repmat(a(:,end),1,rad)];
aat = [repmat(aat(1,:),rad,1); aat; repmat(aat(end,:),rad,1)];
loca = zeros(size(a,1),size(a,2));

for c = -rad:rad
    pr(1,sum(pr)+1,1) = 1;
    prg = subplot('position',[.87 .49 .11 0.025]);
    imagesc(pr);
    axis off
    drawnow;
    for d = -rad:rad
        loca = loca+aat(c+rad+1:end-rad+c,d+rad+1:end-rad+d);
    end
end
loca = loca/(2*rad+1)^2;
loca = a./(loca+eps);

[x y] = meshgrid(-rad:rad);
gs = exp(-(x.^2+y.^2)/rad);
loca = xcorr2(loca,gs);
loca = loca(rad+1:end-rad,rad+1:end-rad);

delete(prg);

for c = 1:length(m)
    f = get(m(c),'position');
    if f(1) > 0.86 & f(2) < 0.50
        set(m(c),'visible','on');
    end
end