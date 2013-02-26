function moviecell = tempfunc(moviecell)

slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    eval(['nummovs = length(moviecell.',sname,');'])
    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        
        if sidx == 6 && midx == 21
            1;
        end
        
        ons1 = movinfo.Ons1; %#ok<NASGU>
        ons2 = movinfo.Ons2; %#ok<NASGU>
        ons3 = movinfo.Ons3; %#ok<NASGU>
        onsover = movinfo.OnsOversampled; %#ok<NASGU>
        names = {'1' '2' '3' 'over'};

        for nidx = 1:length(names)
            nam = names{nidx};
            eval(['thisons = ons',nam,';'])
            numframes = size(thisons,1);
            if numframes>60%for long movies with many activation-like things, just take the one with the most activity

                eval(['sums',nam,' = sum(ons',nam,',2);']);
                eval(['thresh',nam,' = max([3 median(sums',nam,')+2]);']);
                eval(['upframes',nam,' = continuousabove(sums',nam,',zeros(size(sums',nam,')),thresh',nam,',2,Inf);']);
                eval(['thisupframes = upframes',nam,';'])
                if isempty(thisupframes);
                    eval(['moviecell.',sname,'(midx).UpYN',nam,'=0;'])
                    disp('no')
                else
                    disp('yes')
                    eval(['thisuf = upframes',nam,';']) 
            
                    totals = [];
                    for uidx = 1:size(thisuf,1);
                        eval(['totals(uidx) = sum(sums',nam,'(thisuf(uidx,1):thisuf(uidx,2)));'])
                    end
                    [trash, index] = max(totals);%#ok<NASGU> %find the one with most activity
                    eval(['uf = upframes',nam,'(index,1):upframes',nam,'(index,2);']);

                    eval(['upframes',nam,' = uf;']);%whatever frames came out of if-else statement above
                    eval(['upcellons',nam,' = logical(sum(ons',nam,'(upframes',nam,',:)));']);
                    eval(['upcelllist',nam,' = find(upcellons',nam,');']);
                    eval(['numcellsthresh',nam,' = max([10 median(sums',nam,')*3]);']);%find a min numb of cells turning on in up... at least 10
                    %if not more than that, blank things out, ie say no UP state
                    eval(['if sum(upcellons',nam,') < numcellsthresh',nam,';',...
                        'upframes',nam,' = [];',...
                        'upcellons',nam,' = [];',...
                        'upcelllist',nam,' = [];',...
                    'end'])
                    eval(['moviecell.',sname,'(midx).UpYN',nam,'=1;'])
                    eval(['moviecell.',sname,'(midx).Up.UpFrames',nam,'=upframes',nam,';'])
                    eval(['moviecell.',sname,'(midx).Up.Thresh',nam,'=thresh',nam,';'])
                    eval(['moviecell.',sname,'(midx).Up.NumCellsThresh',nam,'=numcellsthresh',nam,';'])
                    eval(['moviecell.',sname,'(midx).Up.UpCellOns',nam,'=upcellons',nam,';'])
                    eval(['moviecell.',sname,'(midx).Up.UpCellList',nam,'=upcelllist',nam,';'])
                end
            end
        end
    end
end