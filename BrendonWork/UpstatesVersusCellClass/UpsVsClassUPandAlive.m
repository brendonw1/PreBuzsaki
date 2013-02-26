function UpsVsClassUPandAlive(matnotes);

%% get directories
charcell = {'C:\Exchange\Data\Axon Data' ...
    'C:\Exchange\J&B Project\Axon Data' ...
    'E:\Lab & Data\Axon Data'};
ephysdirname = findoutdirectory('Choose the folder containing .abf files',charcell);
if ephysdirname==0;
    return;
end
charcell = {'C:\Exchange\Data\Cells\20X Photos' ...
    'E:\Lab & Data\Cells\Image Files\20X Photos'};
x20dir = findoutdirectory('Find directory containing 20X pic files',charcell);
if x20dir==0;
    return;
end
charcell = {'C:\Exchange\Data\Cells\60X Photos' ...
    'E:\Lab & Data\Cells\Image Files\60X Photos'};
x60dir = findoutdirectory('Find directory containing 60X pic files',charcell);
if x60dir==0;
    return;
end


for sidx = 1:length(matnotes);%for each slice
    if sum(matnotes(sidx).upstatecells) & sum(matnotes(sidx).alivecells);%if at least 2 upstate cells
        trialupcells = zeros(size(matnotes(sidx).trial,2),size(matnotes(sidx).alivecells,2));
        trialalivecells = zeros(size(matnotes(sidx).trial,2),size(matnotes(sidx).alivecells,2));
        UCs = find(matnotes(sidx).upstatecells);
        ACs = find(matnotes(sidx).alivecells);
        for tidx = 1:size(matnotes(sidx).trial,2);
            thistrialups=[];
            for ccidx = 1:length(UCs)%for each cell that ever had an upstate... check if it had on in this trial
                cidx = UCs(ccidx);
                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates)
                        trialupcells(tidx,cidx) = 1;
                        trialalivecells(tidx,cidx) = 1;
                        thistrialups = cat(1,thistrialups,matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates);
                    else
                        if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).alivecell)
                            if matnotes(sidx).trial(tidx).ephys.cell(cidx).alivecell%if is 1
                                trialalivecells(tidx,cidx) = 1;
                            end
                        end
                    end
                end
            end
            if ~isempty(thistrialups)
                trialxlims{sidx,tidx} = [max([0 thistrialups(1,1)-2000]) thistrialups(1,4)];%xlims for this plot
            end
        end

%% Finding the trials to be used and the cells to be plotted from
        otheralivecells = trialalivecells;
        otheralivecells(cumsum(trialupcells,2)==1)=0;
        sumtrialupcells = sum(trialupcells,2);
        sumtrialupcells = (sumtrialupcells >= 1);
        sumotheralivecells = sum(otheralivecells,2);
        goodtrials = find(sumtrialupcells.*sumotheralivecells);
        if isempty(goodtrials);
            continue
        elseif length(goodtrials)>5;
            goodtrials = goodtrials(1:5);
        end
        UCingoodtrials = find(sum(trialupcells(goodtrials,:),1));
        ACingoodtrials = find(sum(otheralivecells(goodtrials,:),1));
        PCs = union(UCingoodtrials,ACingoodtrials);%plotting cells
        
%% get some basic info established and create figure    
        cellfields = matnotes(sidx).CellOrder.CellFieldNames;
        handles.cellcolors = [[1 0 0];[0 0 1];[0 1 0];[.8 0 1]];
        figpos = wholescreenfigsize;
        handles.figure = figure('units','pixels',...
            'position',figpos,...
            'ToolBar', 'figure', ...
            'NumberTitle','off',...
            'BackingStore','off',...
            'DoubleBuffer','on',...
            'DithermapMode','manual',...
            'RendererMode','manual',...
            'Renderer','OpenGL',...
            'Name',matnotes(sidx).name(1:end-4));
%% figure positions for plotting
        %do BestIm with max width = 1/6
        set(handles.figure,'units','pixels')
        FigurePixels = get(handles.figure,'position');
        BestImtoWholeRatio = 1/2;
        SpktoWholeRatio = 1 - BestImtoWholeRatio;
        SpktoBestImRatio = SpktoWholeRatio/BestImtoWholeRatio;
        BestImAspectRatio = 3/4;%d1 to d2 (tall and skinny)
        
        spacerheight = .01;
        numrows = size(PCs,2)+1;
        dataheight = 1-(spacerheight*size(PCs,2));
        rowheight = dataheight/numrows;
                
        BestImHeightNorm = rowheight;
        BestImHeightPix = BestImHeightNorm * FigurePixels(4);
        BestImWidthPix = BestImHeightPix * BestImAspectRatio;
        BestImWidthNorm = BestImWidthPix/FigurePixels(3);
        BestImWidthNorm = min([BestImWidthNorm 1/6]);
        BestImWidthPix = BestImWidthNorm * FigurePixels(3);%below steps are in case 1/6 was used
        BestImHeightPix = BestImWidthPix * 1/BestImAspectRatio;
        BestImHeightNorm = BestImHeightPix/FigurePixels(4);
        
        yspacers = spacerheight*(1:(numrows));
        ydatastarts = rowheight*(1:(numrows));
        BestImpos2s = ydatastarts + yspacers;
        BestImpositions = [0*ones(numrows,1) BestImpos2s' BestImWidthNorm*ones(numrows,1) BestImHeightNorm*ones(numrows,1)];
        
        spkwidth = SpktoBestImRatio*BestImWidthNorm;
        spkheight = rowheight;
        spkpositions = [BestImWidthNorm*ones(numrows,1) BestImpos2s' spkwidth*ones(numrows,1) spkheight*ones(numrows,1)];
        for ccidx = 1:size(PCs,2);%for each cell
            cidx = PCs(ccidx);
%% display spiking 
            handles.spikingaxes(ccidx) = axes('parent',handles.figure,...
                'units','normalized',...
                'position',spkpositions(ccidx,:),...
                'XTickLabel',[],...
                'YTickLabel',[]);
            handles = plotspikingpanel(matnotes(sidx),ccidx,cidx,handles,ephysdirname);
            namepos = [0 .75 *BestImpos2s(1) .2 .05];
            uicontrol('style','text','string',matnotes(sidx).name(1:end-4),'units','normalized','position',namepos,'backgroundcolor',[1 1 1],'FontSize',18);
%% plot 20X image
            BestIm = getBestIm(cidx,matnotes(sidx),x20dir,x60dir);
            if ~isempty(BestIm)
                handles.BestImaxes(ccidx) = axes('parent',handles.figure,...
                    'units','normalized',...
                    'position',BestImpositions(ccidx,:));
                handles.BestIms(ccidx) = imagesc(BestIm);
%                 eval(['coords = matnotes(sidx).',cellfields{cidx},'.BestCoordinates;'])
%                 if ~isempty(coords);
%                     handles.BestImpointers(ccidx) = line(coords(1),coords(2),...
%                         'parent',handles.BestImaxes(ccidx),...
%                         'markeredgecolor',[1 1 1],...
%                         'markerfacecolor',handles.cellcolors(cidx,:),...
%                         'marker','o',...
%                         'markersize',8,...
%                         'linewidth',1);
%                 end
                set(handles.BestImaxes(ccidx),'XTickLabel',[],'YTickLabel',[]);
            end
        end

%% Below for displaying upstates       
        %numrows
        %rowheight
        spacerwidth = .01;
        numcolumns = length(goodtrials);
        columnsarea = (1-(BestImWidthNorm+spkwidth+.02)) - ((numcolumns-1)*spacerwidth);
        columnswidth = columnsarea/numcolumns;
        xspacers = spacerwidth*(0:(numcolumns-1));
        xdatastarts = columnswidth*(0:(numcolumns-1))+(BestImWidthNorm+spkwidth+.02);
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
            plotcells = PCs;
            thisposition = squeeze(uppositions(1,ggtidx,:))';
            handles.overlayaxes(ggtidx) = axes('parent',handles.figure,...
                'units','normalized',...
                'position',thisposition,...
                'XTickLabel',[],...
                'YTickLabel',[],...
                'xlim',trialxlims{sidx,gtidx},...
                'ylim',[-85 20]);
            [data,trash,channels]=abfload([ephysdirname,'\',matnotes(sidx).trial(gtidx).abfname]);
            for ccidx = 1:length(plotcells);
                cidx = plotcells(ccidx);
                chan = matnotes(sidx).CellOrder.CellChannels(cidx);
                thisdata = data(:,strmatch(chan,channels));
                thisposition = squeeze(uppositions(ccidx+1,ggtidx,:))';
                handles.upaxes(ggtidx,ccidx) = axes('parent',handles.figure,...
                    'units','normalized',...
                    'position',thisposition,...
                    'XTickLabel',[],...
                    'YTickLabel',[],...
                    'xlim',trialxlims{sidx,gtidx},...
                    'ylim',[-85 20]);
                line(1:length(thisdata),thisdata,'color',handles.cellcolors(cidx,:),'parent',handles.upaxes(ggtidx,ccidx));
                line(1:length(thisdata),thisdata,'color',handles.cellcolors(cidx,:),'parent',handles.overlayaxes(ggtidx));
                stim = matnotes(sidx).trial(gtidx).stim;
%                 stim = ['\bf',stim];%make bold
                tempx = trialxlims{sidx,gtidx}(1)+.05*(trialxlims{sidx,gtidx}(2)-trialxlims{sidx,gtidx}(1));
                tempy = 10;
                text(tempx,tempy,stim,'parent',handles.upaxes(ggtidx,ccidx));
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
function BestIm = getBestIm(ccidx,slicenotes,x20dir,x60dir);
BestIm = [];%so function doesn't crash
cellfields = slicenotes.CellOrder.CellFieldNames;
eval(['from = slicenotes.',cellfields{ccidx},'.BestPhotoFrom;'])

if ~isempty (from)
    eval(['BestImdir = ',lower(from),'dir;']);
    BestImd = getdir(BestImdir);
    match = [];
    for idx = 1:length(BestImd)
        eval(['name = slicenotes.',cellfields{ccidx},'.',from,'Photo;']);
        temp = strfind(BestImd(idx).name,name);
        if ~isempty(temp);
            match(end+1) = idx;
        end
    end
    if length(match) > 1;
        match = match(1);
    end
    if ~isempty(match);
        temp = [BestImdir,'\',BestImd(match).name];
        BestIm = imread(temp,'tif');
        BestIm = permute(BestIm,[2 1 3]);
        for idx = 1:size(BestIm,3);
            BestIm(:,:,idx) = flipud(BestIm(:,:,idx));%should be in correct orientation now.  Flipped and rotated
        end
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
%% display cell classification text
        set(handles.spikingaxes(ccidx),'ylim',[0 sum(tranges)],'xlim',[0 length(traces{1})]);
        eval(['classif = slicenotes.',cellfields{cidx},'.OverallInterpretation;']);
        classif = ['\bf',upper(classif)];
        text(.05*length(traces{1}),.95*sum(tranges),classif,'parent',handles.spikingaxes(ccidx),'color','black');
    end
end