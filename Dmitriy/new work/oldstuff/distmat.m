function distmat = distmat(fid,phases,trials,durat,q)
%function [distmat,nspk,ncond] = distmat(fid,phases,trials,durat,q)
%[distmat,nspk,ncond] = distmat(fid,phases,trials,durat,q)
%  Reads in a t-list file fid and outputs distance matrix
%  Phases specifies the list of conditions to analyze
%  Trials specifies the number of trials to analyze
%  First durat milliseconds are used
%  q gives the list of cost parameters for the metric

%fid = [ondesk fid];
%fid = ['\\westside\tlists\l' fid(1:2) '\' fid];
m = getalltimes(fid);
if isempty(phases)
    phases = 1:m.nconds;
end
if isempty(trials)
    trials = min(m.nc);
end
stimes = [];
begtime = [];
endtime = [];
for ph = 1:size(phases,2)
    for tr = 1:trials
        phn = phases(ph);
        adt = m.t(phn,m.st(phn,tr):m.st(phn,tr)+m.spc(phn,tr)-1);
        adt = adt(find(adt <= durat));
        stimes = [stimes adt];
        if isempty(endtime)
            begtime = 1;
        else
            begtime = [begtime endtime(end)+1];
        end
        endtime = [endtime begtime(end)+size(adt,2)-1];
    end
end
nspk = endtime - begtime + 1;
ncond = m.nconds;
for c = 1:size(q,2)
    if size(q,2) == 1
        %distmat = make_square(spkdl(stimes,begtime,endtime,q));
        distmat = spkdl(stimes,begtime,endtime,q);
    else
        distmat{c} = make_square(spkdl(stimes,begtime,endtime,q(c)));
    end
    %fprintf(['Parameter q = ' num2str(q(c)) ' calculated\n']);
end