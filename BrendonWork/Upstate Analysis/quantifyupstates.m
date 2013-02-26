function quant=quantifyupstates(upstates,abfnotes);

warning off MATLAB:divideByZero

stimlength=[];%establishing variables that will be added to with the method 'variable(end+1)=x'
stimamp=[];
stimapnumber=[];
stimavgfiring=[];
stimminisi=[];
stimontau=[];
stimofftau=[];

spontlength=[];
spontamp=[];
spontapnumber=[];
spontavgfiring=[];
spontminisi=[];
spontontau=[];
spontofftau=[]; 

wdstimlength=[];
wdstimamp=[];
wdstimapnumber=[];
wdstimavgfiring=[];
wdstimminisi=[];
wdstimontau=[];
wdstimofftau=[];

relstimspontlength=[];
relstimspontamp=[];
relstimspontapnumber=[];
relstimspontavgfiring=[];
relstimspontminisi=[];
relstimspontontau=[];
relstimspontofftau=[];

relstimwdstimlength=[];
relstimwdstimamp=[];
relstimwdstimapnumber=[];
relstimwdstimavgfiring=[];
relstimwdstimminisi=[];
relstimwdstimontau=[];
relstimwdstimofftau=[];

relspontwdstimlength=[];
relspontwdstimamp=[];
relspontwdstimapnumber=[];
relspontwdstimavgfiring=[];
relspontwdstimminisi=[];
relspontwdstimontau=[];
relspontwdstimofftau=[];


for a=1:size(upstates,1);%for every slice
    in5stimlength=[];%making clean variables for this slice
    in5stimamp=[];
    in5stimapnumber=[];
    in5stimavgfiring=[];
    in5stimminisi=[];
    in5stimontau=[];
    in5stimofftau=[];
    in10stimlength=[];%making clean variables for this slice
    in10stimamp=[];
    in10stimapnumber=[];
    in10stimavgfiring=[];
    in10stimminisi=[];
    in10stimontau=[];
    in10stimofftau=[];
    in14stimlength=[];%making clean variables for this slice
    in14stimamp=[];
    in14stimapnumber=[];
    in14stimavgfiring=[];
    in14stimminisi=[];    
    in14stimontau=[];
    in14stimofftau=[];
    
    in5spontlength=[];%making clean variables for this slice
    in5spontamp=[];
    in5spontapnumber=[];
    in5spontavgfiring=[];
    in5spontminisi=[];
    in5spontontau=[];
    in5spontofftau=[];
    in10spontlength=[];%making clean variables for this slice
    in10spontamp=[];
    in10spontapnumber=[];
    in10spontavgfiring=[];
    in10spontminisi=[];
    in10spontontau=[];
    in10spontofftau=[];
    in14spontlength=[];%making clean variables for this slice
    in14spontamp=[];
    in14spontapnumber=[];
    in14spontavgfiring=[];
    in14spontminisi=[]; 
    in14spontontau=[];
    in14spontofftau=[];
    
    in5wdstimlength=[];%making clean variables for this slice
    in5wdstimamp=[];
    in5wdstimapnumber=[];
    in5wdstimavgfiring=[];
    in5wdstimminisi=[];
    in5wdstimontau=[];
    in5wdstimofftau=[];
    in10wdstimlength=[];%making clean variables for this slice
    in10wdstimamp=[];
    in10wdstimapnumber=[];
    in10wdstimavgfiring=[];
    in10wdstimminisi=[];
    in10wdstimontau=[];
    in10wdstimofftau=[];
    in14wdstimlength=[];%making clean variables for this slice
    in14wdstimamp=[];
    in14wdstimapnumber=[];
    in14wdstimavgfiring=[];
    in14wdstimminisi=[];    
    in14wdstimontau=[];
    in14wdstimofftau=[];

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
                    match=find(match);
                    reading=data(:,match);  
                    ups=upstates{a,b,c};%bring in upstate matrix, which is x by 4
                    %reading=data(:,c);%extract the corresponding data trace for the same reason
                    for d=1:size(ups,1);%for every upstate detected
%                         inup=reading(ups(d,1):ups(d,4));%extract the region in the upstate
                        aps=findaps(reading(ups(d,2):ups(d,3)));%will be a matrix of ap peaks inside a 1 x 1 cell (for historical reasons)
                        
                        ontau=[reading(ups(d,1)) reading(ups(d,2))];
                        ontau=-ontau;
                        ontau(find(ontau<=0))=1;
                        ontau=log(ontau);
                        ontau=polyfit([ups(d,1) ups(d,2)],ontau,1);
                        ontau=abs(.1/ontau(1));
                        
                        offtau=[reading(ups(d,3)) reading(ups(d,4))];
                        offtau=-offtau;
                        offtau(find(offtau<=0))=1;
                        offtau=log(offtau);
                        offtau=polyfit([ups(d,3) ups(d,4)],offtau,1);
                        offtau=abs(.1/offtau(1));
                        
                        if strcmp(abfnotes{a}.stim{b},'tstrain');%if the upstate was stimulated from the thalamus
                            stimlength(end+1)=ups(d,3)-ups(d,2);
                            stimamp(end+1)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                            if ~isempty(aps{1,1});%if any spikes, then fill in the following
                                stimapnumber(end+1)=size(aps{1},2);%number of spikes found
                                stimavgfiring(end+1)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                if size(aps{1},2)>=2;%if at least two spikes
                                    stimminisi(end+1)=min(diff(aps{1}));%find the shortest distance between any two aps
                                end
                            end
                            stimontau(end+1)=ontau;
                            stimofftau(end+1)=offtau;
                            
                            if c==1;
                                in5stimlength(c,d)=ups(d,3)-ups(d,2);
                                in5stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in5stimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in5stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in5stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end        
                                in5stimontau(c,d)=ontau;
                                in5stimofftau(c,d)=offtau;
                            elseif c==2;
                                in10stimlength(c,d)=ups(d,3)-ups(d,2);
                                in10stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in10stimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in10stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in10stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end
                                in10stimontau(c,d)=ontau;
                                in10stimofftau(c,d)=offtau;
                            elseif c==3;
                                in14stimlength(c,d)=ups(d,3)-ups(d,2);
                                in14stimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in14stimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in14stimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in14stimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end
                                in14stimontau(c,d)=ontau;
                                in14stimofftau(c,d)=offtau;
                            end
                        elseif strcmp(abfnotes{a}.stim{b},'spont');%if the upstate was spontaneous
                            spontlength(end+1)=ups(d,3)-ups(d,2);
                            spontamp(end+1)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                            if ~isempty(aps{1,1});%if any spikes, then fill in the following
                                spontapnumber(end+1)=size(aps{1},2);%number of spikes found
                                spontavgfiring(end+1)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                if size(aps{1},2)>=2;%if at least two spikes
                                    spontminisi(end+1)=min(diff(aps{1}));%find the shortest distance between any two aps
                                end
                            end
                            spontontau(end+1)=ontau;
                            spontofftau(end+1)=offtau;

                            if c==1;
                                in5spontlength(c,d)=ups(d,3)-ups(d,2);
                                in5spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in5spontapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in5spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in5spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end        
                                in5spontontau(c,d)=ontau;
                                in5spontfftau(c,d)=offtau;
                            elseif c==2;
                                in10spontlength(c,d)=ups(d,3)-ups(d,2);
                                in10spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in10spontapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in10spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in10spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end
                                in10spontontau(c,d)=ontau;
                                in10spontfftau(c,d)=offtau;
                            elseif c==3;
                                in14spontlength(c,d)=ups(d,3)-ups(d,2);
                                in14spontamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in14spontapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in14spontavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in14spontminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end
                                in14spontontau(c,d)=ontau;
                                in14spontfftau(c,d)=offtau;
                            end
                        
                        elseif strcmp(abfnotes{a}.stim{b},'wdtrain');%if the upstate was spontaneous
                            wdstimlength(end+1)=ups(d,3)-ups(d,2);
                            wdstimamp(end+1)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                            if ~isempty(aps{1,1});%if any spikes, then fill in the following
                                wdstimapnumber(end+1)=size(aps{1},2);%number of spikes found
                                wdstimavgfiring(end+1)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                if size(aps{1},2)>=2;%if at least two spikes
                                    wdstimminisi(end+1)=min(diff(aps{1}));%find the shortest distance between any two aps
                                end
                            end
                            wdstimontau(end+1)=ontau;
                            wdstimofftau(end+1)=offtau;

                            if c==1;
                                in5wdstimlength(c,d)=ups(d,3)-ups(d,2);
                                in5wdstimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in5wdstimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in5wdstimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in5wdstimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end        
                                in5wdstimontau(c,d)=ontau;
                                in5wdstimofftau(c,d)=offtau;
                            elseif c==2;
                                in10wdstimlength(c,d)=ups(d,3)-ups(d,2);
                                in10wdstimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in10wdstimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in10wdstimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in10wdstimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end
                                in10wdstimontau(c,d)=ontau;
                                in10wdstimofftau(c,d)=offtau;
                            elseif c==3;
                                in14wdstimlength(c,d)=ups(d,3)-ups(d,2);
                                in14wdstimamp(c,d)=mean(reading(ups(d,2):ups(d,3)))-reading(ups(d,1));%mean of upstate minus the value before the upstate
                                if ~isempty(aps{1,1});%if some spikes
                                    in14wdstimapnumber(c,d)=size(aps{1},2);%number of spikes found
                                    in14wdstimavgfiring(c,d)=size(aps{1},2)/(ups(d,3)-ups(d,2));%number of spikes found/length of the upstate
                                    if size(aps{1},2)>=2;%if at least two spikes
                                        in14wdstimminisi(c,d)=min(diff(aps{1}));%find the shortest distance between any two aps
                                    end
                                end       
                                in14wdstimontau(c,d)=ontau;
                                in14wdstimofftau(c,d)=offtau;
                            end                            
                            
                            %%%WHAT EXACTLY TO COMPARE BETWEEN CELLS IN THE
                            %%%SAME SLICE?... FIRST, FIND IF EACH UPSTATE
                            %%%IN ONE OVERLAPS WITH UPSTATE IN ANOTHER
                            %%%(OVERLAPPING).  THEN, WHICH STARTS FIRST?
                            %%%WHICH STARTS RISING FIRST?  WHICH FIRES
                            %%%FIRST?
                            
                            %%% ALSO BREAK DOWN BY CELL CLASS: RISE/FALL
                            %%% TIMES, JAGGEDNESS, SPIKES, ISI'S?
                        end                            
                    end
                end
            end
        end
    end
    relstimspontlength(end+1)=mean(in5stimlength(find(in5stimlength)))/mean(in5spontlength(find(in5spontlength)));%mean length of stim ups/mean length of spont ups
    relstimspontlength(end+1)=mean(in10stimlength(find(in10stimlength)))/mean(in10spontlength(find(in10spontlength)));%mean length of stim ups/mean length of spont ups
    relstimspontlength(end+1)=mean(in14stimlength(find(in14stimlength)))/mean(in14spontlength(find(in14spontlength)));%mean length of stim ups/mean length of spont ups

    relstimspontamp(end+1)=mean(in5stimamp(find(in5stimamp)))/mean(in5spontamp(find(in5spontamp)));%mean amp of stim ups/mean amp of spont ups
    relstimspontamp(end+1)=mean(in10stimamp(find(in10stimamp)))/mean(in10spontamp(find(in10spontamp)));%mean amp of stim ups/mean amp of spont ups
    relstimspontamp(end+1)=mean(in14stimamp(find(in14stimamp)))/mean(in14spontamp(find(in14spontamp)));%mean amp of stim ups/mean amp of spont ups
    
    relstimspontapnumber(end+1)=mean(in5stimapnumber(find(in5stimapnumber)))/mean(in5spontapnumber(find(in5spontapnumber)));%mean apnumber of stim ups/mean apnumber of spont ups
    relstimspontapnumber(end+1)=mean(in10stimapnumber(find(in10stimapnumber)))/mean(in10spontapnumber(find(in10spontapnumber)));%mean apnumber of stim ups/mean apnumber of spont ups
    relstimspontapnumber(end+1)=mean(in14stimapnumber(find(in14stimapnumber)))/mean(in14spontapnumber(find(in14spontapnumber)));%mean apnumber of stim ups/mean apnumber of spont ups
    
    relstimspontavgfiring(end+1)=mean(in5stimavgfiring(find(in5stimavgfiring)))/mean(in5spontavgfiring(find(in5spontavgfiring)));%mean avgfiring of stim ups/mean avgfiring of spont ups
    relstimspontavgfiring(end+1)=mean(in10stimavgfiring(find(in10stimavgfiring)))/mean(in10spontavgfiring(find(in10spontavgfiring)));%mean avgfiring of stim ups/mean avgfiring of spont ups
    relstimspontavgfiring(end+1)=mean(in14stimavgfiring(find(in14stimavgfiring)))/mean(in14spontavgfiring(find(in14spontavgfiring)));%mean avgfiring of stim ups/mean avgfiring of spont ups
    
    relstimspontminisi(end+1)=mean(in5stimminisi(find(in5stimminisi)))/mean(in5spontminisi(find(in5spontminisi)));%mean minisi of stim ups/mean minisi of spont ups
    relstimspontminisi(end+1)=mean(in10stimminisi(find(in10stimminisi)))/mean(in10spontminisi(find(in10spontminisi)));%mean minisi of stim ups/mean minisi of spont ups
    relstimspontminisi(end+1)=mean(in14stimminisi(find(in14stimminisi)))/mean(in14spontminisi(find(in14spontminisi)));%mean minisi of stim ups/mean minisi of spont ups

    relstimspontontau(end+1)=mean(in5stimontau(find(in5stimontau)))/mean(in5spontontau(find(in5spontontau)));%mean ontau of stim ups/mean ontau of spont ups
    relstimspontontau(end+1)=mean(in10stimontau(find(in10stimontau)))/mean(in10spontontau(find(in10spontontau)));%mean ontau of stim ups/mean ontau of spont ups
    relstimspontontau(end+1)=mean(in14stimontau(find(in14stimontau)))/mean(in14spontontau(find(in14spontontau)));%mean ontau of stim ups/mean ontau of spont ups    

    relstimspontofftau(end+1)=mean(in5stimofftau(find(in5stimofftau)))/mean(in5spontofftau(find(in5spontofftau)));%mean offtau of stim ups/mean offtau of spont ups
    relstimspontofftau(end+1)=mean(in10stimofftau(find(in10stimofftau)))/mean(in10spontofftau(find(in10spontofftau)));%mean offtau of stim ups/mean offtau of spont ups
    relstimspontofftau(end+1)=mean(in14stimofftau(find(in14stimofftau)))/mean(in14spontofftau(find(in14spontofftau)));%mean offtau of stim ups/mean offtau of spont ups
    
    %%%%%%%%%%%%%%%now compare stim to wdstim   
    relstimwdstimlength(end+1)=mean(in5stimlength(find(in5stimlength)))/mean(in5wdstimlength(find(in5wdstimlength)));%mean length of stim ups/mean length of wdstim ups
    relstimwdstimlength(end+1)=mean(in10stimlength(find(in10stimlength)))/mean(in10wdstimlength(find(in10wdstimlength)));%mean length of stim ups/mean length of wdstim ups
    relstimwdstimlength(end+1)=mean(in14stimlength(find(in14stimlength)))/mean(in14wdstimlength(find(in14wdstimlength)));%mean length of stim ups/mean length of wdstim ups

    relstimwdstimamp(end+1)=mean(in5stimamp(find(in5stimamp)))/mean(in5wdstimamp(find(in5wdstimamp)));%mean amp of stim ups/mean amp of wdstim ups
    relstimwdstimamp(end+1)=mean(in10stimamp(find(in10stimamp)))/mean(in10wdstimamp(find(in10wdstimamp)));%mean amp of stim ups/mean amp of wdstim ups
    relstimwdstimamp(end+1)=mean(in14stimamp(find(in14stimamp)))/mean(in14wdstimamp(find(in14wdstimamp)));%mean amp of stim ups/mean amp of wdstim ups
    
    relstimwdstimapnumber(end+1)=mean(in5stimapnumber(find(in5stimapnumber)))/mean(in5wdstimapnumber(find(in5wdstimapnumber)));%mean apnumber of stim ups/mean apnumber of wdstim ups
    relstimwdstimapnumber(end+1)=mean(in10stimapnumber(find(in10stimapnumber)))/mean(in10wdstimapnumber(find(in10wdstimapnumber)));%mean apnumber of stim ups/mean apnumber of wdstim ups
    relstimwdstimapnumber(end+1)=mean(in14stimapnumber(find(in14stimapnumber)))/mean(in14wdstimapnumber(find(in14wdstimapnumber)));%mean apnumber of stim ups/mean apnumber of wdstim ups
    
    relstimwdstimavgfiring(end+1)=mean(in5stimavgfiring(find(in5stimavgfiring)))/mean(in5wdstimavgfiring(find(in5wdstimavgfiring)));%mean avgfiring of stim ups/mean avgfiring of wdstim ups
    relstimwdstimavgfiring(end+1)=mean(in10stimavgfiring(find(in10stimavgfiring)))/mean(in10wdstimavgfiring(find(in10wdstimavgfiring)));%mean avgfiring of stim ups/mean avgfiring of wdstim ups
    relstimwdstimavgfiring(end+1)=mean(in14stimavgfiring(find(in14stimavgfiring)))/mean(in14wdstimavgfiring(find(in14wdstimavgfiring)));%mean avgfiring of stim ups/mean avgfiring of wdstim ups
    
    relstimwdstimminisi(end+1)=mean(in5stimminisi(find(in5stimminisi)))/mean(in5wdstimminisi(find(in5wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups
    relstimwdstimminisi(end+1)=mean(in10stimminisi(find(in10stimminisi)))/mean(in10wdstimminisi(find(in10wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups
    relstimwdstimminisi(end+1)=mean(in14stimminisi(find(in14stimminisi)))/mean(in14wdstimminisi(find(in14wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups

    relstimwdstimontau(end+1)=mean(in5stimontau(find(in5stimontau)))/mean(in5wdstimontau(find(in5wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups
    relstimwdstimontau(end+1)=mean(in10stimontau(find(in10stimontau)))/mean(in10wdstimontau(find(in10wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups
    relstimwdstimontau(end+1)=mean(in14stimontau(find(in14stimontau)))/mean(in14wdstimontau(find(in14wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups

    relstimwdstimofftau(end+1)=mean(in5stimofftau(find(in5stimofftau)))/mean(in5wdstimofftau(find(in5wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups
    relstimwdstimofftau(end+1)=mean(in10stimofftau(find(in10stimofftau)))/mean(in10wdstimofftau(find(in10wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups
    relstimwdstimofftau(end+1)=mean(in14stimofftau(find(in14stimofftau)))/mean(in14wdstimofftau(find(in14wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups

    %compare spont to wdstim
    relspontwdstimlength(end+1)=mean(in5spontlength(find(in5spontlength)))/mean(in5wdstimlength(find(in5wdstimlength)));%mean length of stim ups/mean length of wdspont ups
    relspontwdstimlength(end+1)=mean(in10spontlength(find(in10spontlength)))/mean(in10wdstimlength(find(in10wdstimlength)));%mean length of spont ups/mean length of wdstim ups
    relspontwdstimlength(end+1)=mean(in14spontlength(find(in14spontlength)))/mean(in14wdstimlength(find(in14wdstimlength)));%mean length of spont ups/mean length of wdstim ups

    relspontwdstimamp(end+1)=mean(in5spontamp(find(in5spontamp)))/mean(in5wdstimamp(find(in5wdstimamp)));%mean amp of spont ups/mean amp of wdstim ups
    relspontwdstimamp(end+1)=mean(in10spontamp(find(in10spontamp)))/mean(in10wdstimamp(find(in10wdstimamp)));%mean amp of spont ups/mean amp of wdstim ups
    relspontwdstimamp(end+1)=mean(in14spontamp(find(in14spontamp)))/mean(in14wdstimamp(find(in14wdstimamp)));%mean amp of spont ups/mean amp of wdstim ups
    
    relspontwdstimapnumber(end+1)=mean(in5spontapnumber(find(in5spontapnumber)))/mean(in5wdstimapnumber(find(in5wdstimapnumber)));%mean apnumber of spont ups/mean apnumber of wdstim ups
    relspontwdstimapnumber(end+1)=mean(in10spontapnumber(find(in10spontapnumber)))/mean(in10wdstimapnumber(find(in10wdstimapnumber)));%mean apnumber of spont ups/mean apnumber of wdstim ups
    relspontwdstimapnumber(end+1)=mean(in14spontapnumber(find(in14spontapnumber)))/mean(in14wdstimapnumber(find(in14wdstimapnumber)));%mean apnumber of spont ups/mean apnumber of wdstim ups
    
    relspontwdstimavgfiring(end+1)=mean(in5spontavgfiring(find(in5spontavgfiring)))/mean(in5wdstimavgfiring(find(in5wdstimavgfiring)));%mean avgfiring of spont ups/mean avgfiring of wdstim ups
    relspontwdstimavgfiring(end+1)=mean(in10spontavgfiring(find(in10spontavgfiring)))/mean(in10wdstimavgfiring(find(in10wdstimavgfiring)));%mean avgfiring of spont ups/mean avgfiring of wdstim ups
    relspontwdstimavgfiring(end+1)=mean(in14spontavgfiring(find(in14spontavgfiring)))/mean(in14wdstimavgfiring(find(in14wdstimavgfiring)));%mean avgfiring of spont ups/mean avgfiring of wdstim ups
    
    relspontwdstimminisi(end+1)=mean(in5spontminisi(find(in5spontminisi)))/mean(in5wdstimminisi(find(in5wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups
    relspontwdstimminisi(end+1)=mean(in10spontminisi(find(in10spontminisi)))/mean(in10wdstimminisi(find(in10wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups
    relspontwdstimminisi(end+1)=mean(in14spontminisi(find(in14spontminisi)))/mean(in14wdstimminisi(find(in14wdstimminisi)));%mean minisi of stim ups/mean minisi of wdstim ups

    relspontwdstimontau(end+1)=mean(in5spontontau(find(in5spontontau)))/mean(in5wdstimontau(find(in5wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups
    relspontwdstimontau(end+1)=mean(in10spontontau(find(in10spontontau)))/mean(in10wdstimontau(find(in10wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups
    relspontwdstimontau(end+1)=mean(in14spontontau(find(in14spontontau)))/mean(in14wdstimontau(find(in14wdstimontau)));%mean ontau of stim ups/mean ontau of wdstim ups
    
    relspontwdstimofftau(end+1)=mean(in5spontofftau(find(in5spontofftau)))/mean(in5wdstimofftau(find(in5wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups
    relspontwdstimofftau(end+1)=mean(in10spontofftau(find(in10spontofftau)))/mean(in10wdstimofftau(find(in10wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups
    relspontwdstimofftau(end+1)=mean(in14spontofftau(find(in14spontofftau)))/mean(in14wdstimofftau(find(in14wdstimofftau)));%mean offtau of stim ups/mean offtau of wdstim ups
            
end

quant.stimlength=stimlength;
quant.stimamp=stimamp;
quant.stimapnumber=stimapnumber;
quant.stimavgfiring=stimavgfiring;
quant.stimminisi=stimminisi;
quant.stimontau=stimontau;
quant.stimofftau=stimofftau;

quant.spontlength=spontlength;
quant.spontamp=spontamp;
quant.spontapnumber=spontapnumber;
quant.spontavgfiring=spontavgfiring;
quant.spontminisi=spontminisi;
quant.spontontau=spontontau;
quant.spontofftau=spontofftau;

quant.wdstimlength=wdstimlength;
quant.wdstimamp=wdstimamp;
quant.wdstimapnumber=wdstimapnumber;
quant.wdstimavgfiring=wdstimavgfiring;
quant.wdstimminisi=wdstimminisi;
quant.wdstimontau=wdstimontau;
quant.wdstimofftau=wdstimofftau;

quant.relstimspontlength=relstimspontlength;
quant.relstimspontamp=relstimspontamp;
quant.relstimspontapnumber=relstimspontapnumber;
quant.relstimspontavgfiring=relstimspontavgfiring;
quant.relstimspontminisi=relstimspontminisi;
quant.relstimspontontau=relstimspontontau;
quant.relstimspontofftau=relstimspontofftau;

quant.relstimwdstimlength=relstimwdstimlength;
quant.relstimwdstimamp=relstimwdstimamp;
quant.relstimwdstimapnumber=relstimwdstimapnumber;
quant.relstimwdstimavgfiring=relstimwdstimavgfiring;
quant.relstimwdstimminisi=relstimwdstimminisi;
quant.relstimwdstimontau=relstimwdstimontau;
quant.relstimwdstimofftau=relstimwdstimofftau;

quant.relspontwdstimlength=relspontwdstimlength;
quant.relspontwdstimamp=relspontwdstimamp;
quant.relspontwdstimapnumber=relspontwdstimapnumber;
quant.relspontwdstimavgfiring=relspontwdstimavgfiring;
quant.relspontwdstimminisi=relspontwdstimminisi;
quant.relspontwdstimontau=relspontwdstimontau;
quant.relspontwdstimofftau=relspontwdstimofftau;