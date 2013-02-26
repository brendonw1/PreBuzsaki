function septrains=separatein6(stims,maxdiff,varargin)
%Takes the outputs from findin6 as inputs and divides
%them into separate trains.  Trains are defined as series of pulses (from
%in6) that have differences between them of up to maxdiff, an input.  If
%there is a gap greater than maxdiff, the spikes on either side will be
%considered parts of separate trains.  Each train is stored as a vector
%inside a cell array... each vector in the cell represents a separate train

stims=sort(stims);%make sure stims are in numerical sequence... should be a list of times of events, in order
d=diff(stims);
d=5*round(d/5);%round to nearest 5 time points... so small errors are cancelled
ends=find(d>maxdiff);%find the ends of all separate sequences (with intervals less than 100ms) except the last
ends(end+1)=length(stims);%add the final last time, which equals the end of the entire sequence
starts=ends+1;%find whre most sequences start
starts(end)=1;%elim the start that would be one past the end of the entire sequence, sub in point one as the first start
starts=sort(starts);%sort, so in order, and correspond with ends

septrains = {};
bursts = {};
burstaddresses = [];
for d=1:length(starts);%for every separate train
    if ~isempty(varargin);
        if ends(d)-starts(d) >= 3
            bursts{end+1}=stims(starts(d):ends(d));%store each train as a matrix inside a cell
            burstaddresses(end+1) = d;
        end
    else
        septrains{d}=stims(starts(d):ends(d));%store each train as a matrix inside a cell
    end
end
if ~isempty(varargin);
    switch (varargin{1})
        case 'burst'
            septrains = bursts;
        case 'tonic'
            tonics = {};
            if isempty(burstaddresses)
                septrains{1} = stims; 
            else
                for baidx = 1:length(burstaddresses)
                    if baidx == 1%if first burst (grab event before)
                        if burstaddresses(baidx) ~= 1;%if any events before first burst
                            tonics{end+1} = stims(1:ends(burstaddresses(baidx)-1));%record them as a tonic
                        end
                    end
                    if baidx ~= length(burstaddresses);%as long as not last burst
                        tonics{end+1} = stims(starts(burstaddresses(baidx)+1):...%gather next set of events as tonic
                               ends(burstaddresses(baidx+1)-1));
                    elseif baidx == length(burstaddresses);%if last burst
                        if burstaddresses(baidx) ~= length(starts)%if any events after last burst
                            tonics{end+1} = stims(starts(burstaddresses(baidx)+1):end);%record them as a tonic
                        end
                    end
                end
                septrains = tonics;
            end
    end
end