function moviecell = FindMovieUpstates(moviecell)

% at least 2 consecutive frames with minimum 3 cells in each
% with at least a total of 10 activations occuring in those consec frames
% and in those consec frames, must be at least 10 active cells

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
        
        %find series of at least 500 contiguous milliseconds (2 contiguous
        %frames at 300ms/frame) with a minimum number of cells on per
        %frame: whichever is larger of 3 cells/frame or (movie median cells
        %per frame + 2)
        names = {'1' '2' '3' 'over'};
        for nidx = 1:length(names)
            nam = names{nidx};
            eval(['sums',nam,' = sum(ons',nam,',2);']);
            eval(['thresh',nam,' = max([3 median(sums',nam,')+2]);']);
            eval(['upframes',nam,' = continuousabove(sums',nam,',zeros(size(sums',nam,')),thresh',nam,',2,Inf);']);
            eval(['thisupframes = upframes',nam,';'])
            if isempty(thisupframes);
                eval(['moviecell.',sname,'(midx).UpYN',nam,'=0;'])
                disp('no')
            else
                disp('yes')
                eval(['thisons = ons',nam,';']) 
                eval(['thisuf = upframes',nam,';']) 
                numframes = size(thisons,1);
                if numframes>60%for long movies with many activation-like things, just take the one with the most activity
                    for uidx = 1:size(thisuf,1);
                        eval(['totals(uidx) = sum(sums',nam,'(thisuf(uidx,1):thisuf(uidx,2)));'])
                    end
                    [trash, index] = max(totals);%#ok<NASGU> %find the one with most activity
                    eval(['uf = upframes',nam,'(index,1):upframes',nam,'(index,2);']);
                else
                    eval(['uf = upframes',nam,'(1,1):upframes',nam,'(1,2);']);%just keep first "up state" and remember a vector of consec frames
                end
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

                if ~strcmp(nam,'over')
        % In interaction-type trials, check whether "interaction" occured during detected UP state and record
                    if strcmp(movinfo.Protocol,'ss') || strcmp(movinfo.Protocol,'spontstim')%if right kind of trial
                        eval(['interactgood = moviecell.',sname,'(midx).InteractGood;'])%manual check for interaction via ephys
                        if isempty(interactgood)
                            interactgood = 0;
                        end
                        eval(['interframe = moviecell.',sname,'(midx).Movie',nam,'InteractFrame;'])%getting variables out...
                        if ~isempty(interframe)
                            eval(['ufs = upframes',nam,';'])
                            if sum(ufs == interframe) || interactgood%if interaction frame was anywhere in the UP state...
                                    % or manual ephys check was done and was good
                                eval(['moviecell.',sname,'(midx).Movie',nam,'AnyInteract=1;'])%record there was SOME interaction
                                eval(['moviecell.',sname,'(midx).Movie',nam,'NonEndInteract=0;'])%default value, corrected below if necessary
                                if sum(ufs == interframe)
                                    if find(ufs == interframe) < length(ufs)%if the interaction occurred in a frame BEFORE the last
                                        eval(['moviecell.',sname,'(midx).Movie',nam,'NonEndInteract=1;'])%record that
                                    end
                                end
                            else%if no interacting frames, record zeros
                                eval(['moviecell.',sname,'(midx).Movie',nam,'AnyInteract=0;'])                    
                                eval(['moviecell.',sname,'(midx).Movie',nam,'NonEndInteract=0;'])
                            end

                        end
                    end
                end
            end
        end
    end
end