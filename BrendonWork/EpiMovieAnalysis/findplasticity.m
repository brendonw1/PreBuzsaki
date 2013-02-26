function sorted=findplasticity(sorted)
%this functions will look for a type of plasticity in movies where a single
%stim to thalamus does nothing at first, but after a few trains of
%stimulation to thalamus, which evoke network upstates, a single stim can
%evoke a large network activation.  


for a=1:size(sorted,2);%for each slice
    if size(sorted{a}.tssingle,2)>1;%if more than one tssingle was done
        tssingletotals=[];
        for b=1:size(sorted{a}.tssingle,2);
            tssingletotals(b)=sum(sorted{a}.tssingle(b).ons(1:end));%find how many cells in each tssingle movie
        end
        di=diff(tssingletotals);
        di=find(di>0);%find any instance where a later movie had more cells on than in an earlier movie
        if ~isempty(di);%if some such instances
            tssinglenumb=[];
            tstrainnumb=[];
            for z=1:size(sorted{a}.tssingle,2)
                tssinglenumb(z)=sorted{a}.tssingle(z).index;%record the original experiment sequence numbers of the ts single movies
            end
            for z=1:size(sorted{a}.tstrain,2)
                tstrainnumb(z)=sorted{a}.tstrain(z).index;%record the original experiment sequence numbers of the ts train movies
            end
            for c=1:length(di)%for each potential plastic change
                firstsingle=tssinglenumb(di(c));%record the index number of the lesser event
                secondsingle=tssinglenumb(di(c)+1);%and the subsequent larger event
                trainbetween=find(tstrainnumb<secondsingle&tstrainnumb>firstsingle);%record any intervening tstrain events
%                 for d=1:length(trainbetween);
%                     ind=tstrainnumb(trainbetween(d));
%                     trash(d)=sum(sorted{a}.tstrain(ind).ons(1:end));   
%                 end
%                 trash=trash(find(max(trash)))
                if ~isempty(trainbetween)%if any tstrain events were between the tssingle events
                    figure(a)%make a figure, and display the tstrain and tssingle events
                    subplot(2,2,1)
                    highlightons(sorted{a}.contours,logical(sum(sorted{a}.tssingle(di(c)).ons)))
                    title ('First single stim')
                    subplot(2,2,2)
                    highlightons(sorted{a}.contours,logical(sum(sorted{a}.tssingle(di(c)+1).ons)))
                    title ('Second single stim')
                    subplot(2,2,3)
                    highlightons(sorted{a}.contours,logical(sum(sorted{a}.tstrain(trainbetween(1)).ons)))
                    if length(trainbetween)>1
                        subplot(2,2,4)
                        highlightons(sorted{a}.contours,logical(sum(sorted{a}.tstrain(trainbetween(2)).ons)))
                    end
                    in=input('Is this an example of plasticity? y/n: ','s')%ask for user input 
                    in=strcmp('y',in);
                    close
                    if in
                        sorted{a}.tssingle(di(c)+1).plasticity=1;%if judged to be a plasticity event, record that for that movie
                    end
                end
            end
        end
    end
end