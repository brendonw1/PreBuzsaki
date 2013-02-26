function spk = hippo_stat_detect(tr)

filt_wind = 3;
baseline_window = 200;

trf = myfilter(tr,filt_wind);

th = max(trf)-range(trf)/2;
f = find(trf>th);
xs = [];
ys = [];
for c = 1:baseline_window:length(tr)
    fw = f(find(f >= c & f < c+baseline_window));
    thloc = max(trf(c:min([c+baseline_window length(trf)])))-range(trf(c:min([c+baseline_window length(trf)])))/2;
    fw = intersect(fw,find(trf>thloc));
    if ~isempty(fw)
        xs = [xs c+baseline_window/2];
        ys = [ys median(trf(fw))];
    end
end
xs = [1 xs length(tr)];
ys = [max(trf(1:fix(baseline_window/10)+1)) ys max(trf(end-(fix(baseline_window/10)):end))];
xs = [xs (xs(1:end-1)+xs(2:end))/2];
ys = [ys (ys(1:end-1)+ys(2:end))/2];
[xs i] = sort(xs);
ys = ys(i);
bsline = spline(xs,ys,1:length(tr));

spk = bsline;
return

f = find(tr(2:end)-tr(1:end-1)>0 & trf(1:end-1)>bsline(1:end-1));
thres = 2*std(tr(f+1)-tr(f));
df = trf-bsline;

spk = find(df(2:end-1)<-thres & trf(2:end-1)<trf(1:end-2) & trf(2:end-1)<trf(3:end))+1;
for c = 1:length(spk)
    f = find(df(1:end-1)>-thres & df(2:end)<=-thres);
    %f = find(trf(2:end-1)>trf(1:end-2) & trf(2:end-1)>trf(3:end))+1;
    f = f(find(f<spk(c)));
    if ~isempty(f)
        str(c) = f(end);
    else
        str(c) = spk(c);
    end
end
if ~isempty(spk)
    str = str(find(trf(str)-trf(spk) > 0.2*(max(trf(str)-trf(spk)))));
    spk = unique(str);
end


%subplot(2,1,1)
%hold on
%plot(tr)
% plot(bsline,'-r')
% plot(xs,ys,'+r')
% subplot(2,1,2)
% hold on
% plot(trf-bsline)
% plot(xlim,[0 0],'-r')
% plot(xlim,[-thres -thres],'-g')
%plot(spk,trf(spk),'+r');