function spikes=sortspikes(spikes)
%SORTSPIKES Sorts the spikes in each cycle (trial) into ascending order.
%   SPIKES = SORTSPIKES(SPIKES).
%
%   The output is a data structure, SPIKES, with the same form as the input.
%
%   written by Daniel Reich, 1999/01/19

if ~isfield(spikes,'nsp') | ~isfield(spikes,'t') | ~isfield(spikes,'c') | ~isfield(spikes,'nc')
   error('input structure must have fields: nsp, nc, t, c');
end

nconds=length(spikes.nsp);

for i=1:nconds
   for j=1:spikes.nc(i)
      temp=spikes.t(i,find(spikes.c(i,:)==j));
      spikes.t(i,find(spikes.c(i,:)==j))=sort(temp);
   end
end
