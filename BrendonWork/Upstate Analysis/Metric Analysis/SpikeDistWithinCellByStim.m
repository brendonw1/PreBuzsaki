function output=SpikeDistWithinCellByStim(matnotes,beforedur,afterdur,goodpercell,trainsep,trainsperrec,stimtypes);
% function output=SpikeDistWithinCellByStim(matnotes,beforedur,afterdur,goodpercell,varargin);

% matnotes: (structure) contains all info about expts and slices
% beforedur: (number of points) how long before a the start of a stim train (from in6) to include in analysis
% afterdur: (number of points) how long after the start of a stim train to include in analysis
% goodpercell: (number) need to have at least this many of each category of
%     stimulation protocols for a cell to be analyzed
% trainsep: (number of points) consider in6 pulses part of a single train below this number of
%     data points
% trainsperrec: (number) analyze this many trains separately per recording
% stimtypes: (character cell) denoting the kinds of stimulation protocols to be analyzed



warning off
% if nargin==4;
%     stimtypes={'tstrain','wdtrain'};%default
% else
%     stimtypes=varargin{1};
% end

% beforedur=500;
% afterdur=2000;
trainsep=5000;
trainsperrec=1;

for a=1:length(stimtypes);
    reliability{a}=[];
    jitter{a}=[];
end
for a=1:length(matnotes);%for each slice
%% make sure this cell had all the desired kinds of stimtypes
    cells=find(matnotes(a).alivecells);
    for c=1:length(cells);
        anyspikes=0;%for recording if this cell spiked in any stim condition
        postypes=zeros(1,length(stimtypes));%intiate
        for b=1:length(matnotes(a).trial);%for each trial
            if isfield(matnotes(a).trial(b).ephys,'cell');
%                 if ~isempty(matnotes(a).trial(b).ephys.cell(cells(c)).upstates)
                    if ~isempty(matnotes(a).trial(b).stim);
                        temp=strmatch(matnotes(a).trial(b).stim,stimtypes);
                        if ~isempty(temp)
                            postypes(temp)=postypes(temp)+1;
                        end
                    end
%                 end
            end
        end
%% gather and store data
        allmemb={};  
        temp=postypes;
        temp(find(temp<goodpercell))=0;%each cell must have at least goodpercell number of each type of trial
        temp(find(temp>=goodpercell))=1;
%% To analyze only if at least goodpercell of each type of stim... vs just
%% 2 of the stim types comment in and out
%         if sum(temp)==length(stimtypes);%if this cell had all the desired types of events              
        if sum(temp)>=2;%if this cell had all the desired types of events              
%% end choice
            for d=1:length(stimtypes);%create a cell to record all of each type of event systematically
                allmemb{d}=zeros(1,beforedur+afterdur+1);%initiate a matrix with the requested length
            end
            for b=1:length(matnotes(a).trial);%for each trial (go get the data surrounding a stim and store it)
                for d=1:length(stimtypes);%for each type of stim
                    if ~isempty(matnotes(a).trial(b).stim);
                        if strcmpi(matnotes(a).trial(b).stim,stimtypes{d});
                            if isfield(matnotes(a).trial(b).ephys,'cell');
                                if ~isempty(matnotes(a).trial(b).ephys.in6)
                                    trains=separatetrains(matnotes(a).trial(b).ephys.in6,trainsep);
                                    [data,sampling,channels]=abfload(matnotes(a).trial(b).abfname);
                                    match=strmatch(matnotes(a).trial(b).ephys.cell(c).name,channels);
                                    data=data(:,match);
                                    if median(data)<-40 & median(data)>-85%up or down states here
                                        disp([a b])
                                        for f=1:trainsperrec;
                                            data2=(data(trains{f}(1)-beforedur:trains{f}(1)+afterdur));%add 5 b/c if take point of first stim, it's always an artipfact                    memb=(data(trains{1}(1)-beforedur:trains{1}(1)+afterdur));%-data(trains{1}(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                                            data2=reshape(data2,[1 beforedur+afterdur+1]);
                                            allmemb{d}=cat(1,allmemb{d},data2);%store all data traces
                                            temp=findaps2(data2);
                                            temp=temp-beforedur;
                                            allaps{a,cells(c),d}{size(allmemb{d},1)-1}=temp;%store all aps
                                            if ~isempty(find(temp>0));%only if spikes after stim
                                                anyspikes=1;
                                            end
                                        end
                                        slicename=matnotes(a).name;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if anyspikes
                for d=1:length(stimtypes);%get rid of creation artifact
                    allmemb{d}(1,:)=[];
                end
                figure('NumberTitle','Off')
                for d=1:length(stimtypes);
                    if ~isempty(allmemb{d});
                        if ~isempty(allaps{a,cells(c),d});
                            repres=zeros(size(allaps{a,cells(c),d}));
                            firsttimes=[];
                            for f=1:length(allaps{a,cells(c),d});%for each trial
                                if ~isempty(allaps{a,cells(c),d}{f});
                                    temp=allaps{a,cells(c),d}{f};
                                    temp=temp(find(temp>0));
                                    if ~isempty(temp);
                                        repres(f)=1;
                                        firsttimes(end+1)=temp(1);
                                    end
                                end
                            end
                            reliability{d}(end+1)=sum(repres)/length(repres);
                            relstring=['Reliability = ',num2str(reliability{d}(end)),'. '];
                            if length(firsttimes)>=2;%arbitrary... 2 just to get SOMETHING
                                jitter{d}(end+1)=range(firsttimes)/10;%in ms
                            else
                                jitter{d}(end+1)=NaN;
                            end
                            jitstring=['Jitter = ',num2str(jitter{d}(end)),'. '];
                        end
    %% for plotting each class of stim

                        subplot(length(stimtypes),1,d);
                        plot(allmemb{d}');
                        set(gca,'XLim',[0 beforedur+afterdur])
                        set(gca,'XTickLabel',num2str(str2num(get(gca,'XTickLabel'))-beforedur))

                        stimstring=[upper(stimtypes{d}),'. '];
                        trialssting=[num2str(size(allmemb{d},1)),' trials. '];
                        switch cells(c)
                            case (1)
                                fn='in5cell';
                            case (2)
                                fn='in10cell';
                            case (3)
                                fn='in14cell';
                        end
                        eval(['celltypestring=matnotes(a).',fn,';'])
                        celltypestring=[celltypestring,'. '];
                        if matnotes(a).corecells(c)
                            corestring='Core. ';
                        else
                            corestring='Non-core. ';
                        end
        %                 if ~isempty(matnotes(a,1).directinput)
        %     				ds='Direct. ';
        %     			else
        %     				ds='Not Direct. ';
        %     			end
                        directstring='';
                        text(0,1.1,[stimstring,trialssting,relstring,jitstring]...
                            ,'units','normalized','parent',gca)

                        slicename=[slicename(1:8),'0 Cell#',num2str(c),' Slice ',num2str(a),'. '];
                        set(gcf,'Name',[slicename, celltypestring, corestring, directstring]);
                    end
                end
            end
%%
        end
        output.memb{a,cells(c)}=allmemb;
    end
end

output.stimorder=stimtypes;
output.allaps=allaps;
output.reliability=reliability;
output.jitter=jitter;