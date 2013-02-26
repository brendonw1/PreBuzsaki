function allaps=countaps(upstates,abfnotes);

warning off MATLAB:divideByZero

for a=1:size(upstates,1);%for every slice
    for b=1:size(upstates,2);%for each file
        emp=[];
        for bb=1:size(upstates,3);%for each trace in that record
           emp(bb)=~isempty(upstates{a,b,bb});%record whether there is an upstate found in each record
        end
        if sum(emp)>0;%if there is any upstate in this file, load it by...
            name1=abfnotes{a}.abfname{b};%get name of the electrophys recording to open from the abfnotes cell
            a
            b
            name1
            load(name1);%load data from that file into the workspace... this will have multiple traces in it as columns of the variable "data"
            channels=channelnames(header);%record the names of the channels recorded, ie "IN 5", "IN 10" or "IN 14"
            match=[];
            for c=1:size(upstates,3);%for each trace in the loaded file
                if ~isempty(upstates{a,b,c});%if upstates detected;
                    if c==1;%figuring out which channel corresponds with which tracenumber, so that trace can be displayed
                        for q=1:size(channels,2);
                            if strcmp(channels(q),'IN 5') | strcmp(channels(q),'IN 11');
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
                            if strcmp(channels(q),'IN 10') | strcmp(channels(q),'IN 7');
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
                            if strcmp(channels(q),'IN 14') | strcmp(channels(q),'IN 15');
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
                    match=find(match);%tells which channels have upstates... ie IN5/11, IN10/7, or IN14/15
                    reading=data(:,match);  
                    ups=upstates{a,b,c};%bring in upstate matrix, which is x by 4
                    %reading=data(:,c);%extract the corresponding data trace for the same reason
                    for d=1:size(ups,1);%for every upstate detected
%                         inup=reading(ups(d,1):ups(d,4));%extract the region in the upstate
                        aps=findaps(reading(ups(d,2):ups(d,3)));%will be a matrix of ap peaks inside a 1 x 1 cell (for historical reasons)
                        if strcmp(abfnotes{a}.stim{b},'tstrain');%if the upstate was stimulated from the thalamus
                            goodt(a,b,c,d)=1;
                            if ~isempty(aps{1,1});%if any spikes, then fill in the following
                                stimaps(a,b,c,d)=size(aps{1},2);%number of spikes found
                            end
%                             if c==1;
%                                 in5stimlength(c,d)=ups(d,3)-ups(d,2);
%                                 in5stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in5stimapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in5stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in5stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end        
%                             elseif c==2;
%                                 in10stimlength(c,d)=ups(d,3)-ups(d,2);
%                                 in10stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in10stimapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in10stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in10stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end
%                             elseif c==3;
%                                 in14stimlength(c,d)=ups(d,3)-ups(d,2);
%                                 in14stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in14stimapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in14stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in14stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end
%                             end
                        elseif strcmp(abfnotes{a}.stim{b},'spont');%if the upstate was spontaneous
                            goods(a,b,c,d)=1;
                            if ~isempty(aps{1,1});%if any spikes, then fill in the following
                                spontaps(a,b,c,d)=size(aps{1},2);%number of spikes found
                            end
% 
%                             if c==1;
%                                 in5spontlength(c,d)=ups(d,3)-ups(d,2);
%                                 in5spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in5spontapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in5spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in5spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end        
%                             elseif c==2;
%                                 in10spontlength(c,d)=ups(d,3)-ups(d,2);
%                                 in10spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in10spontapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in10spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in10spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end
%                             elseif c==3;
%                                 in14spontlength(c,d)=ups(d,3)-ups(d,2);
%                                 in14spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
%                                 if ~isempty(aps{1,1});%if some spikes
%                                     in14spontapnumber(c,d)=size(aps{1},2);%number of spikes found
%                                     in14spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
%                                     if size(aps{1},2)>=2;%if at least two spikes
%                                         in14spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
%                                     end
%                                 end
%                             end
                        end                            
                    end
                end
            end
        end
    end
end

allaps.stim=stimaps;
allaps.spont=spontaps;

t=stimaps;
s=spontaps;
tt=zeros(size(t));
tt(find(t))=1;
ss=zeros(size(s));
ss(find(s))=1;

cell=0;
pert=[];
totalt=[];
for a=1:size(goodt,1);
    for c=1:size(goodt,3);
        cell=cell+1;
        denom=sum(sum(goodt(a,:,c,:)));
        totalt(end+1)=denom;
        if denom>1;%must have at least 2 upstates
            numer=sum(sum(tt(a,:,c,:)));
            pert(end+1)=numer/denom;
        end
    end
end
figure
subplot(2,1,1);
percenthist(pert,10)
title ('Triggered: Distribution of cells by repeatability')
m=mean(pert);
s=std(pert);
m2=mean(pert(find(pert)));
s2=std(pert(find(pert)));
totalt=totalt(totalt>1);
text(.2,.9,['mean of all = ',num2str(m)])
text(.2,.8,['SD of all = ',num2str(s)])
text(.2,.7,['mean of active = ',num2str(m2)])
text(.2,.6,['SD of active = ',num2str(s2)])
text(.6,.9,['Total Cells = ',num2str(length(totalt))])
text(.6,.8,['2 to ',num2str(max(totalt)),' upstates per cell.'])
text(.6,.7,[num2str(mean(totalt)),'+/-',num2str(std(totalt)),' UPs per cell'])
xlabel('Percent Repetition')
ylabel('Proportion of Cells')

cell=0;
pers=[];
totals=[];
for a=1:size(goods,1);
    for c=1:size(goods,3);
        cell=cell+1;
        denom=sum(sum(goods(a,:,c,:)));
        totals(end+1)=denom;
        if denom>1;%must have at least 2 upstates
            numer=sum(sum(ss(a,:,c,:)));
            pers(end+1)=numer/denom;
        end
    end
end
subplot(2,1,2);
percenthist(pers,10)
title ('Spontaneous: Distribution of cells by repeatability')
m=mean(pers);
s=std(pers);
m2=mean(pers(find(pers)));
s2=std(pers(find(pers)));
totals=totals(totals>1);
text(.2,.9,['mean of all = ',num2str(m)])
text(.2,.8,['SD of all = ',num2str(s)])
text(.2,.7,['mean of active = ',num2str(m2)])
text(.2,.6,['SD of active = ',num2str(s2)])
text(.6,.9,['Total Cells = ',num2str(length(totals))])
text(.6,.8,['2 to ',num2str(max(totals)),' upstates per cell.'])
text(.6,.7,[num2str(mean(totals)),'+/-',num2str(std(totals)),' UPs per cell'])
xlabel('Percent Repetition')
ylabel('Proportion of Cells')

[h,p]=ttest2(pers(find(pers)),pert(find(pert)));
text(.6,.6,['p btw spont and stim ',num2str(p)])

cell=0;
pers=[];
pert=[];
for a=1:size(goods,1);
    for c=1:size(goods,3);
        cell=cell+1;
        denom=sum(sum(goods(a,:,c,:)));
        if denom>1;%must have at least 2 upstates
            numer=sum(sum(ss(a,:,c,:)));
            pers(cell)=numer/denom;
        end
        denom=sum(sum(goodt(a,:,c,:)));
        if denom>1;%must have at least 2 upstates
            numer=sum(sum(tt(a,:,c,:)));
            pert(cell)=numer/denom;
        end
        if sum(sum(goods(a,:,c,:)))>1 & sum(sum(goodt(a,:,c,:)))>1
            doublegood(cell)=1;
        end
    end
end
doublegood=logical(doublegood);
