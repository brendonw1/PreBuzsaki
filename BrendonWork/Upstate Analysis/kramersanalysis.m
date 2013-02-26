function intervals=kramersanalysis(upstates,evals,abfnotes);

startint=[];
for a=1:size(upstates,1);%for each slice
    for b=1:size(upstates,2);%for each recording file
        if evals(a,b)==1;%if multiple upstates
            record=[];
            for c=1:size(upstates,3);%for each trace from an individual cell
                if size(upstates{a,b,c},1)>1;%if multiple upstates
                    record(end+1)=c;
                end
            end
            if ~isempty(record);
                w=min(record);
                ups=upstates{a,b,w};
                starts=ups(:,2);
                startint=cat(2,startint,diff(starts)');
%                 name=abfnotes{a}.abfname{b};
%                 load(name);
%               figure;plot(data(:,c));
%               clear data
            end
        end
    end
end

intervals.startint=startint;
hist(startint);