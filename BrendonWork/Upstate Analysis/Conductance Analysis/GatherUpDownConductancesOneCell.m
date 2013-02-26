function cellnumbers = GatherUpDownConductancesOneCell(varargin)
%gathering mean UP and DOWN state conductances for an individual cell
%either expects a filepath coming in or asks user for one?
if isempty(varargin)
    [FileName,PathName,FilterIndex] = uigetfile;
    filepath = [PathName,FileName];
else
    filepath = varargin{1};
end
[path,filename]=fileparts(filepath);

w = load(filepath);
fie = fieldnames(w);


cellnumbers.UMeanConducts = [];
cellnumbers.DMeanConducts = [];
cellnumbers.UMeanResists = [];
cellnumbers.DMeanResists = [];
cellnumbers.UMedianConducts = [];
cellnumbers.DMedianConducts = [];
cellnumbers.UMedianResists = [];
cellnumbers.DMedianResists = [];
cellnumbers.DownFileBreaks = [];
cellnumbers.UpFileBreaks = [];
recnames = {};
numUPs = 0;

for vidx = 1:length(fie)
    thiscms = eval(['w.',fie{vidx}]);
    cellnumbers.DownFileBreaks(end+1) = 0; 
    cellnumbers.UpFileBreaks(end+1) = 0; 
    recnames{end+1} = thiscms(1).FileName;
    thisUD = [];
    for hidx = 1:length(thiscms)
        tU = thiscms(hidx).toUse;
        if strcmp(thiscms(hidx).UD,'D')
           eval(['cellnumbers.DMeanConducts(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageConductance;'])
           eval(['cellnumbers.DMeanResists(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageResistance;'])
           eval(['cellnumbers.DMedianConducts(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageConductance;'])
           eval(['cellnumbers.DMedianResists(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageResistance;'])
           cellnumbers.DownFileBreaks(end) = cellnumbers.DownFileBreaks(end) + 1; 
           thisUD(end+1) = 0;
        elseif strcmp(thiscms(hidx).UD,'U')
           eval(['cellnumbers.UMeanConducts(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageConductance;'])
           eval(['cellnumbers.UMeanResists(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageResistance;'])
           eval(['cellnumbers.UMedianConducts(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageConductance;'])
           eval(['cellnumbers.UMedianResists(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageResistance;'])            
           cellnumbers.UpFileBreaks(end) = cellnumbers.UpFileBreaks(end) + 1; 
          thisUD(end+1) = 1;
        end
    end
    UPsthisrecord = continuousabove(thisUD,zeros(size(thisUD)),.1,1,Inf);
    numUPs = numUPs + size(UPsthisrecord,1);
end

cellnumbers.DMeanMeanResists = mean(cellnumbers.DMeanResists);
cellnumbers.DSDMeanResists = std(cellnumbers.DMeanResists);
cellnumbers.UMeanMeanResists = mean(cellnumbers.UMeanResists);
cellnumbers.USDMeanResists = std(cellnumbers.UMeanResists);
cellnumbers.DMeanMeanConducts = mean(cellnumbers.DMeanConducts);
cellnumbers.DSDMeanConducts = std(cellnumbers.DMeanConducts);
cellnumbers.UMeanMeanConducts = mean(cellnumbers.UMeanConducts);
cellnumbers.USDMeanConducts = std(cellnumbers.UMeanConducts);

cellnumbers.DMeanMedianResists = mean(cellnumbers.DMedianResists);
cellnumbers.DSDMedianResists = std(cellnumbers.DMedianResists);
cellnumbers.UMeanMedianResists = mean(cellnumbers.UMedianResists);
cellnumbers.USDMedianResists = std(cellnumbers.UMedianResists);
cellnumbers.DMeanMedianConducts = mean(cellnumbers.DMedianConducts);
cellnumbers.DSDMedianConducts = std(cellnumbers.DMedianConducts);
cellnumbers.UMeanMedianConducts = mean(cellnumbers.UMedianConducts);
cellnumbers.USDMedianConducts = std(cellnumbers.UMedianConducts);

cellnumbers.NumberofSamples = length(cellnumbers.UMeanResists);
cellnumbers.NumberofUPstates = numUPs;
cellnumbers.NumberofFiles = length(fie);

%% plot resistance over time
figure('name',filename);
subplot(2,1,1);
plot(cellnumbers.DMeanResists);
hold on;
title({['Resistance of ',num2str(length(cellnumbers.DMeanResists)),' DOWN states from ,',num2str(length(fie)),' files (blue)']
    ['and ',num2str(length(cellnumbers.UMeanResists)),' samples from ',num2str(numUPs),' UP states in ',num2str(length(fie)),' files (red).']})
LastDOWNs = cumsum(cellnumbers.DownFileBreaks);
FirstDOWNs = [1 LastDOWNs(1:end-1)+1];
% plot(LastDOWNs,ones(size(cellnumbers.DownFileBreaks)),'x','color','k')
LastUPs = cumsum(cellnumbers.UpFileBreaks);
FirstUPs = [1 LastUPs(1:end-1)+1];

for fidx = 1:length(LastUPs);
    theseUPs = cellnumbers.UMeanResists(FirstUPs(fidx):LastUPs(fidx));
    plot(FirstDOWNs(fidx):(FirstDOWNs(fidx)+length(theseUPs)-1),theseUPs,'o','color','r')
    text(FirstDOWNs(fidx),-300000000+35000000*fidx,recnames{fidx});
end
    





% [means,stds] = errorbargraphmeansd(cellnumbers.DMeanResists,cellnumbers.UMeanResists);
% title({['Mean resistances: '];...
%     ['DOWN(',num2str(means(1)),'+-',num2str(stds(1)),')'];...
%     ['   UP   (',num2str(means(2)),'+-',num2str(stds(2)),')']})
% cellnumbers.DMeanMeanResists = means(1);
% cellnumbers.UMeanMeanResists = means(2);

% [means,stds] = errorbargraphmeansd(cellnumbers.DMeanConducts,cellnumbers.UMeanConducts);
% title({['Mean conductances: '];...
%     ['DOWN(',num2str(means(1)),'+-',num2str(stds(1)),')'];...
%     ['   UP   (',num2str(means(2)),'+-',num2str(stds(2)),')']})

