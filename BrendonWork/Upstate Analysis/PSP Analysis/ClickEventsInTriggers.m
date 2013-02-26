function results = ClickEventsInTriggers(varargin)
%takes triggered average figure as input.
% asks user to click at start of rise of an EPSP (or IPSC) and asks to
% select a rectangle encompassing the x of where the max of the synaptic 
% event was.
% from this calculates and outputs data into a structure array with data
% both in matrix format and in a cell array ready to be exported to Excel.



%%ASSUMPTIONS
samprate = 10000;%ASSUME 10KHz sampling
pretrigtime = 0.01;%ASSUME 10ms pre-trigger time
%assume looking for UPwards deflections, so use "max"

%% get file if one wasn't input
if nargin==1;%assume input is the path to the file with the data to view    
    filepath=varargin{1};%save pathname into handles
elseif nargin==0;%if no inputs
    [filename,pathname,FilterIndex]=uigetfile('.fig','Choose a data file');
    if ~FilterIndex
        return
	end
    filepath=[pathname,filename];
end


%% open the fig and get data out of it
ReadFig = hgload(filepath);
set(ReadFig,'visible','off');
try
    ReadFigDat = getappdata(ReadFig,'data');
catch
    errdlg ('Invalid Figure.  Must have "data" in appdata containing a structure of line data')
    return
end
close(ReadFig)
clear ReadFig

traces = ReadFigDat.data{5};%grab zeroed traces
meantrace = ReadFigDat.data{6};%grab averaged zeroed trace
%% plot data
f = figure('units','normalized');
ax = axes('parent',f);
hold on
for tidx = 1:size(traces,1);
    thistrace = traces(tidx,:);
    timebase = (1:size(traces,2))/samprate;
    meanline = line(timebase,meantrace,'color',[.9 .9 .9],'LineWidth',3);
    thisline = line(timebase,thistrace);
    xlim([0 timebase(end)])
    title([num2str(tidx),' out of ',num2str(size(traces,1))])
%% get sample 1, should be at baseline just as rise starts
    [x1,y1,button] = ginput(1);%only listen to x's... get y's as trace values at those x points
    if button~=1%indicates a synaptic failure if any non-left click
        outbasetimes(tidx) = 0;
        outbasevalues(tidx) = 0;
        outeventtimes(tidx) = 0;
        outeventvalues(tidx) = 0;
        latencies(tidx) = 0;
        amplitudes(tidx) = 0;
        risetimes(tidx) = 0;
        amplitudes1090(tidx) = 0;
        risetimes1090(tidx) = 0;
        riserates1090(tidx) = 0;
        failures(tidx) = 1;
    else%if button clicked was 1
        basetime = x1;
        basesample = round(x1*samprate);
        basevalue = thistrace(basesample);

    %% get sample 2: make a box to select a region to get a max
        [tempx,tempy] = ginput(1);
        point1 = get(f,'CurrentPoint'); % button down detected
        if strcmp(get(f,'SelectionType'),'normal');%if a left click
            rect = [point1(1,1) point1(1,2) 0 0];
            r2 = rbbox(rect);%in figure units = seconds
            axpos = get(ax,'position');
            axxlims = get(ax,'xlim');
            xlims(1)=(r2(1)-axpos(1))/axpos(3);%convert first point to x start in axes normalized
            xlims(2)=r2(3)/axpos(3)+xlims(1);%convert third point to x stop in axes normalized

            xstartsec = axxlims(1) + xlims(1)*(axxlims(2)-axxlims(1));
            xstopsec = axxlims(1) + xlims(2)*(axxlims(2)-axxlims(1));
            xstartsamp = round(xstartsec*samprate);
            xstopsamp = round(xstopsec*samprate);
            xstartsamp = max([xstartsamp 1]);
            xstopsamp = min([xstopsamp length(thistrace)]);

            boxedchunk = thistrace(xstartsamp:xstopsamp);
            [eventvalue,maxsamp] = max(boxedchunk);
            eventtime = maxsamp + xstartsamp;
            eventtime = eventtime/10000;
        end

    %% calculate and save measures for each event
        latencies(tidx) = basetime-pretrigtime;
        amplitudes(tidx) = eventvalue - basevalue;
        risetimes(tidx) = eventtime - basetime;
        
        tenlevel = basevalue + .1*amplitudes(tidx);
        aboveten = thistrace>=tenlevel;
        aboveten(1:round(basetime*samprate)) = 0;
        tentime = find(aboveten,1,'first');
        tentime = tentime/samprate;
        
        ninetylevel = basevalue + .9*amplitudes(tidx);
        belowninety = thistrace<=ninetylevel;
        belowninety(round(eventtime*samprate):end) = 0;
        ninetytime = find(belowninety,1,'last');
        ninetytime = ninetytime/samprate;
        amplitudes1090(tidx) = ninetylevel - tenlevel;
        risetimes1090(tidx) = ninetytime - tentime;
        riserates1090(tidx) = amplitudes1090(tidx)/risetimes1090(tidx);
        
        failures(tidx) = 0;
        outbasetimes(tidx) = basetime;
        outbasevalues(tidx) = basevalue;
        outeventtimes(tidx) = eventtime;
        outeventvalues(tidx) = eventvalue;
    end
    delete(thisline);
end

close(f);

results.dataorder = {'Failure' 'BaseTime' 'BaseValue' 'EventTime' ...
    'EventValue' 'Latency' 'Amplitude' 'RiseTime' 'Amplitude1090' ...
    'RiseTime1090' 'RiseRate1090'};
numfields = size(results.dataorder,2);
results.datamat = [failures' outbasetimes' outbasevalues' ...
    outeventtimes' outeventvalues' latencies' amplitudes' ...
    risetimes' amplitudes1090' risetimes1090' riserates1090'];
results.datacell = mat2cell(results.datamat,ones(1,tidx),ones(1,numfields));
results.datacell = [results.dataorder; cell(1,numfields); results.datacell]
