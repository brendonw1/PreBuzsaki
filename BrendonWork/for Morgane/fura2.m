function cov=fura2(signal,framelength)
% function [onsets,offsets]=fura2(signal,framelength)
%specific to detecting signals with oregon green-bapta.  Framelength is in
%ms. 

framerate=1000/framelength;

filtlength=framerate*12;
lowpass=fir1(30,1/filtlength);%make a 30 frame long filter
trendA=filtfilt(lowpass,sum(lowpass),signal);%lowpass filter to find the trend in the data
signalA=signal./trendA;%divide each point by the local baseline

lowpoints=find(signalA<mean(signalA)-.5*std(signalA));
signalB=signal;
signalB(lowpoints)=trendA(lowpoints);
trendB=filtfilt(lowpass,sum(lowpass),signalB);%lowpass filter to find the trend in the data
signalC=signal./trendB;%divide each point by the local baseline
% 
% figure
% plot(signalC);
% hold on;
% % plot(1+5*noise*ones(length(signalC)),'r')
% % plot(1.009*ones(length(signalC)),'g')
noise=std(signalC(find(signalC<1)));

cov=noise;

thresh=min([.91 1-5*noise]);

plot(thresh*ones(size(signalC)),'c')
plot((1-noise)*ones(size(signalC)),'r')
% aboveperiods=continuousabove(signalC,zeros(size(signalC)),thresh,1,Inf);%find all areas of the trace that are at least 1 point long that are at least "thesh" in amplitude
% 
% if ~isempty(aboveperiods);
%     onsets=aboveperiods(:,1);
%     offsets=aboveperiods(:,2);
% else
%     onsets=[];
%     offsets=[];
% end


function aboveperiods=continuousabove(data,baseline,abovethresh,mintime,maxtime);
% Finds periods in a linear trace that are above some baseline by some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.
above=find(data>=baseline+abovethresh);
if max(diff(diff(above)))==0 & length(above)>=mintime & length(above)<=maxtime;%if only 1 potential upstate found
    aboveperiods = [above(1) above(end)];
elseif length(above)>0;%if many possible upstates
	ends=find(diff(above)~=1);%find breaks between potential upstates
    ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
    ends(end+1)=length(above);%one of the ends comes at the last found point above baseline
    ends=sort(ends);
    lengths=diff(ends);%length of each potential upstate
    good=find(lengths>=mintime & lengths<=maxtime);%must be longer than 500ms but shorter than 15sec
    ends(1)=[];%lose the 0 added before
    e3=reshape(above(ends(good)),[length(good) 1]);
    l3=reshape(lengths(good)-1,[length(good) 1]);
    aboveperiods(:,2)=e3;%upstate ends according to the averaged reading
    aboveperiods(:,1)=e3-l3;%upstate beginnings according to averaged reading
else
    aboveperiods=[];
end