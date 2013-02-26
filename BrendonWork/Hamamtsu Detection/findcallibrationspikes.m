function findcallibrationspikes

[filename,pathname,filterindex] = uigetfile('.mat','Choose .mat file containing callibration data');%ask user to open a file

eval(['load ',filename]);%open it and save contents in a struct file
clear filename pathname filterindex

% handles.fig=figure('position',get(0,'ScreenSize'));
handles.fig=figure;
handles.ax=axes('parent',handles.fig);
handles.backbutton=uicontrol('style','pushbutton','string','Back',...
    'units','normalized','position',[.05 .02 .1 .05],...
    'callback',@backbuttoncallback);
handles.skipbutton=uicontrol('style','pushbutton','string','Skip',...
    'units','normalized','position',[.17 .02 .1 .05 ],...
    'callback',@skipbuttoncallback);
handles.redobutton=uicontrol('style','pushbutton','string','Redo',...
    'units','normalized','position',[.75 .02 .1 .05],...
    'callback',@redobuttoncallback);
handles.forwardbutton=uicontrol('style','pushbutton','string','Forward',...
    'units','normalized','position',[.87 .02 .1 .05],...
    'callback',@forwardbuttoncallback);
handles.allcal=allcal;
handles.allcellnames=fieldnames(allcal);
temp=strmatch('Stats',handles.allcellnames);
if ~isempty(temp);
    handles.allcellnames(temp)=[];
end
handles.cellcounter=1;
handles.trialcounter=0;
handles.alltrialnames=eval(['fieldnames(handles.allcal.',handles.allcellnames{handles.cellcounter},');']);

guidata(handles.fig,handles);
forwardbuttoncallback(handles.fig,[]);

%%
function backbuttoncallback(obj,ev);
handles=guidata(obj);
if handles.trialcounter==1;
    handles.cellcounter=handles.cellcounter-1;
    handles.alltrialnames=eval(['fieldnames(handles.allcal.',handles.allcellnames{handles.cellcounter},');']);
    handles.trialcounter=size(handles.alltrialnames,1);
else
    handles.trialcounter=handles.trialcounter-2;
end
guidata(handles.fig,handles);
forwardbuttoncallback(handles.fig,[]);

%%
function skipbuttoncallback(obj,ev);
handles=guidata(obj);
handles.trialcounter=handles.trialcounter+1;
guidata(handles.fig,handles);
forwardbuttoncallback(handles.fig,[]);

%%
function forwardbuttoncallback(obj,ev);
handles=guidata(obj);
handles.trialcounter=handles.trialcounter+1;

if handles.trialcounter>size(handles.alltrialnames,1);
    handles.cellcounter=handles.cellcounter+1;
    handles.trialcounter=1;
    if handles.cellcounter<=size(handles.allcellnames,1);
        handles.alltrialnames=eval(['fieldnames(handles.allcal.',handles.allcellnames{handles.cellcounter},');']);
    end
end
if handles.cellcounter>size(handles.allcellnames,1);%if now gone over the number of cells used
    handles=finishfunction(handles);
    assignin('base','allcal',handles.allcal);
    return;
end
delete(get(handles.ax,'children'))
eval(['struc=handles.allcal.',handles.allcellnames{handles.cellcounter},'.',handles.alltrialnames{handles.trialcounter},';']);
if isfield(struc,'data');
    if ~isempty(struc.data);
        trace=struc.data;
%                 if ~isfield(struc,'bounds');
            xp=min([length(trace) 150]);
            xp=1:xp;
            yp=detrend(trace(xp));
            handles.line=line(xp,yp,'parent',handles.ax);
            [x,y]=ginput(3);
            x=round(x);
            x(x<1)=1;
            x(x>length(trace))=length(trace);
            y=trace(x);
            struc.bounds=[x,y];
%                 else
%                     x=struc.bounds(:,1);
%                     y=struc.bounds(:,2);
%                 end
        eval(['allcal.',handles.allcellnames{handles.cellcounter},'.',handles.alltrialnames{handles.trialcounter},'=struc;']);
    end
end
guidata(handles.fig,handles);

%%
function redobuttoncallback(obj,ev);
handles=guidata(obj);
handles.trialcounter=handles.trialcounter-1;
guidata(handles.fig,handles);
forwardbuttoncallback(handles.fig,[]);

%%
function handles=finishfunction(handles); 

allcal=handles.allcal;
allcal.Stats.AllPercentDecreases=[];
allcal.Stats.AllNumPointsToDecreases=[];
allcal.Stats.AllSlopeofDecreases=[];
allcal.Stats.AllSignalIntegrals=[];
allcal.Stats.ByCellPercentDecreases=[];
allcal.Stats.ByCellNumPointsToDecreases=[];
allcal.Stats.ByCellSlopeofDecreases=[];
allcal.Stats.ByCellSignalIntegrals=[];
%repeat loop to gather data... do this so no problems with final data
%gathering if .Stats already contained data from a previous iteration of
%this program... all is erased and regenerated here.
for cellcounter=1:size(handles.allcellnames,1);%for each variable... ie callibration cell
    handles.alltrialnames=eval(['fieldnames(allcal.',handles.allcellnames{cellcounter},');']);
    PercentDecreases=[];
    NumPointsToDecreases=[];
    SlopeofDecreases=[];
    SignalIntegrals=[];
    
    handles.trialcounter=1;
    while handles.trialcounter<=size(handles.alltrialnames,1);%for each experiment
        delete(get(handles.ax,'children'))
        eval(['struc=allcal.',handles.allcellnames{cellcounter},'.',handles.alltrialnames{handles.trialcounter},';']);
        if isfield(struc,'data');
            if ~isempty(struc.data);
                trace=struc.data;
                x=struc.bounds(:,1);
                y=struc.bounds(:,2);
                
                sx=[x(1):x(3)]';
                sy=trace(sx);
                struc.SignalRaw=[sx,sy];
                PercentDecreases(end+1)=(y(2)-y(1))/y(1);
                struc.PercentDecrease=PercentDecreases(end);
                NumPointsToDecreases(end+1)=x(2)-x(1);
                struc.NumPointsToDecrease=NumPointsToDecreases(end);
                SlopeofDecreases(end+1)=struc.PercentDecrease/struc.NumPointsToDecrease;
                struc.SlopeofDecrease=SlopeofDecreases(end);
                
                p=polyfit(x([1,3]),y([1,3]),1);
                ty=polyval(p,sx);
                struc.BleachTrend=[sx,ty];
                struc.SignalBelowTrend=[sx,sy-ty];
                SignalIntegrals(end+1)=sum(struc.SignalBelowTrend(:,2));
                struc.SignalIntegral=SignalIntegrals(end);
                eval(['allcal.',handles.allcellnames{cellcounter},'.',handles.alltrialnames{handles.trialcounter},'=struc;']);
            end
        end
        handles.trialcounter=handles.trialcounter+1;
    end

    allcal.Stats.AllPercentDecreases(end+1:end+length(PercentDecreases))=PercentDecreases;
    allcal.Stats.AllNumPointsToDecreases(end+1:end+length(PercentDecreases))=NumPointsToDecreases;
    allcal.Stats.AllSlopeofDecreases(end+1:end+length(PercentDecreases))=SlopeofDecreases;
    allcal.Stats.AllSignalIntegrals(end+1:end+length(PercentDecreases))=SignalIntegrals;
    
    allcal.Stats.ByCellPercentDecreases(end+1)=mean(PercentDecreases);
    allcal.Stats.ByCellNumPointsToDecreases(end+1)=mean(NumPointsToDecreases);
    allcal.Stats.ByCellSlopeofDecreases(end+1)=mean(SlopeofDecreases);
    allcal.Stats.ByCellSignalIntegrals(end+1)=mean(SignalIntegrals);

    %keep range of signals... 
    %make cellcounter mean signal with a range
end
handles.allcal=allcal;
close(handles.fig);
