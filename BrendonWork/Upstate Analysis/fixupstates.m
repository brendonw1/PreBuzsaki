function fixedupstates=fixupstates(upstates,abfnotes);
for a=1:size(upstates,1);%for every slice
     for b=1:size(upstates,2);%for each file
        for bb=1:size(upstates,3);%for each trace in that record
           emp(bb)=~isempty(upstates{a,b,bb});%record whether there is an upstate found in each record
        end
        if sum(emp)>0;%if there is any upstate in this file, load it by...
            name1=abfnotes{a}.abfname{b};%get name of the electrophys recording to open from the abfnotes cell
            sc=['load ',name1,' header'];
            eval(sc);
            channels=channelnames(header);%record the names of the channels recorded, ie "IN 5", "IN 10" or "IN 14"
            for c=1:size(upstates,3);%for each trace in the loaded file
                if ~isempty(upstates{a,b,c});%if upstates detected in that trace
                    if strcmp(channels(c),'IN 5') | strcmp(channels(c),'IN 11');
                        w=1;
                    elseif strcmp(channels(c),'IN 10') | strcmp(channels(c),'IN 7');
                        w=2
                    elseif strcmp(channels(c),'IN 14') | strcmp(channels(c),'IN 15')
                        w=3;
                    end
                    fixedupstates{a,b,w}=upstates{a,b,c};
                end
            end
        end
    end
end
