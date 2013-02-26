function match=channelmatch(header,c)
%based on which cell number we want to find, c, ie cell 1,2, or 3, which
%channel in a trace from axoscope corresponds to that cell.  This is
%necssary b/c the same cell can be on channel "IN 5" or "IN 11", "IN 10" 
%or "IN 7" (IN 5 always corresponds to the same cell)
channels=channelnames(header);%record the names of the channels recorded, ie "IN 5", "IN 10" or "IN 14"
match=[];    
if c==1;%figuring out which channel corresponds with which tracenumber, so that trace can be displayed
    for q=1:size(channels,2);
        if strcmp(channels(q),'IN 5') || strcmp(channels(q),'IN 11');
            match(q)=1;
        else
            match(q)=0;
        end
    end
    if sum(match)>1;
        correct=[];
        o=channels(logical(match));
        m=find(match);
        for y=1:length(o);
            correct(y)=strcmp(o(y),'IN 5');
        end
        match(m(~correct))=0;
    end
elseif c==2;
    for q=1:size(channels,2);
        if strcmp(channels(q),'IN 10') || strcmp(channels(q),'IN 7');
            match(q)=1;
        else
            match(q)=0;
        end
    end
    if sum(match)>1;
        correct=[];
        o=channels(logical(match));
        m=find(match);
        for y=1:length(o);
            correct(y)=strcmp(o(y),'IN 5');
        end
        match(m(~correct))=0;
    end
elseif c==3;
    for q=1:size(channels,2);
        if strcmp(channels(q),'IN 14') || strcmp(channels(q),'IN 15');
            match(q)=1;
        else
            match(q)=0;
        end
    end
    if sum(match)>1;
        correct=[];
        o=channels(logical(match));
        m=find(match);
        for y=1:length(o);
            correct(y)=strcmp(o(y),'IN 5');
        end
        match(m(~correct))=0;
    end
end
match=find(match);