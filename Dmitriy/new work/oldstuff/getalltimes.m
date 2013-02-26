function spikes=getspikestimes(filename)
%GETALLTIMES Read a tlist, spikes conditions, with or without rich information.
%   SPIKES = GETALLTIMES(FILENAME) reads a tlist with a relatively fast
%   algorithm. Since Matlab's file reading capabilities are slow, other than simply
%   loading an array from a file, tlists with rich information must be converted
%   into tlists that contain only spike times and trial/condition delimiters.
%   This conversion is accomplished by the C program strip(), which is invoked
%   first.
%
%   The output structure, SPIKES, contains the following fields:
%		.nconds: total number of stimulus conditions (1x1)
%		.t: spike time (#conds x #spikes)
%		.c: cycle # (starting at 1) (#conds x #spikes)
%		.nsp: number of spikes (#conds)
%		.nc: number of cycles/trials (#conds)
%		.spc: number of spikes in cycle icycle (#conds x #cycles)
%		.st: starting spike # of cycle icycle (#conds x #cycles)
%
%   written by Daniel Reich, 1999/12/11

%   Uncommenting a line in the program will add the following field:
%		.i: spike index (starting at 1) (#conds x #spikes)


%tempn=tempname;
tempn = filename;
%eval(sprintf('!C:\\MATLABR11\\work\\strip %s %s\n',filename,tempn));
adat=load(tempn,'-ascii');
%delete(tempn);

min2=find(adat<-1);
spikes.nconds=length(min2);
min2=[0;find(adat<-1)];
spikes.nsp=diff(min2)';
for icond=1:spikes.nconds
   spind=1;
	spikes.nc(icond)=1+length(find(adat(min2(icond)+1:min2(icond+1))==-1));
   %index=(icond-1)*spikes.nc(icond);
   index=[0 cumsum(spikes.nc)];
   index=index(icond);
   y=[0;find(adat<0)];
   %[spikes.nc(icond) index]
   for icyc=1:spikes.nc(icond)
      spikelist=adat(y(index+icyc)+1:y(index+icyc+1)-1)';
      spikes.spc(icond,icyc)=length(spikelist);
      spikes.st(icond,icyc)=spind;
      spikes.t(icond,spind:spind+spikes.spc(icond,icyc)-1)=spikelist(1:spikes.spc(icond,icyc));
      spikes.c(icond,spind:spind+spikes.spc(icond,icyc)-1)=icyc;
%      spikes.i(icond,spind:spind+spikes.spc(icond,icyc)-1)=1:spikes.spc(icond,icyc)';
      spind=spind+spikes.spc(icond,icyc);
   end
end

% correct for the case of no spikes in the last trial; added 3/11/99
if ~any(spikes.spc(spikes.nconds,:))
   spikes.t(spikes.nconds,1:size(spikes.t,2))=0;
   spikes.c(spikes.nconds,1:size(spikes.t,2))=0;
end

spikes.nsp=spikes.nsp-spikes.nc;