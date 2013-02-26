function [ons, offs, param] = epo_marseille(fname,region)

tfig = figure('Name','Detecting signals...','NumberTitle','off','MenuBar','none','doublebuffer','on','units','normalized','position',[0.3    0.5    0.4    0.025]);

prg = zeros(1,length(region.contours)+1);
figure(tfig);
subplot('position',[0 0 1 1]);
set(gca,'xtick',[],'ytick',[]);
for cellnum = 1:length(region.contours)
    prg(cellnum) = 1;
    figure(tfig);
    imagesc(prg);
    set(gca,'xtick',[],'ytick',[]);
    drawnow
    
    x = region.traces(cellnum,:);
    
    tr = myfilter(x,2);
    
    block_size = 3;
    start_baseline = 50;
    end_baseline = 5;
    
    % plot(x);
    % hold on;
    
    isused = zeros(1,length(tr));
    pk = 1;
    st = 1;
    for c = 3:block_size:length(tr)-block_size
        [dummy min_location] = min(tr(c:c+block_size-1));
        min_location = min_location+c-1;
        if min_location - pk(end) < 2*block_size
            baseblock = tr(pk(end):min_location);
            baseavg = max(baseblock);
        else
            baseblock = tr(max([1 min_location-start_baseline]):max([1 min_location-end_baseline]));
            baseavg = mean(baseblock(find(baseblock>=median(baseblock))));
        end
        avgchange = mean(abs(x(2:end)-x(1:end-1)));
        stdchange = std(abs(x(2:end)-x(1:end-1)));
        if tr(min_location)-baseavg < -(avgchange+2*stdchange)
            ps = find(tr>baseavg);
            ps = ps(find(ps < min_location));
            if ~isempty(ps)
                ps = ps(end);
                if ps < pk(end)
                    [dummy psn] = max(tr(pk(end)+1:min_location));
                    psn = psn+pk(end);
                    if tr(min_location) < tr(psn)
                        ps = psn;
                    else
                        ps = psn;
                        isused(ps) = 1;
                    end
                end
                if isused(ps) == 0
                    %plot([min_location ps],[tr(min_location) tr(ps)],'-r');
                    pk = [pk min_location];
                    st = [st ps];
                end
            end
        end
    end
    
    if length(pk>1)
        pk = pk(2:end);
        st = st(2:end);
    else
        pk = [];
        st = [];
    end
    
    if~isempty(pk)
        pkn = pk(1);
        stn = st(1);
        for c = 2:length(pk)
            if st(c)-pkn(end) <= block_size
                pkn(end) = pk(c);
            else
                stn(end+1) = st(c);
                pkn(end+1) = pk(c);
            end
        end
    else
        pkn = [];
        stn = [];
    end
    
    tr = x;
    for c = 1:length(pkn)
        startpt = max([1 stn(c)-end_baseline]);
        endpt = find(tr>tr(stn(c))-(tr(stn(c))-tr(pkn(c)))/5);
        endpt = endpt(find(endpt<pkn(c)));
        endpt = endpt(end)+1;
        dfblock = tr(startpt:endpt);
        f = find(dfblock(2:end-1)>dfblock(3:end) & dfblock(2:end-1)>dfblock(1:end-2))+startpt;
        if ~isempty(f)
            f = f(end);
            for fx = 1:2
                if tr(f+fx+1)-tr(f+fx) < 4*(tr(f+fx)-tr(f))
                    f = f+fx;
                end
            end
            stn(c) = f;
        end
    end
    
    f = find(tr(stn)-tr(pkn) > 0.2*max(tr(stn)-tr(pkn)));
    stn = stn(f);
    pkn = pkn(f);
    
    decpt = [];
    for c = 1:length(stn)
        [mn i] = min(tr(stn(c):min([stn(c)+15 size(x,2)])));
        i = i+stn(c)-1;
        th = (tr(stn(c))+tr(i))/2;
        f = find(tr>th);
        f = f(find(f>i));
        if isempty(f)
            decpt(c) = size(x,2);
        else
            decpt(c) = f(1);
        end
        if c < length(stn) & decpt(c) >= stn(c+1)
            decpt(c) = stn(c+1) - 1;
        end
    end
    
    ons{cellnum} = stn;
    offs{cellnum} = decpt;
end

param = [];

delete(tfig);