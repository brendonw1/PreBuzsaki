function cellnumbers = GatherUpDownConductancesOneCellReshuff(numreshuffs,varargin)
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

for ridx = 1:numreshuffs;
    cellnumbers(ridx).UMeanConducts = [];
    cellnumbers(ridx).DMeanConducts = [];
    cellnumbers(ridx).UMeanResists = [];
    cellnumbers(ridx).DMeanResists = [];
    % cellnumbers.UMedianConducts = [];
    % cellnumbers.DMedianConducts = [];
    % cellnumbers.UMedianResists = [];
    % cellnumbers.DMedianResists = [];
end
% cellnumbers.DownFileBreaks = [];
% cellnumbers.UpFileBreaks = [];
% recnames = {};

for vidx = 1:length(fie)
    thiscms = eval(['w.',fie{vidx}]);
%     cellnumbers.DownFileBreaks(end+1) = 0; 
%     cellnumbers.UpFileBreaks(end+1) = 0; 
%     recnames{end+1} = thiscms(1).FileName;
%% make surrogate UD
    realUD = zeros(1,length(thiscms));
    randUD = zeros(numreshuffs,length(thiscms));
    for hidx = 1:length(thiscms)
        if strcmp(thiscms(hidx).UD,'D')
            realUD(hidx) = 0;
        elseif strcmp(thiscms(hidx).UD,'U')
            realUD(hidx) = 1;
        end    
    end
    numUPs = sum(realUD);
    randUPspots = ceil(size(realUD,2)*rand(numreshuffs,numUPs));
    adjustperreshuff = length(thiscms)*(0:(numreshuffs-1));
    adjustperreshuff = repmat(adjustperreshuff',[1 size(randUPspots,2)]);
    randUPspots = randUPspots + adjustperreshuff;
    randUD(randUPspots) = 1;
    %go through each hidx
    %go through each reshuff
    %take 0/1
    for ridx = 1:numreshuffs;
        
        for hidx = 1:length(thiscms)
            tU = thiscms(hidx).toUse;
            if randUD(ridx,hidx) == 0;
                eval(['cellnumbers(ridx).DMeanConducts(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageConductance;'])
                eval(['cellnumbers(ridx).DMeanResists(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageResistance;'])
%                 eval(['cellnumbers.DMedianConducts(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageConductance;'])
%                 eval(['cellnumbers.DMedianResists(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageResistance;'])
%                 cellnumbers.DownFileBreaks(end) = cellnumbers.DownFileBreaks(end) + 1; 
%             elseif strcmp(thiscms(hidx).UD,'U')
            elseif randUD(ridx,hidx) == 1;
                eval(['cellnumbers(ridx).UMeanConducts(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageConductance;'])
                eval(['cellnumbers(ridx).UMeanResists(end+1) = thiscms(hidx).',tU,'DepolMeanLast50VoltageResistance;'])
    %             eval(['cellnumbers.UMedianConducts(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageConductance;'])
    %             eval(['cellnumbers.UMedianResists(end+1) = thiscms(hidx).',tU,'DepolMedianLast50VoltageResistance;'])            
%                 cellnumbers.UpFileBreaks(end) = cellnumbers.UpFileBreaks(end) + 1; 
            end
        end
    end
end

for ridx = 1:numreshuffs;
    cellnumbers(1).DMeanMeanResists(ridx) = mean(cellnumbers(ridx).DMeanResists);
    cellnumbers(1).DSDMeanResists(ridx) = std(cellnumbers(ridx).DMeanResists);
    cellnumbers(1).UMeanMeanResists(ridx) = mean(cellnumbers(ridx).UMeanResists);
    cellnumbers(1).USDMeanResists(ridx) = std(cellnumbers(ridx).UMeanResists);
    cellnumbers(1).DMeanMeanConducts(ridx) = mean(cellnumbers(ridx).DMeanConducts);
    cellnumbers(1).DSDMeanConducts(ridx) = std(cellnumbers(ridx).DMeanConducts);
    cellnumbers(1).UMeanMeanConducts(ridx) = mean(cellnumbers(ridx).UMeanConducts);
    cellnumbers(1).USDMeanConducts(ridx) = std(cellnumbers(ridx).UMeanConducts);
end

% cellnumbers.DMeanMedianResists = mean(cellnumbers.DMedianResists);
% cellnumbers.DSDMedianResists = std(cellnumbers.DMedianResists);
% cellnumbers.UMeanMedianResists = mean(cellnumbers.UMedianResists);
% cellnumbers.USDMedianResists = std(cellnumbers.UMedianResists);
% cellnumbers.DMeanMedianConducts = mean(cellnumbers.DMedianConducts);
% cellnumbers.DSDMedianConducts = std(cellnumbers.DMedianConducts);
% cellnumbers.UMeanMedianConducts = mean(cellnumbers.UMedianConducts);
% cellnumbers.USDMedianConducts = std(cellnumbers.UMedianConducts);


%% plot resistance over time
% figure('name',filename);
% plot(cellnumbers.DMeanResists);
% hold on;
% title({['Resistance of ',num2str(length(cellnumbers.DMeanResists)),' DOWN states from ,',num2str(length(w)),' files (blue)']
%     ['and ',num2str(length(cellnumbers.UMeanResists)),' UP states from ',num2str(length(w)),' files (red).']})
% LastDOWNs = cumsum(cellnumbers.DownFileBreaks);
% FirstDOWNs = [1 LastDOWNs(1:end-1)+1];
% % plot(LastDOWNs,ones(size(cellnumbers.DownFileBreaks)),'x','color','k')
% LastUPs = cumsum(cellnumbers.UpFileBreaks);
% FirstUPs = [1 LastUPs(1:end-1)+1];
% 
% for fidx = 1:length(LastUPs);
%     theseUPs = cellnumbers.UMeanResists(FirstUPs(fidx):LastUPs(fidx));
%     plot(FirstDOWNs(fidx):(FirstDOWNs(fidx)+length(theseUPs)-1),theseUPs,'o','color','r')
%     text(FirstDOWNs(fidx),-300000000+35000000*fidx,recnames{fidx});
% end
    





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

