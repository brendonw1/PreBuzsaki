function [spkres, decres] = intresdur(region)
% interval reshuffling

spkres = cell(1,length(region.contours));
decres = cell(1,length(region.contours));
sz = size(region.traces,2);
for c = 1:length(region.contours)
    if ~isempty(region.onsets{c})
        ints = [region.onsets{c}(1) region.onsets{c}(2:end)-region.offsets{c}(1:end-1) sz-region.offsets{c}(end)];
        if ints(end) == 0
            ints(end) = 1;
        end
        durs = region.offsets{c}-region.onsets{c};
        sm = 0;
        while sm == 0
            f = randperm(length(ints));
            g = randperm(length(durs));
            sm = sum([f(2:end)-(1:length(ints)-1) g(2:end)-(1:length(durs)-1)]);
        end
        ints = ints(f);
        durs = durs(g);
        tms = [reshape([ints(1:end-1); durs],1,2*length(durs)) ints(end)];
        tms = cumsum(tms);
        spkres{c} = tms(1:2:end-1);
        decres{c} = tms(2:2:end-1);
    end
end