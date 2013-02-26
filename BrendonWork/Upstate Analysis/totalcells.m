function numbtotal=totalcells(abfnotes,upstates);

for a=1:size(abfnotes,2);%for each slice
    for b=1:size(abfnotes{a}.stimprotocol);%for each possible recording
        if strcmp(abfnotes{a}.stim{b},'tstrain');%stim will not be empty only if there is a valid abf file associated with that trial (an abf which is a recording of the right thing)
            for c=1:3;%for each cell
                numt(a,b,c)=size(upstates{a,b,c},1);
            end
        elseif strcmp(abfnotes{a}.stim{b},'spont');%stim will not be empty only if there is a valid abf file associated with that trial (an abf which is a recording of the right thing)
            for c=1:3;%for each cell
                nums(a,b,c)=size(upstates{a,b,c},1);
            end
        end
    end
end