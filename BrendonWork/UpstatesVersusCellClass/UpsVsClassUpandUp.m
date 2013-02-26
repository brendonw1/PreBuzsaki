function UpsVsClassUpandUp(matnotes);

warning off
%% get directories
charcell = {'C:\Exchange\Data\Axon Data' ...
    'C:\Exchange\J&B Project\Axon Data' ...
    'E:\Lab & Data\Axon Data'};
ephysdirname = findoutdirectory('Choose the folder containing .abf files',charcell);
if ephysdirname==0;
    return;
end
charcell = {'C:\Exchange\Data\Cells\20X Photos' ...
    'E:\Lab & Data\Cells\Image Files\Photos'};
x20dir = findoutdirectory('Find directory containing 20X pic files',charcell);
if x20dir==0;
    return;
end


for sidx = 1:length(matnotes);%for each slice
    if sum(matnotes(sidx).upstatecells)>=2;%if at least 2 upstate cells
        UCs = find(matnotes(sidx).upstatecells);
        ACs = find(matnotes(sidx).alivecells);
        trialupcells = zeros(size(matnotes(sidx).trial,2),size(UCs,2));
        trialalivecells = zeros(size(matnotes(sidx).trial,2),size(ACs,2));
        for tidx = 1:size(matnotes(sidx).trial,2);
            thistriallist = zeros(1,size(UCs,2));
            trialupcoordinates = {};
            for ccidx = 1:length(UCs)%for each cell that ever had an upstate... check if it had on in this trial
                cidx = UCs(ccidx);
                thistrialups{ccidx}={};
                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates)
                        trialupcells(tidx,ccidx) = 1;
                        thistrialups{ccidx}{end+1} = matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates;
                    end
                end
            end          
            upnums = [];
            upstarts = [];
            upstops = [];
%             if length(thistrialups)>=2;
                for a = 1:length(thistrialups{1});
                    for b = 1:length(thistrialups{2});
%                         if length(thistrialups)>=3;
%                             for c = 1:length(thistrialups{3});
%                                 if overlapping(thistrialups{1}{a},thistrialups{2}{b})
%                                     upnums(end+1,:) = [a b];
%                                     upstarts(end+1,:) = min([thistrialups{1}{a}(1) thistrialups{2}{b}(1)]);
%                                     upstops(end+1,:) = max([thistrialups{1}{a}(4) thistrialups{2}{b}(4)]);
%                                 end
%                         else
                            if overlapping(thistrialups{1}{a}(2:3),thistrialups{2}{b}(2:3))
                                upnums(end+1,:) = [a b];
                                upstarts(end+1,:) = min([thistrialups{1}{a}(1) thistrialups{2}{b}(1)]);
                                upstops(end+1,:) = max([thistrialups{1}{a}(4) thistrialups{2}{b}(4)]);
                            else
                                trialupcells(tidx,UCs(1)) = 0;
                                trialupcells(tidx,UCs(2)) = 0;
                            end
%                         end
                    end
                end
%             end
            [trash,earliestov] = min(upstarts);
            trialupcoordinates{sidx,tidx} = upnums(earliestov,:);%which up from cell 1 and cell 2
            trialxlims{sidx,tidx} = [upstarts(earliestov) upstops(earliestov)];%xlims for this plot
            for ccidx = 1:length(ACs)%for each cell that ever had an upstate... check if it had on in this trial
                cidx = ACs(ccidx);
                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).alivecell)
                        if matnotes(sidx).trial(tidx).ephys.cell(cidx).alivecell%if is 1
                            trialalivecells(tidx,ccidx) = 1;
                        end
                    end
                end
            end
        end
        cells = logical(sum(trialupcells,1));
        notupcells = find(~cells);
        UCs(notupcells) = [];%elim cells that never did have ups.
        if length(UCs) < 2;%if don't still have at least 2 with ups
            break%jump to next slice
        end
%         cells = logical(sum(trialalivecells,1));
%         notalivecells = find(~cells);
%         ACs(notalivecells) = [];%elim cells that never were alive
%         if length(ACs) < 2;%if don't still have at least 2 with ups
%             break%jump to next slice
%         end
        cellfields = matnotes(sidx).CellOrder.CellFieldNames;
        x20image = getx20im(x20dir,matnotes(sidx));
        handles.cellcolors = [[1 0 0];[0 0 1];[0 1 0];[.8 0 1]];
%% create figure
        figpos = wholescreenfigsize;
        handles.figure = figure('units','pixels',...
            'position',figpos,...
            'ToolBar', 'figure', ...
            'NumberTitle','off',...
            'MenuBar','none',...
            'BackingStore','off',...
            'Name',matnotes(sidx).name);
%% figure positions for plotting
        %do x20 with max width = 1/6
        set(handles.figure,'units','pixels')
        FigurePixels = get(handles.figure,'position');
        X20toWholeRatio = 1/2;
        SpktoWholeRatio = 1 - X20toWholeRatio;
        SpktoX20Ratio = SpktoWholeRatio/X20toWholeRatio;
        X20AspectRatio = 3/4;%d1 to d2 (tall and skinny)
        
        spacerheight = .01;
        numrows = size(UCs,2)+1;
        dataheight = 1-(spacerheight*size(UCs,2));
        rowheight = dataheight/numrows;
                
        X20HeightNorm = rowheight;
        X20HeightPix = X20HeightNorm * FigurePixels(4);
        X20WidthPix = X20HeightPix * X20AspectRatio;
        X20WidthNorm = X20WidthPix/FigurePixels(3);
        X20WidthNorm = min([X20WidthNorm 1/6]);
        X20WidthPix = X20WidthNorm * FigurePixels(3);%below steps are in case 1/6 was used
        X20HeightPix = X20WidthPix * 1/X20AspectRatio;
        X20HeightNorm = X20HeightPix/FigurePixels(4);
        
        yspacers = spacerheight*(1:(numrows));
        ydatastarts = rowheight*(1:(numrows));
        X20pos2s = ydatastarts + yspacers;
        X20positions = [0*ones(numrows,1) X20pos2s' X20WidthNorm*ones(numrows,1) X20HeightNorm*ones(numrows,1)];
        
        spkwidth = SpktoX20Ratio*X20WidthNorm;
        spkheight = rowheight;
        spkpositions = [X20WidthNorm*ones(numrows,1) X20pos2s' spkwidth*ones(numrows,1) spkheight*ones(numrows,1)];
        for ccidx = 1:size(UCs,2);%for each cell
            
            cidx = UCs(ccidx);
%% display spiking 
            handles.spikingaxes(ccidx) = axes('parent',handles.figure,'units','normalized','position',spkpositions(ccidx,:));
            handles = plotspikingpanel(matnotes(sidx),ccidx,cidx,handles,ephysdirname);
%% plot 20X image
            if ~isempty(x20image)
                handles.x20axes(ccidx) = axes('parent',handles.figure,'units','normalized','position',X20positions(ccidx,:));
                handles.x20images(ccidx) = imagesc(x20image);
                eval(['coords = matnotes(sidx).',cellfields{cidx},'.X20Coordinates;'])
                if ~isempty(coords);
                    imsize = size(get(handles.x20images(ccidx),'CData'));
                    coords(1) = coords(1) * imsize(1);
                    coords(2) = coords(2) * imsize(2);
                    handles.x20pointers(ccidx) = line(coords(1),coords(2),'color',handles.cellcolors(cidx,:),'marker','o');
                end
            end
        end
%% Below for displaying upstates
        sumtrialupcells = sum(trialupcells,2);
        sumtrialupcells = (sumtrialupcells >= 2);
        goodtrials = find(logical(sumtrialupcells));%trials with at least 2 cells having ups
        if length(goodtrials)>5;
            goodtrials = goodtrials(1:5);
        end

        %numrows
        %rowheight
        spacerwidth = .01;
        numcolumns = length(goodtrials);
        columnsarea = (1-(X20WidthNorm+spkwidth+.02)) - ((numcolumns-1)*spacerwidth);
        columnswidth = columnsarea/numcolumns;
        xspacers = spacerwidth*(0:(numcolumns-1));
        xdatastarts = columnswidth*(0:(numcolumns-1))+(X20WidthNorm+spkwidth+.02);
        UpPos1s = xdatastarts + xspacers;
        UpPos1s = repmat(UpPos1s,[numrows,1]);%make a 2d plane of all pos1s
        Upyspacers = spacerheight*(0:(numrows-1));
        Upydatastarts = rowheight*(0:(numrows-1));
        UpPos2s = Upydatastarts + Upyspacers;
        UpPos2s = repmat(UpPos2s',[1 numcolumns]);%make a 2d plane of all pos2s
        UpPos3s = columnswidth * ones(numrows,numcolumns);
        UpPos4s = rowheight * ones(numrows,numcolumns);
        uppositions = cat(3,UpPos1s,UpPos2s,UpPos3s,UpPos4s);%concat pos1s - pos4s to make a 3d matrix
        
        for ggtidx = 1:length(goodtrials);
            gtidx = goodtrials(ggtidx);
            upcells = UCs(find(trialupcells(gtidx,:)));
            [data,trash,channels]=abfload([ephysdirname,'\',matnotes(sidx).trial(gtidx).abfname]);
            for ccidx = 1:length(upcells);
                cidx = upcells(ccidx);
                chan = matnotes(sidx).CellOrder.CellChannels(cidx);
                thisdata = data(:,strmatch(chan,channels));
                thisposition = squeeze(uppositions(ccidx+1,ggtidx,:))';
                handles.upaxes(ggtidx,ccidx) = axes('parent',handles.figure,...
                    'units','normalized',...
                    'position',thisposition,...
                    'xlim',trialxlims{sidx,gtidx},...
                    'ylim',[-85 20]);
                line(1:length(thisdata),thisdata,'color',handles.cellcolors(cidx,:));
            end
           %display overlay
        end               
    end
end


%% for finding folders with certain files
function dirpath = findoutdirectory(questionstring,defaultcharcell)
trydir = cd;
for a = 1:length(defaultcharcell);
    if isdir(defaultcharcell{a});
        trydir = defaultcharcell{a};
        break
    end
end
dirpath=uigetdir(trydir,questionstring);

%% for creating figures that are
function figpos = wholescreenfigsize
%for creating figures that are the size of the whole screen, minus windows
%xp task bars etc.
screensize=get(0,'ScreenSize');
screensize=screensize(3:4);
taskbarheight=38;%pixels (true for all screens?)
figtoolbarheight=55;%pixels (true for all screens?)
vertpix=taskbarheight+figtoolbarheight;%to subtract from height of fig
proportion=(screensize(2)-vertpix)/screensize(2);
figpos = [5 taskbarheight screensize(1)*proportion screensize(2)-vertpix];
        
%% just load and correctly orient the 20X image
function x20image = getx20im(x20dir,slicenotes);
x20image = [];%so function doesn't crash
x20d = getdir(x20dir);
match = [];
for idx = 1:length(x20d)
    temp = strfind(x20d(idx).name,slicenotes.name(1:end-4));
    if ~isempty(temp);
        match(end+1) = idx;
    end
end
if length(match) > 1;
    charcell = {};
    for idx = match;
        charcell{end+1}=x20d(idx).name;
    end
    prompt = ['Which 20X for ',slicenotes.name(1:end-4)];
    [Selection,ok] = listdlg('ListString',charcell,...
        'SelectionMode','single',...
        'promptstring',prompt,...
        'name','X20 Images');
    match = match(Selection);
end
if ~isempty(match);
    temp = strcat(x20dir,'\',x20d(match).name);
    x20image = imread(temp,'tif');
    x20image = permute(x20image,[2 1 3]);
    for idx = 1:size(x20image,3);
        x20image(:,:,idx) = flipud(x20image(:,:,idx));%should be in correct orientation now.  Flipped and rotated
    end
end


%% display spiking
function handles = plotspikingpanel(slicenotes,ccidx,cidx,handles,ephysdirname)
traces = {};
tlims = [];
tranges = [];
oldname = [];
cellfields = slicenotes.CellOrder.CellFieldNames;
eval(['numtraces = size(slicenotes.',cellfields{cidx},'.SpikePatternRecords,2);']);%even if not evaluated this time...
for tidx = 1:numtraces;
    eval(['name = slicenotes.',cellfields{cidx},'.SpikePatternRecords(tidx).file;']);
    if ~strcmp(oldname,name);
        path = [ephysdirname,'\',name];
        [data,trash,channels]=abfload(path);
    end
    eval(['sweep = slicenotes.',cellfields{cidx},'.SpikePatternRecords(tidx).sweep;']);
    traces{end+1} = data(:,1,sweep);
    tlims(end+1,:) = [min(traces{end}) max(traces{end})];
    tranges(end+1) = tlims(end,2) - tlims(end,1);
    match = [];
    for idx = 1:size(slicenotes.trial,2)
        if strcmp(slicenotes.trial(idx).abfname,name);
            match = idx;
        end
    end       
    oldname = name;
end
%plotting previously chosen spike patterns
%%assuming only 4 channels for this(!)
if ~isempty(tlims);
    for tidx = 1:size(traces,2);%for each trace
        if tidx == 1;
            tcs = 0;
        else
            tcs = sum(tranges(1:(tidx-1)));%total range for all below this one
        end
        thistrace = traces{tidx}-(tlims(tidx,1)-tcs);
        line(1:length(thistrace),thistrace,'parent',handles.spikingaxes(ccidx),'color',handles.cellcolors(cidx,:))
        set(handles.spikingaxes(ccidx),'ylim',[0 sum(tranges)],'xlim',[0 length(traces{1})]);
    end
end