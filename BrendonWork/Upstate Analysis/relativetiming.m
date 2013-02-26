function indices=relativetiming(uptraces,abfnotes);
%input is "uptraces" a series of upstates, created by saveupstatetraces.m.
%uptraces.traces is a 4D cell array, with each entry containing a vector which is
%the electrophysiologic trace for 1 upstate.  Dimensions correspond to the
%following: 1=slice, 2=file, 3=cell, 4=upstate number (within a file of a
%cell).  
%uptraces.starts has exactly the same dimensionality as the .traces cell
%array, but is a normal numeric array, with entries only where there are up
%states, each entry is the absolute start time of the up state, corresponding to the
%first point in the trace.  This is useful in comparing timings between
%simultaneously recorded neurons.
%Output...

% 2) also into uptraces... put I, S, P, E (Excitatory, non-specific) for each cell
% 3) find basic relationships between whatever in each cell
% 4) based on what kind of comparison it is, save into a category: IS, IP,
% IE, SP, SE, PE


% rel=1;

warning off MATLAB:conversionToLogical

indices=[];
for a=1:size(uptraces.traces,1);%for each slice
    if sum(logical(sum(sum(uptraces.guide(a,:,:,:),4),2))) >= 2;%find sum across all movies and all upstates, to find which cells had ups, if at least two cells...
        upcells=find(logical(sum(sum(uptraces.guide(a,:,:,:),4),2)));%store the cell numbers of the cells that had upstates... ie [1 3] or [1 2 3]
        for c1=1:(length(upcells)-1);%go thru each cell that had an UP up to the second to last... will compare each in turn to second thru last
            upfiles=find(logical(sum(uptraces.guide(a,:,upcells(c1),:),4)));%record which files this cell comes on in
            for b=1:length(upfiles);%for each file
                upnumb1=sum(uptraces.guide(a,upfiles(b),upcells(c1),:));%find how many upstates this cell had in this file
                for d1=1:upnumb1;%for each up that cell had in that file
                    onset=uptraces.ups{a,upfiles(b),upcells(c1),d1}(1);%find where that up started
                    offset=uptraces.ups{a,upfiles(b),upcells(c1),d1}(4);%find where that up stopped
                    oo1=[onset offset];%store start and stop time for that UP state
                    for c2=(c1+1):length(upcells);%go thru each cell that had an UP from the second thru last cell
                        if sum(uptraces.guide(a,upfiles(b),upcells(c2),:),4);%if the second cell had an upstate in the same file as the first cell
                            upnumb2=sum(uptraces.guide(a,upfiles(b),upcells(c2),:));%find how many upstates the second cell had in this file
                            for d2=1:upnumb2;%for each up that cell had in that file
                                onset=uptraces.ups{a,upfiles(b),upcells(c2),d2}(1);%find where that up started
                                offset=uptraces.ups{a,upfiles(b),upcells(c2),d2}(4);%find where that up stopped
                                oo2=[onset offset];%store start and stop time for that UP state
                                if overlapping(oo1,oo2);%if these two upstates overlap
                                    indices(:,:,end+1)=[a,upfiles(b),upcells(c1),d1;a,upfiles(b),upcells(c2),d2];
                                    disp([a upcells(c1) upcells(c2)])

%                                     aps1=findaps(uptraces.traces{a,upfiles(b),upcells(c1),d1});%extracting action potential times
%                                     aps1=aps1{1}+oo1(1);%taking out of cell array, also adding to onset time to make times absolute
%                                     aps2=findaps(uptraces.traces{a,upfiles(b),upcells(c2),d2});%extracting action potential times
%                                     aps2=aps2{1}+oo2(1);%taking out of cell array, also adding to onset time to make times absolute
%                                     rel(end+1).cella=[a b c1];%recording which cell will be the first cell for this comparison
%                                     rel(end).cellb=[a b c2];%recording the id of the second cell
% 	%                                 rel(end).cellatype=???;%record I, P, S, E etc for first cell
% 	%                                 rel(end).cellabtype=???;%ditto for second cell
%                                     rel(end).onsets=onset1-onset2;%record diff between starts of rise time
%                                     rel(end).startplateau=uptraces.ups{a,b,upcells(c1),d1}(2) - uptraces.ups{a,b,upcells(c2),d2}(2);%diff between times that cells get to 5mV above baseline
%                                     rel(end).stopplateau=uptraces.ups{a,b,upcells(c1),d1}(3) - uptraces.ups{a,b,upcells(c2),d2}(3);%diff between times that potential descends below 5mV more than baseline
%                                     rel(end).offsets=offset1-offset2;%diff between final settle times
%                                     if ~isempty (aps1) & ~isempty(aps2);%if both cells fired at least once
%                                         rel(end).firstaps=aps1(1)-aps2(1);%diff between when cells first fire
% 	%                                     if length(aps1)>1 & length(aps2)>2;???? need more than one spike for cost fctn?
% 	%                                         rel(end).cost=???(aps1,aps2);
% 	%                                     end
%                                     end
%                                     if ~isempty (aps1);%if first cell fired at least once
%                                         rel(end).apaonsetb=aps1-onset2;%find if it fired before the other cell began depolarizing
%                                     end
%                                     if ~isempty (aps2);%if second cell fired at least once
%                                         rel(end).apbonseta=aps2-onset1;%find if it fired before the other cell began depolarizing
%                                     end

                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
