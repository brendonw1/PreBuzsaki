function [ups]=findupstates(reading);
% function [ups, upaps]=findupstates(data);

% gives start and end points for upstates in the trace in "data" 
% Output ups is a 4 column matrix, in each 4 column matrix:
% Column 1: time point of beginning of upswing into upstate
% Column 2: time point of beginning of upstate
% Column 3: time point of end of upstate
% Column 4: time point of end of downswing from upstate
% 1 row for each upstate found with the trace

% Two kinds of upstates are found: those above 5mV (with
% possible short dip that does not go below 3mV) and those above 3mV but
% which has 6Hz firing it at least once.  Any upstate which starts before
% the beginning of the trace or ends after the end of the trace are not
% recorded.  All upstates must be at least 500ms long (5000 data points)
% and less than 15 seconds (150000 data points).

% upaps is another output, which is also a cell, it lists action potentials 
% inside each upstate.  In the cell there is one
% row for each trace and one column for each upstate found in that trace.
% Inside each element of the cell {a,b} is a vector listing time points of action
% potentials in upstate b of trace a.

aps=findaps(reading);
% ups=cell(1,size(data,2));
% upaps=cell(1,size(data,2));
ups=[];
upaps={};
tempups=[];

% % for a=find(evaluated);
% for a=size(data,2);%for each trace
    a=1;%shortcut b/c only dealing with one trace at a time
    
    if length(reading)<1200000;%if total length is less than 2 minutes
    	[baseline,trash]=findbase(reading);%make a baseline for the whole reading... line of best fit to most common range in reading
    else%if 2 minutes or longer
        remain=rem(size(reading,1),100);
        if remain>0;%if number of points is not divisible by 100
            remvals=reading(end-(remain-1):end);
            remmean=mean(remvals);
            newreading=reading;
            addon=remmean(ones(100-remain,1));        
            newreading=cat(1,newreading,addon);
            baseline=reshape(newreading,[100 size(newreading,1)/100]);%set up for 100 fold decimation of data  
            baseline=mean(baseline);%decimation to 1 point per 10ms is complete
            baselinemean=mean(baseline);%for next step
            baseline=baseline-baselinemean;%subtract mean to minimize covolving probs at edges
            baseline=conv(hamming(6000)/sum(hamming(6000)),baseline);%convolve with a 4500 point = 45 sec filter
	%         baseline=conv(ones(3000,1)/3000,baseline);%convolve with a 3000 point = 30 sec filter
            baseline=baseline(3001:end-(3000-1));%get rid of convolvement artifacts
            baseline=baseline+baselinemean;%bring back to actual values
            baseline=repmat(baseline,[100 1]);
            baseline=baseline(1:end)';
            baseline(end-(size(addon,1)-1):end)=[];
        else%if divisible by 100
            baseline=reshape(reading,[100 size(reading,1)/100]);%set up for 100 fold decimation of data  
            baseline=mean(baseline);%decimation to 1 point per 10ms is complete
            baselinemean=mean(baseline);%for next step
            baseline=baseline-baselinemean;%subtract mean to minimize covolving probs at edges
            baseline=conv(hamming(3000)/sum(hamming(3000)),baseline);%convolve with a 3000 point = 30 sec filter
	%         baseline=conv(ones(3000,1)/3000,baseline);%convolve with a 3000 point = 30 sec filter
            baseline=baseline(1501:end-(1500-1));%get rid of convolvement artifacts
            baseline=baseline+baselinemean;%bring back to actual values
            baseline=repmat(baseline,[100 1]);
            baseline=baseline(1:end)';
        end
    end
    
    filtlength=5000;%.50 second filter to find upstates 
    tr=reading-baseline;%subtract baseline from reading
	filt=conv(ones(filtlength,1)/filtlength,tr);%convolve with filter
	filt=filt(filtlength/2+1:end-(filtlength/2-1));%eliminate edges
    
    tempups=continuousabove(filt+baseline,baseline,5,5000,150000);%find all periods continously above 5 mV and are between 500ms and 15sec long

    %NEXT, ELIMINATE UPSTATES THAT GO OFF EITHER END OF THE READING
    if~isempty(tempups);
        if tempups(1,1)<100;%if the first upstate starts earlier than 10ms after the start of the reading
            tempups(1,:)=[];%throw it away
        end
    end
    if~isempty(tempups);
        if tempups(size(tempups,1),2)>length(reading)-100;%if the last upstate ends later than 10ms before the end of the reading (ie if cell dying)
            tempups(size(tempups,1),:)=[];%throw it away
        end
    end
    %NEXT, IN CASE TWO UPSTATES ARE REALLY PART OF ONE BIGGER
    %UPSTATE WHICH JUST HAS A SMALL DIP IN IT (NOT GOING BELOW 3MV
    %ABOVE BASELINE
    if size(tempups,1)>1;%if more than one potential upstate detected
        e2=tempups(:,2);%take ends of all upstates
        b2=tempups(:,1);%filt(ends(good))-(lengths(good)-1)';%take all beginnings
        e2(end)=[];%prepare for comparison
        b2(1)=[];%ditto
        between=b2-e2;%subtract beginning of each movie from end of last
        for j=length(between):-1:1;%for each difference
            bet2=filt(e2(j):b2(j));%find portion of convolved reading between the depolarized areas
            if between(j)<20000;%for periods less than 2 seconds long
                trash=find(bet2<1);%is there any area that dips below 1mV above baseline?
                if isempty(trash);%if not...
                    tempups(j,2)=tempups(j+1,2);%make end of the first upstate now equal to the end of the 2nd... 1 big upstate
                    tempups(j+1,:)=[];%eliminate record of 2nd upstate
                end
            end
        end
    end
    %NOW FIND REAL BEGINNING AND END OF EACH UPSTATE, NOT BEGINNING
    %AND END OF THE SMOOTHED CURVE.  DO THIS BY LOOKING AT A
    %BASELINE CREATED FROM ONLY THE POINTS IN THIS REGION IN THE
    %ORIGINAL reading.  WHERE DOES THE UPSTATE FIRST CROSS THAT
    %BASELINE AND LAST CROSS IT.  LATER FIND WHERE THE UPSWING FROM
    %DOWNSTATE STARTS AND THE DOWNSWING TO DOWNSTATE ENDS
    
    if ~isempty(tempups);
        ups=findfirstlast(reading,filt,baseline,tempups,20000,.5,5000,5);%find beginning and end of upstates: 
    %First point 2sec before or after found upstate that is above 5mV that is followed 
    %by a region that is .5mV above baseline for at least 500ms (and that region must 
    %overlap with the found upstate).  Last is the last such point
    %preceeded by the continuous region.
    end
    tempups=[];
    
    
    filt2=find(filt>3);%arbitrary threshold of 3mV
	if max(diff(diff(filt2)))==0 & length(filt2>5000) & length(filt2<150000);%if only 1 potential upstate found
        tempups = [filt2(1) filt2(end)];
        %NEXT, ELIMINATE UPSTATES THAT GO OFF EITHER END OF THE reading
        if tempups(1)<100;%if the first upstate starts earlier than 10ms after the start of the reading
            tempups=[];%throw it away
        end
        if ~isempty(tempups);%if any potential upstates
            if tempups(1,2)>length(reading)-100;%if the last upstate ends later than 10ms before the end of the reading (ie if cell dying)
                tempups=[];%throw it away
            end
        end
        %ALLOW THIS KIND OF SMALL-DEFLECTION UPSTATE ONLY IF IT HAS AT LEAST
        %3 ACTION POTENTIALS IN IT THEY OCCUR AT 6 HZ FOR AT LEAST ONE INSTANT
%         for f=1:size(ups{a},1);%for each previously detected upstate
        
        if ~isempty(tempups);%if any potential upstates
            inaps=aps{a}(find(aps{a}>=tempups(1) & aps{a}<=tempups(2)));%find action potentials in the range of the potential upstate
            if length(inaps)>2;%if 3 or more aps
                inaps2=inaps(3:end);
                inaps3=inaps(1:end-2);
                intervals=inaps2-inaps3;%find intervals between each ap and the ap 2 down in the order
                mi=min(intervals);%find the minimum such interval
                if mi>10000;%if the fastest interval between aps is less than 10000 data points (1000ms)
                    tempups=[];
                end
            else%if not 3 or more aps
                tempups=[];%don't keep this upstate
            end
        end
        %eliminate any tempups that overlap with known upstates
        for h=1:size(tempups,1);
            for f=1:size(ups,1);%for each previously detected upstate
                if ~isempty(tempups);
                    ol=overlapping(tempups(h,1:2),ups(f,1:2));
                    if ~ol;
%                 if ~((tempups(h,1)>testabove(f,1) & tempups(h,1)<testabove(f,2)) | (tempups(h,2)>testabove(f,1) & tempups(h,2)<testabove(f,2)) | (testabove(f,1)>tempups(h,1) & testabove(f,1)<tempups(h,2)) | (testabove(f,2)>tempups(h,1) & testabove(f,2)<tempups(h,2))...
%                         | (tempups(h,1)<ups(f,2) & tempups(h,2)>ups(f,3)) | (tempups(h,1)>ups(f,2) & tempups(h,2)<ups(f,3)));%if none of the found edges overlap with any known pair of other upstate edges
%                 if ~((tempups(1)>ups{a}(f,2) &
%                 tempups(1)<ups{a}(f,3)) | (tempups(2)>ups{a}(f,2) & tempups(2)<ups{a}(f,3)) | (ups{a}(f,2)>tempups(1) & ups{a}(f,2)<tempups(2)) | (ups{a}(f,3)>tempups(1) & ups{a}(f,3)<tempups(2)));%if none of the found edges overlap with any known pair of other upstate edges
                    else%if there is overlap between known upstate and new one
                       tempups=[];%don't keep this upstate
                    end
                end
            end
        end
        
    elseif length(filt2>0);%if many possible upstates
		ends=find(diff(filt2)~=1);%find breaks between potential upstates
        ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
        ends(end+1)=length(filt2);%one of the ends comes at the last found point above baseline
        ends=sort(ends);
        lengths=diff(ends);%length of each potential upstate
        good=find(lengths>5000 & lengths<150000);%must be longer than 500ms but shorter than 15sec
        ends(1)=[];%lose the 0 added before
        %NEXT, ELIMINATE UPSTATES THAT GO OFF EITHER END OF THE reading
        if ~isempty(good);
            if filt2(ends(good(1)))-(lengths(good(1))-1)<100;%if the first upstate starts earlier than 10ms after the start of the reading
                good(1)=[];%throw it away
            end
            if filt2(ends(good(end)))>length(reading)-100;%if the last upstate ends later than 10ms before the end of the reading (ie if cell dying)
                good(end)=[];%throw it away
            end
            e3=reshape(filt2(ends(good)),[length(good) 1]);
            l3=reshape(lengths(good)-1,[length(good) 1]);
            tempups(:,2)=e3;%upstate ends according to the averaged reading
            tempups(:,1)=e3-l3;%upstate beginnings according to averaged reading
            %ALLOW THIS KIND OF SMALL-DEFLECTION UPSTATE ONLY IF IT HAS AT LEAST
            %3 ACTION POTENTIALS IN IT THEY OCCUR AT 6 HZ FOR AT LEAST ONE
            %INSTANT
            if ~isempty(tempups);
                for g=size(tempups,1):-1:1;%for each potential 3mV upstate
                    inaps=aps{a}(find(aps{a}>=tempups(g,1) & aps{a}<=tempups(g,2)));%find action potentials in the range of the potential upstate
                    if length(inaps)>2;%if 3 or more aps
                        inaps2=inaps(3:end);
                        inaps3=inaps(1:end-2);
                        intervals=inaps2-inaps3;%find intervals between each ap and the ap 2 down in the order
                        mi=min(intervals);%find the minimum such interval
                        if mi>10000;%if the fastest interval between aps is more than 10000 data points (500ms)
                            tempups(g,:)=[];%don't keep that upstate
                        end
                    else%if not 3 or more aps
                       tempups(g,:)=[];%don't keep this upstate
                    end
                end
            end
            
            for f=1:size(ups,1)%for each previously detected upstate
%             for f=1:size(ups{a},1)%for each previously detected upstate
               for g=size(tempups,1):-1:1;%for each potential 3mV upstate
                   ol=overlapping(tempups(g,1:2),ups(f,2:3));
                   if ~ol;
%                    if ~((tempups(g,1)>ups(f,2) & tempups(g,1)<ups(f,3)) | (tempups(g,2)>ups(f,2) & tempups(g,2)<ups(f,3)) | (ups(f,2)>tempups(g,1) & ups(f,2)<tempups(g,2)) | (ups(f,3)>tempups(g,1) & ups(f,3)<tempups(g,2)) | (tempups(h,1)<ups(f,2) & tempups(h,2)>ups(f,3)) | (tempups(h,1)>ups(f,2) & tempups(h,2)<ups(f,3)));%if none of the found edges are between any known pair of other upstate edges
%                     if ~((tempups(g,1)>ups{a}(f,2) &
%                     tempups(g,1)<ups{a}(f,3)) | (tempups(g,2)>ups{a}(f,2) & tempups(g,2)<ups{a}(f,3)) | (ups{a}(f,2)>tempups(g,1) & ups{a}(f,2)<tempups(g,2)) | (ups{a}(f,3)>tempups(g,1) & ups{a}(f,3)<tempups(g,2)));%if none of the found edges are between any known pair of other upstate edges
                    else%if there is overlap between known upstate and new one
                       tempups(g,:)=[];%don't keep this upstate
                    end
                end
            end
            
            %NEXT, IN CASE TWO UPSTATES ARE REALLY PART OF ONE BIGGER
            %UPSTATE WHICH JUST HAS A SMALL DIP IN IT (NOT GOING BELOW 3MV
            %ABOVE BASELINE
            if size(tempups,1)>1;%if more than one potential upstate detected
                e2=tempups(:,2);%take ends of all upstates
                b2=tempups(:,1);%filt(ends(good))-(lengths(good)-1)';%take all beginnings
                e2(end)=[];%prepare for comparison
                b2(1)=[];%ditto
                between=b2-e2;%subtract beginning of each movie from end of last
                for j=length(between):-1:1;%for each difference
                    bet2=filt(e2(j):b2(j));%find portion of convolved reading between the depolarized areas
                    if between(j)<20000;%for periods less than 2 seconds long
                        trash=find(bet2<0);%is there any area that dips below 3mV above baseline?
                        if isempty(trash);%if not...
                            tempups(j,2)=tempups(j+1,2);%make end of the first upstate now equal to the end of the 2nd... 1 big upstate
                            tempups(j+1,:)=[];%eliminate record of 2nd upstate
                        end
                    end
                end
            end
        end   
    end
    %NOW FIND REAL BEGINNING AND END OF EACH UPSTATE, NOT BEGINNING
    %AND END OF THE SMOOTHED CURVE.  DO THIS BY LOOKING AT A
    %BASELINE CREATED FROM ONLY THE POINTS IN THIS REGION IN THE
    %ORIGINAL reading.  WHERE DOES THE UPSTATE FIRST CROSS THAT
    %BASELINE AND LAST CROSS IT.  LATER FIND WHERE THE UPSWING FROM
    %DOWNSTATE STARTS AND THE DOWNSWING TO DOWNSTATE ENDS
    
    if ~isempty(tempups);
        laterups=findfirstlast(reading,filt,baseline,tempups,20000,.5,5000,3);%find beginning and end of upstates: 
        ups(size(ups,1)+1:size(ups,1)+size(laterups,1),:)=laterups;
    end
    %First point 2sec before or after found upstate that is above 5mV that is followed 
    %by a region that is .5mV above baseline for at least 500ms (and that region must 
    %overlap with the found upstate).  Last is the last such point
    %preceeded by the continuous region.

    
    if ~isempty(ups);%put in order from first upstate to last in the reading
        ups(:,1)=sort(ups(:,1));
        ups(:,2)=sort(ups(:,2));
        ups(:,3)=sort(ups(:,3));%finished putting in order
    end
    
    if ~isempty(ups);
        if ups(1,2)<100;%if the first upstate starts earlier than 10ms after the start of the reading
            ups(1,:)=[];%throw it away
        end
        if size(ups,1)>1;%if any upstates overlap, turn them into one upstate
            if ups(size(ups,1),3)>length(reading)-100;%if the last upstate ends later than 10ms before the end of the reading (ie if cell dying)
                ups(size(ups,1),:)=[];%throw it away
            end
        end
    end
        
    if size(ups,1)>1;%if any upstates overlap, turn them into one upstate
        for h=size(ups,1):-1:2;
            if ups(h,2)<=ups(h-1,3);
                ups(h-1,3)=ups(h,3);
                ups(h,:)=[];
            end
        end
    end
    
    if~isempty(ups)
        if ups(1,2)<100;%if the first upstate starts earlier than 10ms after the start of the reading
            ups(1,:)=[];%throw it away
        end
    end
    if~isempty(ups)
        if ups(size(ups,1),3)>length(reading)-100;%if the last upstate ends later than 10ms before the end of the reading (ie if cell dying)
            ups(size(ups,1),:)=[];%throw it away
        end
    end
    
    for h=size(ups,1):-1:1;%start cycle again, this time backwards
       if h==1;%if first upstate
           st=reading(1:ups(h,2)-1);%part of the reading preceeding the upstate
           st=st-baseline(1:ups(h,2)-1);%how much above baseline is each point preceeding this upstate
           st=find(st<0);%indices of points below baseline
           if length(st)>3;%if baseline is reached before the upstate
               start=st(end-3);%find 5th to last point before upstate that is below baseline
           else%if no points below baseline before the upstate...
               n=reading(1:ups(h,2)-1);%take the portion of the reading before this upstate
               [newbase,trash]=findbase(n);%find the baseline of it
               n=n-newbase;%how much above baseline is each point preceeding this upstate
               n=find(n<0);%find points below baseline
               start=n(end-4);%the 5th to last one is assigned as the start of the upswing into this upstate
           end    
       else%if not first upstate
           if ups(h,2)<=ups(h-1,3);%if the beginning of this upstate is after the end of the last one
               ups(h-1,3)=ups(h,3);%combine them into one big upstate
               ups(h,:)=[];%throw out this one
           else           
               st=reading(ups(h-1,3):ups(h,2)-1);%part of the reading preceeding the upstate
               st=st-baseline(ups(h-1,3):ups(h,2)-1);%how much above baseline is each point preceeding this upstate
               st=find(st<0);%indices of points below baseline
               if length(st)>3;%if baseline is reached before the upstate
                   start=st(end-3)+ups(h-1,3)-1;%find 5th to last point before upstate that is below baseline
               else%if no points below baseline before the upstate...
                   n=reading(ups(h-1,3):ups(h,2)-1);%take the portion of the reading before this upstate, but after the last
                   [newbase,trash]=findbase(n);%make a baseline for it
                   n=n-newbase;%how much above baseline is each point preceeding this upstate
                   n=find(n<0);%find points below baseline
                   start=n(end-4)+ups(h-1,3)-1;%the 5th to last one is assigned as the start of the upswing into this upstate
               end    
           end
       end

        ups(h,1)=start;
    end
    
%NOW WE WILL FIND SETTLING DOWN POINTS FOR EACH UPSTATE... BASED ON START
%POINTS FOR UPSTATES FOLLOWING THE ONE IN QUESTION
for h=1:size(ups,1);%for each detected upstate   
    last=ups(h,3);%point decided to be the last of this upstate
    if h==size(ups,1);%if this is last upstate
       if length(reading)-last >= 10000;%if there is enough space after the upstate
           low=find(reading(last+10000:end)-baseline(last+10000:end) < 0);%find all points more than 1 second past the end of the upstate that are below baseline
           if ~isempty(low);%if there are any point below baseline
               stop=low(1)+last+10000;%stop is the first such point
           else%if no points below baseline
               [trash,stop]=min(reading(last+10000:end));%find the minimum point more than 1 sec after the upstate
               stop=stop+last+10000-1;%correct index returned to "stop" by the fact that the last sequence started at last+10000
           end
       else%if not enough space after upstate
           [trash,stop]=min(reading(last:end));%find the lowest point after the upstate
           stop=stop+last-1;%correct index returned to "stop" by the fact that the last sequence started at last
       end
   else%if this is not the last upstate for this reading
        if ups(h+1,1)-last>10000;%if sufficient time between upstates
            low=find(reading(last+10000:ups(h+1,1))-baseline(last+10000:ups(h+1,1)) < 0);%find points more than 1 second after this upstate ends that are below baseline
            if ~isempty(low);%if any such points
                stop=low(1)+last+10000-1;%stop is the first one
            else%if no such points
                [trash,stop]=min(reading(last+10000:ups(h+1,1)));%find the lowest point between the upstates (more than 1 sec after the first)
                stop=stop+last+10000-1;%correct index returned to "stop" by the fact that the last sequence started at last
            end
        else%if less than 1 sec between upstates;
            [trash,stop]=min(reading(last:ups(h+1,1)));%find the lowest point between the upstates
            stop=stop+last-1;%correct index returned to "stop" by the fact that the last sequence started at last
        end
    end
    ups(h,4)=stop;
end