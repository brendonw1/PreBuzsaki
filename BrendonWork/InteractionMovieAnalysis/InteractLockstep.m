function InteractLockstep(moviecell)
%want to show lockstep num of cells per frame plot, along with indicator of
%when interaction was
%get every non-interaction and every interaction
%do every combo of them

slices = fieldnames(moviecell);
plotx = 0;
nactfig = figure('name','Number of Activations');
nactax = axes('parent',nactfig,'ylim',[-2.5 1.5],'position',[.01 .03 .98 .95]);
percactfig = figure('name','Percent of Activations');
percactax = axes('parent',percactfig,'ylim',[-2.5 1.5],'position',[.01 .03 .98 .95]);
ncontigactfig = figure('name','Number of Contiguous Activations');
ncontigactax = axes('parent',ncontigactfig,'ylim',[-2.5 1.5],'position',[.01 .03 .98 .95]);
perccontigactfig = figure('name','Contiguous as Percent of Total Activations');
perccontigactax = axes('parent',perccontigactfig,'ylim',[-2.5 1.5],'position',[.01 .03 .98 .95]);

for sidx = 1:length(slices);
    disp(sidx);
    sname = slices{sidx};
    eval(['nummovs = length(moviecell.',sname,');'])
    interactmovs = [];
    noninteractmovs = [];
    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        if strcmp(movinfo.Protocol,'ss') || strcmp(movinfo.Protocol,'spontstim')
            interactmovs(end+1) = midx;
        else
            noninteractmovs(end+1) = midx;
        end
    end
    for iidx = 1:length(interactmovs)
        thisi = interactmovs(iidx);
        for niidx = 1:length(noninteractmovs)
            plotx = plotx+1;
            thisni = noninteractmovs(niidx);
            
            eval(['imovinfo = moviecell.',sname,'(thisi);'])
            eval(['nimovinfo = moviecell.',sname,'(thisni);'])

            ions1 = imovinfo.Ons1;
            ions2 = imovinfo.Ons2;
            ions3 = imovinfo.Ons3;
            ionsover = imovinfo.OnsOversampled;
            nions1 = nimovinfo.Ons1;
            nions2 = nimovinfo.Ons2;
            nions3 = nimovinfo.Ons3;
            nionsover = nimovinfo.OnsOversampled;

            % find locksteps
            [i11reps,ni11reps] = findbestrepeats(ions1,nions1); %#ok<NASGU>
            [i12reps,ni12reps] = findbestrepeats(ions1,nions2); %#ok<NASGU>
            [i13reps,ni13reps] = findbestrepeats(ions1,nions3); %#ok<NASGU>
            [i21reps,ni21reps] = findbestrepeats(ions2,nions1); %#ok<NASGU>
            [i22reps,ni22reps] = findbestrepeats(ions2,nions2); %#ok<NASGU>
            [i23reps,ni23reps] = findbestrepeats(ions2,nions3); %#ok<NASGU>
            [i31reps,ni31reps] = findbestrepeats(ions3,nions1); %#ok<NASGU>
            [i32reps,ni32reps] = findbestrepeats(ions3,nions2); %#ok<NASGU>
            [i33reps,ni33reps] = findbestrepeats(ions3,nions3); %#ok<NASGU>
            
            for a = 1:3;
                for b = 1:3;
                    eval(['[itotacts(a,b),ifrsum{a,b},ifrperc{a,b},',...
                        'nbeforefr(a,b),nduringfr(a,b),nafterfr(a,b),',...
                        'ncontigbeforefr(a,b),ncontigafterfr(a,b),',...
                        'nbeforeacts(a,b),nduringacts(a,b),nafteracts(a,b),',...
                        'ncontigbeforeacts(a,b),ncontigafteracts(a,b),',...
                        'percbeforeacts(a,b),percduringacts(a,b),percafteracts(a,b),',...
                        'perccontigbeforeacts(a,b),perccontigafteracts(a,b)',...
                        '] = getrepnumbs(i',...
                        num2str(a),num2str(b),'reps,imovinfo.Movie',num2str(a),'InteractFrame);'])
                end
            end
            rawrepscore = nafteracts .* percafteracts;
            contigrepscore = ncontigafteracts .* perccontigafteracts;
            
            rawmaxval = max(rawrepscore(:));
            [irawmaxidx,nirawmaxidx]= find(rawrepscore==rawmaxval);
            if rawmaxval ~= 0 && ~isnan(rawmaxval)
                line(plotx,-1,'marker','o','markersize',max([nbeforeacts(irawmaxidx(1),nirawmaxidx(1)) .01]),'parent',nactax);
                line(plotx,0,'marker','o','markersize',max([nduringacts(irawmaxidx(1),nirawmaxidx(1)) .01]),'parent',nactax);
                line(plotx,1,'marker','o','markersize',max([nafteracts(irawmaxidx(1),nirawmaxidx(1)) .01]),'parent',nactax);
                text(plotx,-1.5,imovinfo.Name,'Rotation',270,'parent',nactax)
                line(plotx,-1,'marker','o','markersize',max([percbeforeacts(irawmaxidx(1),nirawmaxidx(1))*30 .01]),'parent',percactax);
                line(plotx,0,'marker','o','markersize',max([percduringacts(irawmaxidx(1),nirawmaxidx(1))*30 .01]),'parent',percactax);
                line(plotx,1,'marker','o','markersize',max([percafteracts(irawmaxidx(1),nirawmaxidx(1))*30 .01]),'parent',percactax);
                text(plotx,-1.5,imovinfo.Name,'Rotation',270,'parent',percactax)
            end
    
            contigmaxval = max(contigrepscore(:));
            [icontigmaxidx,nicontigmaxidx]= find(contigrepscore==contigmaxval);
            if contigmaxval ~= 0 && ~isnan(rawmaxval)
                line(plotx,-1,'marker','o','markersize',max([ncontigbeforeacts(icontigmaxidx(1),nicontigmaxidx(1)) .01]),'parent',ncontigactax);
                line(plotx,0,'marker','o','markersize',max([nduringacts(icontigmaxidx(1),nicontigmaxidx(1)) .01]),'parent',ncontigactax);
                line(plotx,1,'marker','o','markersize',max([ncontigafteracts(icontigmaxidx(1),nicontigmaxidx(1)) .01]),'parent',ncontigactax);
                text(plotx,-1.5,imovinfo.Name,'Rotation',270,'parent',ncontigactax)
                line(plotx,-1,'marker','o','markersize',max([perccontigbeforeacts(icontigmaxidx(1),nicontigmaxidx(1))*30 .01]),'parent',perccontigactax);
                line(plotx,0,'marker','o','markersize',max([percduringacts(icontigmaxidx(1),nicontigmaxidx(1))*30 .01]),'parent',perccontigactax);
                line(plotx,1,'marker','o','markersize',max([perccontigafteracts(icontigmaxidx(1),nicontigmaxidx(1))*30 .01]),'parent',perccontigactax);
                text(plotx,-1.5,imovinfo.Name,'Rotation',270,'parent',perccontigactax)
            end
            
            
            [ioverreps,nioverreps] = findbestrepeats(ionsover,nionsover);
        end
    end
end

%%
function [totacts,frsum,frperc,varargout] = getrepnumbs(reps,varargin)
%get total repeating activations over whole
totacts = sum(sum(reps));

%get number of repeating activations per frame
frsum = sum(reps,2);

%get percent of total movie repeat activity happening in each frame
frperc = frsum/totacts;

if ~isempty(varargin)
    intframe = varargin{1};%this means the input was an i movie, not an ni movie
    %first just get num frames before intframe in lockstep, after and
    %during
    %numbers of frames with rep before during and after intframe  
    beforefr = frsum(1:intframe-1)>0;
    duringfr = frsum(intframe)>0;
    afterfr = frsum(intframe+1:end)>0;
    
    nbeforefr = sum(beforefr);
    nduringfr = duringfr;
    nafterfr = sum(afterfr);
    
    nbeforeacts = sum(frsum(1:intframe-1));
    nduringacts = sum(frsum(intframe));
    nafteracts = sum(frsum(intframe+1:end));
    percbeforeacts = nbeforeacts/totacts;
    percduringacts = nduringacts/totacts;
    percafteracts = nafteracts/totacts;
    
    %then be more picky: 1) only deal with movies that had lockstep going
    %into intframe and 2) only take lockstep contiguously before and after
    %intframe
    ncontigbeforefr = 0;
    ncontigafterfr = 0;
    ncontigbeforeacts = 0;
    ncontigafteracts = 0;
    perccontigbeforeacts = 0;
    perccontigafteracts = 0;
    if frsum(intframe-1)>0 && frsum(intframe)>0
        last0before = find(beforefr==0,1,'last');
        if isempty(last0before);
            last0before = 0;
        end
        first0after = find(afterfr==0,1,'first');
        if isempty(first0after);
            first0after = length(afterfr)+1;
        end
        if last0before<intframe-1  &&  first0after>1%if contiguous before and after
            ncontigbeforefr = (intframe-1) - last0before;
            ncontigafterfr = first0after - 1;
            ncontigbeforeacts = sum(frsum(last0before+1:intframe-1));
            ncontigafteracts = sum(frsum(intframe+1:intframe+first0after-1));
            perccontigbeforeacts = ncontigbeforeacts/totacts;
            perccontigafteracts = ncontigafteracts/totacts;
        end
    end
    varargout{1} = nbeforefr;%
    varargout{2} = nduringfr;%
    varargout{3} = nafterfr;%
    
    varargout{4} = ncontigbeforefr;%
    varargout{5} = ncontigafterfr;%

    varargout{6} = nbeforeacts;%
    varargout{7} = nduringacts;%
    varargout{8} = nafteracts;%
    
    varargout{9} = ncontigbeforeacts;
    varargout{10} = ncontigafteracts;

    varargout{11} = percbeforeacts;%
    varargout{12} = percduringacts;%
    varargout{13} = percafteracts;%
    
    varargout{14} = perccontigbeforeacts;
    varargout{15} = perccontigafteracts;
end
