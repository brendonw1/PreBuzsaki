function ups=findfirstlast(reading,filt,baseline,tempups,beforeafter,contamp,contlength,height);
%This function is called on in "findupstates" function.
%It finds start and end points of upstates, given certain input parameters.
%Input is tempups (first pass, temporarily detected upstate beginnings and
%endings, from "findupstates").  Output is a partially formed version of
%"ups" which will come out of "findupstates" when that function is
%finished.

for h=1:size(tempups,1);
    if tempups(h,1)-beforeafter<0;%if not enough space before upstate
        extrastart=1;%make a region interest starting from the beginning of the trace
    else% if enough space
        extrastart=tempups(h,1)-beforeafter;%take the upstate minus 2sec
    end
    if tempups(h,2)+beforeafter>length(reading);%if not enough space after upstate
        extrastop=length(reading);%make a region interest ending at the end of the trace
    else%if enough space
        extrastop=tempups(h,2)+beforeafter;%take the upstate plus 2sec
    end
    extraup=reading(extrastart:extrastop);%take a sample of points beyond detected upstate which corresponds to the area the filter was seeing when it first and last was up
    extrafilt=filt(extrastart:extrastop);%take a sample of the same points but in the filtered curve
    extrabase=baseline(extrastart:extrastop);%take same area of baseline
    extraabove=continuousabove(extrafilt+extrabase,extrabase,contamp,contlength,length(extraup)+1);%find areas where filtered data is contampmV above baseline continously for contlengthms or more        
    testabove=extraabove+extrastart-1;
    for f=size(testabove,1):-1:1;
        ol=overlapping(testabove(f,1:2),tempups(h,1:2));
        if ~ol
            extraabove(f,:)=[];
        end
    end
    if isempty(extraabove);%if no overlapping areas, which should theoretically be impossible b/c already discovered a larger amplitude area in this region
        continue%then go to the next tempup
    end
        
    trash=extraabove(:,2)-extraabove(:,1);%find lengths of all such periods
    [trash,trash2]=max(trash);%find the index of the longest period (maybe has to be only 1)
    extraabove=extraabove(trash2,:);%use that indexnumber to pull out the value
    
    first1=find(extraup>extrabase+height);%find points in this region of raw data above heightmV...output is index # relative to this region
    first=find(first1>=extraabove(1,1));%find index of first above-heightmV point that is followed by continuous above contampmV baseline
    first=first(1);%take the first such point
    first=first1(first);%referring back to the index of extraup
    first=first+extrastart-1;%converting to index of the whole reading
    firstap=findaps(extraup);%find action potentials in the candidate region
    if ~isempty(firstap{1});%if any ap's
        firstap=firstap{1}(1);%take the first one
        firstap=find(extraup(1:firstap)-extrabase(1:firstap)<height);%find regions before the first ap that are below heightmV
        if ~isempty(firstap);%if any points below heightmV before the action potential exist in this region
            firstap=firstap(end)+1+(extrastart-1);%firstap = the last such point + 1 (then callibrate for the entire trace)
        else%if no point below heightmV before the first ap (ie if ap is right at start of region)
            firstap=1+(extrastart-1);%firstap = the first point in the candidate region
        end
        candid=[firstap first];%setting up to compare these two points
        first=min(candid);%the start of the upstate is the earlier of the two
    end
   
    last=find(first1<=extraabove(1,2));%find index of above-heightmV-points that are preceded by continuous above contampmV baseline
    last=last(end);%take last such point
    last=first1(last);%referring back to the index of extraup
    last=last+extrastart-1;%converting to index of the whole reading
    lastap=findaps(extraup);%find action potentials in the candidate region
    if ~isempty(lastap{1});%if any ap's
        lastap=lastap{1}(end);%take the last one
        lastap2=lastap;%we'll need this later... the point of the first upstate
        lastap=find(extraup(lastap:end)-extrabase(lastap:end)<height);%find regions after the last ap that are below heightmV
        if ~isempty(lastap);%if any points below heightmV after the action potential exist in this region
            lastap=lastap(1)-1+(extrastart-1)+(lastap2-1);%firstap = the last such point - 1 (then callibrate for the entire trace)
        else%if no point below heightmV
            lastap=extrastop;%firstap = the last point in the candidate region
        end
        candid=[lastap last];
        last=max(candid);
    end
     ups(h,2)=first;
     ups(h,3)=last;
 end