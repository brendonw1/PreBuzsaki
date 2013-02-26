function matches=findbestmatchingspikes(aps1,aps2);
if isempty(aps1) | isempty(aps2)
    matches=[];
    return
end
table=abs(repmat(aps1',[1 length(aps2)])-repmat(aps2,[length(aps1) 1]));
%to get all distances between all spikes
num=min(size(table));
matches=[];
while size(matches,1)<num;%for each match to be found
    addresses=find(table==min(table(:)));%find place where the least distance
    [x,y]=ind2sub(size(table),addresses);%convert to x,y coords for the matrix
    if length(addresses)==1;%if a unique best value is found
        matches(end+1,:)=[x y];
        table(x,:)=Inf;%eliminate this match for the next iteration
        table(:,y)=Inf;
    elseif length(addresses)>1;%if a tie for the best match here
        indepx=zeros(size(x));%set up to search for aps1 spikes that were
            %found to have this minimum value only once
        indepx1=unique(x);
        for b=1:length(indepx1);
            temp=find(x==indepx1(b));
            if length(temp)==1;
                indepx(temp)=1;%set up a vector of which aps1's have unique
                    %aps2 matches
            end
        end
        indepy=zeros(size(y));%repeat for aps2 to aps1
        indepy1=unique(y);
        for b=1:length(indepy1);
            temp=find(y==indepy1(b));
            if length(temp)==1;
                indepy(temp)=1;
            end
        end
        indep=find(indepx.*indepy);%find which are independent both ways... use
            %below
        if length(indep)>0;%if any matches not conflicting with others
            for b=1:length(indep);%go through them, saving them and eliminating
                tempx=x(indep(b));%those spikes from further analysis
                tempy=y(indep(b));
                matches(end+1,:)=[tempx tempy];
                table(tempx,:)=Inf;
                table(:,tempy)=Inf;
            end
        end
        
        dep=~(indepx.*indepy);%test for aps that had two matches
        dep=find(dep);%get indices of those
        if length(dep>0);%find a match with the smallest value outside
                %the matches found above.  Return this to the big loop to
                %repeat
            tietable=table;%to manipulate
            tietable(addresses)=Inf;%so won't be found in later "min" function
            smallest=Inf;%dummy for now
            for b=1:length(x);%go through all rows and all columns (below) to find
                [tievalue,tempaddress]=min(tietable(x(b),:));%the smallest value
                if tievalue<smallest%outside of the tied min... and remember it's
                    tieaddressx=(x(b));%address...
                    tieaddressy=tempaddress;
                    smallest=tievalue
                end
            end
            for b=1:length(y);
                [tievalue,tempaddress]=min(tietable(:,y(b)));
                if tievalue<smallest
                    tieaddressx=tempaddress;
                    tieaddressy=(y(b));
                    smallest=tievalue;
                end
            end
            x=tieaddressx;%... out of that, make a new x and y to save and elim
            y=tieaddressy;
            matches(end+1,:)=[x y];
            table(x,:)=Inf;%eliminate this match for the next iteration
            table(:,y)=Inf;
        end
    end
end
%     if prod(size(table))=1;
%         match=min(