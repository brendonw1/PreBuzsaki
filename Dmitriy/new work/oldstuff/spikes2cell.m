function spikes2cell = spikes2cell(spikes)
%spike2cell(spikes)
%   Takes in a spikes train in structure format and outputs it
%   in a cell array format with the i,j-th entry being a vector
%   of spike times in ith condition's jth trial.

for ph = 1:spikes.nconds
   for tr = 1:spikes.nc(ph)
      begs = spikes.st(ph,tr);
      ends = begs + spikes.spc(ph,tr) - 1;
      sp = spikes.t(ph,begs:ends);
      %sp = sp(find(sp>0));
      spikes2cell{ph,tr} = sp;
   end
end