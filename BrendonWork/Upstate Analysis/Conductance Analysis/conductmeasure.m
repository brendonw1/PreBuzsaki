function cms = conductmeasure

answer = inputdlg({'Enter data channel (axis number) for voltage',...
    'Enter data channel (axis number) for current',...
    'Enter downward threshold for finding injections in current trace'},...
    'Conductance channels',...
    1,...
    {'1','2','-5'});%default values
vchannum = str2double(answer{1});
cchannum = str2double(answer{2});
currentthresh = str2double(answer{3});

%% get figure handles and data
f = findobj('type','figure','tag','EphysViewer');
decdata=getappdata(f,'decdata');
allrawdata = decdata.data{1};
vchan = allrawdata(:,vchannum);
cchan = allrawdata(:,cchannum);
clear decdata allrawdata;

handles = guidata(f);

%% divide up and down states
disp('Enter a pair of inputs signifying start and stop of each UP state.  Hit enter when finished,')
[x,y] = ginput;
x = x*10000;
if isempty(x);
    error('Click to indicate start and stop times of UP states')
    return
end
if mod(size(x,1),2) ~= 0
    error('Must make paired clicks');
    return
end
DS = [1 x(1)-1];
US = [];
for idx = 1:2:(length(x)-1)
    US(end+1,:) = [x(idx) x(idx+1)];%store each upstate
    if idx<(length(x)-1)%as long as not at end
        DS(end+1,:) = [x(idx+1)+1 x(idx+2)-1];%and following downstate
    end
end
DS(end+1,:) = [x(end)+1 length(vchan)];%at end, store a downstate lasting to the end of the trace

%% get hyperpol and depol periods, by looking for depolarizing injections
[hypCs,depCs] = pt_continuousbelow(cchan,zeros(size(cchan)),currentthresh,1000,5500,2);

hyplengths = diff(hypCs,[],2);
deplengths = diff(depCs,[],2);
hypdur = mode(hyplengths);
exclude = round(hypdur/2);

hypVs = hypCs;
hypVs(:,1) = hypVs(:,1) + exclude;%remove exclusion region from front, leave rest
hypVs(:,2) = hypVs(:,2) - 3;%don't count last 3 points, just for safety
depVs = depCs;
depVs(:,1) = depVs(:,1) + exclude;
depVs(:,2) = depVs(:,2) - 10;%don't cound last 1ms, since depCs were not 
% really recognized but were just the places that were NOT hypCs

%throw away all periods that are too short
htoss = hyplengths<(.9*hypdur);
hypCs(htoss,:) = [];
hypVs(htoss,:) = [];
hyplengths(htoss) = [];
dtoss = deplengths<(.9*hypdur);
depCs(dtoss,:) = [];
depVs(dtoss,:) = [];
deplengths(htoss) = [];

%% match each hyperpolarization to a depolarization in the same UP/DOWN
%% state period
%for each hyperpol, try at first to use the prior depol
%if that's not in the same u/d try switching to 2nd
%switch paradigm from then on??
HypDmatches = zeros(1,length(hypVs));
DepDmatches = zeros(1,length(depVs));
HypUmatches = zeros(1,length(hypVs));
DepUmatches = zeros(1,length(depVs));

for didx = 1:size(DS,1);
    startsafter = hypCs(:,1)>=DS(didx,1);
    endsbefore = hypCs(:,2)<=DS(didx,2);
    HypDmatches(find(startsafter .* endsbefore)) = didx;
    
    startsafter = depCs(:,1)>=DS(didx,1);
    endsbefore = depCs(:,2)<=DS(didx,2);
    DepDmatches(find(startsafter .* endsbefore)) = didx;
end
for uidx = 1:size(US,1);
    startsafter = hypCs(:,1)>=US(uidx,1);
    endsbefore = hypCs(:,2)<=US(uidx,2);
    HypUmatches(find(startsafter .* endsbefore)) = uidx;
    
    startsafter = depCs(:,1)>=US(uidx,1);
    endsbefore = depCs(:,2)<=US(uidx,2);
    DepUmatches(find(startsafter .* endsbefore)) = uidx;
end

%% go through hyperpolarizing pulses and find depolarizing pulses that can
%% pair up for subtraction (adjacent on either or both sides and in same
%% UP/DOWN state)


cmssize = 0;
for hidx = 1:length(hypCs);
    thisD = 0;
    thisU = 0;
    beforeNum = [];
    afterNum = [];
    if HypDmatches(hidx)%if encompassed in a DOWN state
        thisD = HypDmatches(hidx);%the fact that this is not zero will encode that this
        % hyperpolarizing pulse was in a DS, not US. Also the value is
        % which DS
        beforeNum = find((depCs(:,2)<hypCs(hidx,1)) .* (depCs(:,2)>(hypCs(hidx,1)-50)));
        % find a depolarizing pulse that ends prior to this hyp but not
        % more than 5ms before
        if DepDmatches(beforeNum) ~= thisD%make sure the candidate before pulse is in the same DS
            beforeNum = [];%if it isn't, nullify it
        end
        
        afterNum = find((depCs(:,1)>hypCs(hidx,2)) .* (depCs(:,1)<(hypCs(hidx,2)+50)));
        % find a depolarizing pulse that starts after this hyp but not
        % more than 5ms after        
        if DepDmatches(afterNum) ~= thisD%make sure the candidate after pulse is in the same DS
            afterNum = [];%if it isn't, nullify it
        end
    elseif HypUmatches(hidx)%if encompassed in an UP state
        thisU = HypUmatches(hidx);%the fact that this is not zero will encode that this
        % hyperpolarizing pulse was in a US, not DS. Also the value is
        % which US
        beforeNum = find((depCs(:,2)<hypCs(hidx,1)) .* (depCs(:,2)>(hypCs(hidx,1)-50)));
        % find a depolarizing pulse that ends prior to this hyp but not
        % more than 5ms before
        if DepUmatches(beforeNum) ~= thisU%make sure the candidate before pulse is in the same US
            beforeNum = [];%if it isn't, nullify it
        end
        
        afterNum = find((depCs(:,1)>hypCs(hidx,2)) .* (depCs(:,1)<(hypCs(hidx,2)+50)));
        % find a depolarizing pulse that starts after this hyp but not
        % more than 5ms after        
        if DepUmatches(afterNum) ~= thisU%make sure the candidate after pulse is in the same US
            afterNum = [];%if it isn't, nullify it
        end
    end

%% if there are qualified before or after pulses for this hyperpolarizing
%% pulse, store information for output
    if ~isempty(beforeNum) || ~isempty(afterNum)
        cmssize = cmssize+1;
        cms(cmssize).FileName = handles.filename;
        cms(cmssize).CurrentChannel = get(handles.ChannelLabels(cchannum),'String');
        cms(cmssize).VoltageChannel = get(handles.ChannelLabels(vchannum),'String');
        if ~isempty(beforeNum) && ~isempty(afterNum)
            cms(cmssize).toUse = 'combo';
        elseif ~isempty(beforeNum) && isempty(afterNum)
            cms(cmssize).toUse = 'before';
        elseif isempty(beforeNum) && ~isempty(afterNum)
            cms(cmssize).toUse = 'after';
        end
            
        if thisD & ~thisU
            cms(cmssize).UD = 'D';
        elseif ~thisD & thisU
            cms(cmssize).UD = 'U';
        else
            error('Problem in assigning UP/DOWN status')
        end
        cms(cmssize).hyperpolCurrentIndices = hypCs(hidx,:);%C indicies
        cms(cmssize).hyperpolVoltageIndices = hypVs(hidx,:);%V indices
        cms(cmssize).hyperpolCurrentTrace = cchan(hypCs(hidx,1):hypCs(hidx,2));%Current trace
        cms(cmssize).hyperpolWholeVoltageTrace = vchan(hypCs(hidx,1):hypCs(hidx,2));%Whole voltage 
        % trace from full current injection period
        cms(cmssize).hyperpolLast50VoltageTrace = vchan(hypVs(hidx,1):hypVs(hidx,2));%Voltage from last 
        %50% of current inj
        %% start getting rid of action potentials below???????
%         aps = findaps2(cms(cmssize).hyperpolLast50VoltageTrace);
%         cms(cmssize).HyperpolAps = aps;
%         noaps = cms(cmssize).hyperpolLast50VoltageTrace;
%         if ~isempty(aps);
%             aps = [aps'-20 aps'+100];%remove 2ms before and 10ms after the AP
%             aps (aps<1) = 1;
%             aps (aps>length(noaps)) = length(noaps);
%             noaps(aps) = [];
%         end
% 
%         
%         %store means of all recorded periods
%         cms(cmssize).hyperpolCurrentMean = mean(cms(cmssize).hyperpolCurrentTrace);            
%         cms(cmssize).hyperpolLast50VoltageMean = mean(noaps);
%         %store medians of all recorded periods
%         cms(cmssize).hyperpolCurrentMedian = median(cms(cmssize).hyperpolCurrentTrace);
%         cms(cmssize).hyperpolLast50VoltageMedian = median(noaps);
        
        %store means of all recorded periods
        cms(cmssize).hyperpolCurrentMean = mean(cms(cmssize).hyperpolCurrentTrace);            
        cms(cmssize).hyperpolLast50VoltageMean = mean(cms(cmssize).hyperpolLast50VoltageTrace);
        %store medians of all recorded periods
        cms(cmssize).hyperpolCurrentMedian = median(cms(cmssize).hyperpolCurrentTrace);
        cms(cmssize).hyperpolLast50VoltageMedian = median(cms(cmssize).hyperpolLast50VoltageTrace);

        %store info for before-depolarizations, if any qualify
        if ~isempty(beforeNum);
            cms(cmssize).beforeDepolCurrentIndices = depCs(beforeNum,:);
            cms(cmssize).beforeDepolVoltageIndices = depVs(beforeNum,:);%V indices
            cms(cmssize).beforeDepolCurrentTrace = cchan(depCs(beforeNum,1):depCs(beforeNum,2));%Current trace
            cms(cmssize).beforeDepolWholeVoltageTrace = vchan(depCs(beforeNum,1):depCs(beforeNum,2));%Whole voltage 
            % trace from full current injection period
            cms(cmssize).beforeDepolLast50VoltageTrace = vchan(depVs(beforeNum,1):depVs(beforeNum,2));%Voltage from last 
            %50% of current inj
            
            %store means of all recorded periods
            cms(cmssize).beforeDepolCurrentMean = mean(cms(cmssize).beforeDepolCurrentTrace);
            cms(cmssize).beforeDepolLast50VoltageMean = mean(cms(cmssize).beforeDepolLast50VoltageTrace);
            %store medians of all recorded periods
            cms(cmssize).beforeDepolCurrentMedian = median(cms(cmssize).beforeDepolCurrentTrace);
            cms(cmssize).beforeDepolLast50VoltageMedian = median(cms(cmssize).beforeDepolLast50VoltageTrace);
            
            %diff of means
            cms(cmssize).beforeDepolCurrentMeanDiff = cms(cmssize).beforeDepolCurrentMean - ...
                cms(cmssize).hyperpolCurrentMean;
            cms(cmssize).beforeDepolLast50VoltageMeanDiff = cms(cmssize).beforeDepolLast50VoltageMean - ...
                cms(cmssize).hyperpolLast50VoltageMean;
            %diff of medians
            cms(cmssize).beforeDepolCurrentMedianDiff = cms(cmssize).beforeDepolCurrentMedian - ...
                cms(cmssize).hyperpolCurrentMedian;
            cms(cmssize).beforeDepolLast50VoltageMedianDiff = cms(cmssize).beforeDepolLast50VoltageMedian - ...
                cms(cmssize).hyperpolLast50VoltageMedian;
            
            %resistance from means
            cms(cmssize).beforeDepolMeanLast50VoltageResistance = 1000000000 * cms(cmssize).beforeDepolLast50VoltageMeanDiff /...
                cms(cmssize).beforeDepolCurrentMeanDiff;
            %resistance from medians
            cms(cmssize).beforeDepolMedianLast50VoltageResistance = 1000000000 * cms(cmssize).beforeDepolLast50VoltageMedianDiff /...
                cms(cmssize).beforeDepolCurrentMedianDiff;
            
            %conductance from means
            cms(cmssize).beforeDepolMeanLast50VoltageConductance = 1/cms(cmssize).beforeDepolMeanLast50VoltageResistance;
            %conductance from medians
            cms(cmssize).beforeDepolMedianLast50VoltageConductance = 1/cms(cmssize).beforeDepolMedianLast50VoltageResistance;
        end

        %store info for after-depolarizations, if any qualify
        if ~isempty(afterNum);
            cms(cmssize).afterDepolCurrentIndices = depCs(afterNum,:);
            cms(cmssize).afterDepolVoltageIndices = depVs(afterNum,:);%V indices
            cms(cmssize).afterDepolCurrentTrace = cchan(depCs(afterNum,1):depCs(afterNum,2));%Current trace
            cms(cmssize).afterDepolWholeVoltageTrace = vchan(depCs(afterNum,1):depCs(afterNum,2));%Whole voltage 
            % trace from full current injection period
            cms(cmssize).afterDepolLast50VoltageTrace = vchan(depVs(afterNum,1):depVs(afterNum,2));%Voltage from last 
            %50% of current inj
            
            %store means of all recorded periods
            cms(cmssize).afterDepolCurrentMean = mean(cms(cmssize).afterDepolCurrentTrace);
            cms(cmssize).afterDepolLast50VoltageMean = mean(cms(cmssize).afterDepolLast50VoltageTrace);
            %store medians of all recorded periods
            cms(cmssize).afterDepolCurrentMedian = median(cms(cmssize).afterDepolCurrentTrace);
            cms(cmssize).afterDepolLast50VoltageMedian = median(cms(cmssize).afterDepolLast50VoltageTrace);
            
            %diff of means
            cms(cmssize).afterDepolCurrentMeanDiff = cms(cmssize).afterDepolCurrentMean - ...
                cms(cmssize).hyperpolCurrentMean;
            cms(cmssize).afterDepolLast50VoltageMeanDiff = cms(cmssize).afterDepolLast50VoltageMean - ...
                cms(cmssize).hyperpolLast50VoltageMean;
            %diff of medians
            cms(cmssize).afterDepolCurrentMedianDiff = cms(cmssize).afterDepolCurrentMedian - ...
                cms(cmssize).hyperpolCurrentMedian;
            cms(cmssize).afterDepolLast50VoltageMedianDiff = cms(cmssize).afterDepolLast50VoltageMedian - ...
                cms(cmssize).hyperpolLast50VoltageMedian;
            
            %resistance from means
            cms(cmssize).afterDepolMeanLast50VoltageResistance = 1000000000 * cms(cmssize).afterDepolLast50VoltageMeanDiff /...
                cms(cmssize).afterDepolCurrentMeanDiff;
            %resistance from medians
            cms(cmssize).afterDepolMedianLast50VoltageResistance = 1000000000 * cms(cmssize).afterDepolLast50VoltageMedianDiff /...
                cms(cmssize).afterDepolCurrentMedianDiff;
            
            %conductance from means
            cms(cmssize).afterDepolMeanLast50VoltageConductance = 1/cms(cmssize).afterDepolMeanLast50VoltageResistance;
            %conductance from medians
            cms(cmssize).afterDepolMedianLast50VoltageConductance = 1/cms(cmssize).afterDepolMedianLast50VoltageResistance;
        end
        
        %store info for combo mean of before- and after-depolarizations, if both
        %qualify (note no indices)
        if ~isempty(beforeNum) && ~isempty(afterNum);
            bt = cms(cmssize).beforeDepolCurrentTrace;
            at = cms(cmssize).afterDepolCurrentTrace;
            sz = min([size(at,1) size(bt,1)]);
            cms(cmssize).comboDepolCurrentTrace = mean([bt(1:sz) at(1:sz)],2);%Current trace
            
            bt = cms(cmssize).beforeDepolWholeVoltageTrace;
            at = cms(cmssize).afterDepolWholeVoltageTrace;
            sz = min([size(at,1) size(bt,1)]);
            cms(cmssize).comboDepolWholeVoltageTrace = mean([bt(1:sz) at(1:sz)],2);%Whole voltage 
            % trace from full current injection period
            
            bt = cms(cmssize).beforeDepolLast50VoltageTrace;
            at = cms(cmssize).afterDepolLast50VoltageTrace;
            sz = min([size(at,1) size(bt,1)]);
            cms(cmssize).comboDepolLast50VoltageTrace = mean([bt(1:sz) at(1:sz)],2);%Voltage from last 
            %50% of current inj
            
            %store means of all recorded periods
            cms(cmssize).comboDepolCurrentMean = mean(cms(cmssize).comboDepolCurrentTrace);
            cms(cmssize).comboDepolWholeVoltageMean = mean(cms(cmssize).comboDepolWholeVoltageTrace);
            cms(cmssize).comboDepolLast50VoltageMean = mean(cms(cmssize).comboDepolLast50VoltageTrace);
            %store medians of all recorded periods
            cms(cmssize).comboDepolCurrentMedian = median(cms(cmssize).comboDepolCurrentTrace);
            cms(cmssize).comboDepolWholeVoltageMedian = median(cms(cmssize).comboDepolWholeVoltageTrace);
            cms(cmssize).comboDepolLast50VoltageMedian = median(cms(cmssize).comboDepolLast50VoltageTrace);
            
            %diff of means
            cms(cmssize).comboDepolCurrentMeanDiff = cms(cmssize).comboDepolCurrentMean - ...
                cms(cmssize).hyperpolCurrentMean;
            cms(cmssize).comboDepolLast50VoltageMeanDiff = cms(cmssize).comboDepolLast50VoltageMean - ...
                cms(cmssize).hyperpolLast50VoltageMean;
            %diff of meadians
            cms(cmssize).comboDepolCurrentMedianDiff = cms(cmssize).comboDepolCurrentMedian - ...
                cms(cmssize).hyperpolCurrentMedian;
            cms(cmssize).comboDepolLast50VoltageMedianDiff = cms(cmssize).comboDepolLast50VoltageMedian - ...
                cms(cmssize).hyperpolLast50VoltageMedian;
            
            %resistance from means
            cms(cmssize).comboDepolMeanLast50VoltageResistance = 1000000000 * cms(cmssize).comboDepolLast50VoltageMeanDiff /...
                cms(cmssize).comboDepolCurrentMeanDiff;
            %resistance from medians
            cms(cmssize).comboDepolMedianLast50VoltageResistance = 1000000000 * cms(cmssize).comboDepolLast50VoltageMedianDiff /...
                cms(cmssize).comboDepolCurrentMedianDiff;
            
            %conductance from means
            cms(cmssize).comboDepolMeanLast50VoltageConductance = 1/cms(cmssize).comboDepolMeanLast50VoltageResistance;
            %conductance from medians
            cms(cmssize).comboDepolMedianLast50VoltageConductance = 1/cms(cmssize).comboDepolMedianLast50VoltageResistance;
        end

% remove APs        
    end
end