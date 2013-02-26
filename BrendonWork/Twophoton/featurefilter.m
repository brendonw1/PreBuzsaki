% function eventtimes=featurefilter(trace,eventlength,secperframe,filtcutoff,signaldirection,peakplace);
function eventtimes=featurefilter(trace,eventlength,framerate,signaldirection,timesnoise);
% signaldirection=-1;%downward signal

warning off

hpcutoff=2;%seconds... will keep signals only faster than this
lpcutoff=.2;%seconds... will keep signals only slow than this

peakplace=.5;%arbitrary... .2 gives an alpha function with a sharp onset 
        %and a relatively long tail
% timesnoise=1.5;%number of standard devs beyond the mean a signal will be

figure;plot(trace/max(trace));
trace=trace*signaldirection;
[trash,order] = sort(size(trace));
trace=ipermute(trace,order);%make sure the vector is oriented correctly by
    %permuting the dimensions

lt=length(trace);%total number of pints
numfiltpoints=min([30 (length(trace)/3)-1]);
secperframe=1/framerate;
% hpcutoff=hpcutoff*1/secperframe;%how many frames to filter at ten seconds
% hpcutoff=lt/hpcutoff;%how many times an event of this many frames occurs in the total number of frame
% hpcutoff=(hpcutoff)/(lt/2);%normalize by Nyquist frequency (as required my matlab functions)
% lpcutoff=lpcutoff*1/secperframe;%how many frames to filter at ten seconds
% lpcutoff=lt/lpcutoff;%how many times an event of this many frames occurs in the total number of frame
% lpcutoff=(lpcutoff)/(lt/2);%normalize by Nyquist frequency (as required my matlab functions)
% 
% f=fir1(numfiltpoints,[hpcutoff lpcutoff]);%make a bandpass filter
% ftrace=filtfilt(f,1/sum(f),trace);%filter

ftrace = zscore(trace);
ftrace=zscore(ftrace);%normalize
hold on;plot(ftrace/max(ftrace),'r')

% figure;plot(ftrace);
framesperevent=round(eventlength/secperframe);%frames per event
framesperevent=[framesperevent(1):framesperevent(2)];

alldet=zeros(1,length(trace));%prepare for later
for tl = framesperevent;%template length = all values indicated in "framesperevent"
    t=0:(tl-1);%timepoints
    peak=peakplace*length(t);%.2 is arbitrary... it gives a wave with a sharp onset 
        %and a relatively long tail
        
%     searchwave=alphafunc(t,peak);%alpha function evaluated at points t
    searchwave=calciumtransient(t,peak);%alpha function evaluated at points t

    [trash,offset]=max(searchwave,[],2);%find where the max is
    offset=round(offset);%to offset resultant traces by that much
    searchwave = searchwave / max(searchwave);
    
    presize=2;%play with this to adjust for time?... or more worried about noise/variation to determine length
    vdet=myxcorr(searchwave,trace,presize);%cross-covary
    
%     vdet=fliplr(vdet(1:length(trace)));%fix output
%     vdet=zscore(vdet);%normalize
%     vdet=circshift(vdet,[0 offset]);%offset
%     
    vdet2=vdet;
    vdet2(vdet<=0)=eps;
% %     vdet=vdet+vdet2;
    vdet=vdet2;
%     alldet=alldet+vdet;
%     
%     rdet=xcorr(searchwave,trace);%same as above but cross-correlate
%     rdet=fliplr(rdet(1:length(trace)));
%     rdet=zscore(rdet);
%     rdet=circshift(rdet,[0 offset]);
%     alldet=alldet+rdet;
    
% 
%     det=vdet.*rdet.*ftrace;%multiply xcov by xcorr by amplitude
    det=vdet;
%     figure;plot(det);
%     alldet=[alldet ; det];%add such traces from each width of feature
    alldet=det+alldet;%add such traces from each width of feature
end
% alldet = max(alldet);
% hold on;plot(alldet,'g');
hold on;plot(zscore(alldet),'g');
% hold on;plot(alldet/max(alldet),'g');
% hold on;plot(alldet/length(framesperevent),'g');

% sdl=find(alldet<0);%find points below zero
% sdl=[alldet(sdl) - alldet(sdl)];%duplicate them, reflecting about zero
% sdl=std(sdl);%find standard dev... a measure of noise

% look at integrals... take ones with largest integrals
[peakpoints, pareas, abounds, bbounds] = characterizepeaks(alldet);
pheights = alldet(peakpoints);

noise = mean(pheights) + timesnoise*std(pheights(find(pheights<mean(pheights))));
%threshold based on the std of peaks that have below mean value times the
%"timesnoise" variable.

% figure;hist(pheights,100);hold on;plot((mean(pheights)+timesnoise*std(pheights(find(pheights<mean(pheights)))))*[1 1],[0 1],'color','r','linewidth',5)
% sdl = std(alldet);
% sdl = std(alldet(find(alldet<sdl)));
% sdl=timesnoise*sdl;%multiply by an arbitrary amount
% 
eventtimes=continuousabove(alldet,zeros(size(alldet)),noise,max([framesperevent(1) 2]),framesperevent(end)*2);
    % find anything with amplitude greater than the neg amplitude of the 
    % largest downward deflection

%go back and find the corresponding peaks... then, within those peaks find
%the greatest slope in "trace"... then... that defines the beginning... end
%is the end of the peak?  
    
for eidx = 1:size(eventtimes,1);%for each event... go find real start and stop times.
    %%lots of bad assumptions... about where peaks fall etc... need to
    %%clean up, but this works OK
    [trash, thismax] = max(alldet(eventtimes(eidx,1):eventtimes(eidx,2)));
    thismax = thismax + eventtimes(eidx,1) - 1;
    
    bpidx = max(find(bbounds<thismax));%find last upswing before and...
    apidx = min(find(abounds>thismax));%first downswing after this max... may include more than one peak
    thisorigdata = trace(bbounds(bpidx):abounds(apidx));
    slopes = diff(thisorigdata);
    [trash,onidx]=max(slopes);
    onidx = onidx + bbounds(bpidx) - 1;
%     offidx = next trough
    offidx = findtroughs(trace(onidx:end));
    offidx = offidx(1) + onidx -1;
    eventtimes (eidx,:) = [onidx offidx];
end

% figure;plot(alldet);
% % hold on;plot(xlim,[sdl sdl]/max(alldet),':r')
for a=1:size(eventtimes,1);
    ev1=eventtimes(a,1);
    ev2=eventtimes(a,2);
    line([ev1,ev2],[1 1],'color','r','linewidth',10);
end
%     

% lets=['a','b','c','d','e','f','g','h','i','j','k','l','m','n'];
% evl=[.07 .2];tn=6; for let=1:length(lets);eval(['eventtimes=featurefilter(',lets(let),',evl,35,1,tn);']);end

%%
function xcorred = myxcorr (x,y,presize);
% Cross correlates 2 signals.  Each must be a vector.  Slow, but allows
% control over each step... in this case we do a subtraction of the mean of
% a few points just before the data in question.  The size of that region
% before (in points) is the variable presize.

x = x(:);%make multi row, single column vectors
y = y(:);

sx = size(x,1);
sy = size(y,1);

if sx >= sy;
    sig1 = x;%sig1 will be the longer signal by default
    sig2 = y;%sig2 will be shorter
else
    sig1 = y;%sig1 will be the longer signal by default
    sig2 = x;%sig2 will be shorter
end
origs1 = size(sig1,1);
s2 = size(sig2,1);
szpad1 = 2*s2+presize;
szpad2 = s2;
sig1 = padarray(sig1,szpad1,'symmetric','pre');
sig1 = padarray(sig1,szpad2,'symmetric','post');
s1 = size(sig1,1);

for idx = presize+1:(s1-s2);%not including final pad
    sig1seg = sig1(idx:(idx+s2-1));
    preseg = mean(sig1(idx-presize:idx-1));
    sig1seg = sig1seg - preseg;
    xcorred(idx) = sum(sig1seg.*s2);
end
totake = szpad1-round(s2/2);
xcorred(1:totake) = [];
xcorred(origs1+1:end) = [];


function [peakpoints, pareas, abounds, bbounds] = characterizepeaks(data);
% finds peaks, starts & ends of peaks, and their total areas.

peakpoints = findpeaks(data);
troughpoints = findtroughs(data);
zeropoints = find(data<(10^-10));
for pidx = 1:length(peakpoints);
    bt = troughpoints(find(troughpoints<peakpoints(pidx)));
    if isempty(bt)
        bt = 1;
    end
    bt = max(bt);
    bz = zeropoints(find(zeropoints<peakpoints(pidx)));
    if isempty(bz)
        bz = 1;
    end
    bz = max(bz);
    
    at = troughpoints(find(troughpoints>peakpoints(pidx)));
    if isempty(at)
        at = length(data);
    end
    at = min(at);
    az = zeropoints(find(zeropoints>peakpoints(pidx)));
    if isempty(az)
        az = length(data);
    end
    az = min(az);
    
    bbounds(pidx) = max([bt bz]);
    abounds(pidx) = min([at az]);
    pareas(pidx) = sum(data(bbounds(pidx):abounds(pidx)));
end