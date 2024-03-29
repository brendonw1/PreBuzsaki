function handles = ct_autocov_signals(handles)
% function handles=detect_signals(handles)
%Evaluates signals in traces using a signal detector from the signal
%detectors folder.  Takes the signal onsets, offset and any signal detector
%programer's parameters, as well as the name of the signal detector used
%and puts them into handles.exp for posterity.
numcells=size(handles.exp.contours,2)
cellnum = handles.appData.currentCellId;
cl = handles.exp.regions.cl;
traces = handles.exp.traces;
halo_traces = handles.exp.haloTraces;
time_res = handles.exp.timeRes;
cridx = handles.exp.contourRegionIdx;
contours = handles.exp.contours;
tidx = 1;
size(traces);
size(halo_traces);
tracetime = time_res*(0:size(traces,2)-1);
max(tracetime);
i = handles.appData.activeCells;    
if (length(i) > 1)
    warndlg(['There are multiple active cells.  Using contour ' num2str(i(1)) '.']);
end
i = i(1);
nidx = find([handles.exp.contours.id] == i);
pidx = handles.appData.currentPartitionIdx;
p = handles.exp.partitions(pidx);
clean_traceA = p.cleanContourTraces(nidx,:);
%i = handles.appData.activeCells-1;    
%nidx = find([handles.exp.contours.id] == i);
cnt = handles.guiOptions.face.cnt;
axes(handles.guiOptions.face.clickMap);
lengthtrace=length(clean_traceA)
stimfreq=1/6;
lengthfreq=ceil((1/time_res)/stimfreq)
nhfilt = 300;		% filter length
hpass = .01;		% high pass in Hz.
Fs = 1/time_res;
normfreq_hpass = hpass/(Fs/2)	% 1 corresponds to Nyquist rate.
hfilt = fir1(nhfilt/2, normfreq_hpass, 'high');
%xfilt = filtfilt(hfilt, 1, x')';
for i=1:numcells,
    nidx = find([handles.exp.contours.id] == i);
    clean_traceA = p.cleanContourTraces(nidx,:);
    clean_traceAautocovA=xcov(clean_traceA,clean_traceA,'coef');
    newautotrace=clean_traceAautocovA(ceil(0.25*length(clean_traceAautocovA)):...
        (length(clean_traceAautocovA)-ceil(0.25*length(clean_traceAautocovA))));
    autotrace=xcov(newautotrace,newautotrace,'coef');
    autotrace = filtfilt(hfilt, 1, autotrace);
    handles.exp.autocovmaxvalues(i)=max(autotrace((lengthtrace+lengthfreq/2):(lengthtrace+lengthfreq+lengthfreq/2)));
    handles.exp.autocovmaxvalues(i)=handles.exp.autocovmaxvalues(i)-...
        min(autotrace((lengthtrace+lengthfreq*1):(lengthtrace+lengthfreq*2)));
    xxx=max(autotrace((lengthtrace+lengthfreq*1+lengthfreq/2):(lengthtrace+lengthfreq*2+lengthfreq/2)));
    xxx=xxx-min(autotrace((lengthtrace+lengthfreq*2):(lengthtrace+lengthfreq*3)));
    yyy=max(autotrace((lengthtrace+lengthfreq*2+lengthfreq/2):(lengthtrace+lengthfreq*3+lengthfreq/2)));
    yyy=yyy-min(autotrace((lengthtrace+lengthfreq*3):(lengthtrace+lengthfreq*4)));
    handles.exp.autocovmaxvalues(i)=(handles.exp.autocovmaxvalues(i)+xxx+yyy)/2;
    %handles.exp.autocovmaxvalues(i)=handles.exp.autocovmaxvalues(i)/2;
        
    
    testing=handles.exp.autocovmaxvalues(i);
   % if (i == handles.appData.activeCells)
   %     handles.exp.covmaxvalues(i)=handles.exp.covmaxvalues(i-1);
   % end;
  %  handles.exp.covmaxvalues(i)=max(clean_traceAcovB((length(clean_traceAc
  %  ovB)-...
  %  length(clean_traceA)-0):(length(clean_traceAcovB)-length(clean_traceA)
  %  +0)));
  
  %covmaxval(i)=handles.exp.covmaxvalues(i);
end;
    newcolor=handles.exp.autocovmaxvalues;
    newcolor(handles.appData.activeCells)=mean(newcolor);
    newcolor=newcolor-min(newcolor)+0.01;
    newcolor=newcolor/(max(newcolor)+0.01);
    newcolor;
for i=1:numcells,
    handles.exp.contours(i).color=[newcolor(i),newcolor(i),newcolor(i)];
    set(cnt(i), 'facecolor', handles.exp.contours(i).color);
end;
%fade = 0.65*ones(1,3)
%handles.exp.contours(i).color
%cnt = handles.guiOptions.face.cnt;
%set(cnt(116), 'facecolor', handles.exp.contours(116).color.*fade);
%covmaxval(116)=-100;
%maxloc=find(covmaxval==max(covmaxval))
%handles.exp