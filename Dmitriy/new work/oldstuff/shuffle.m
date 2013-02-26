function shuffle = shuffle(spikes)
%SPIKES = SHUFFLE(SPIKES)
%   Performs shuffle resampling (Victor & Purpura 1996) on a spike train
%   stored in the structure SPIKES. The resampling preserves the set of
%   spike times across trials, but not the number of spikes in individual
%   trials.
%
%   The output is a structure with the same form as the input.
%
%   Dmitriy Aronov, 8/23/2000

for c = 1:spikes.nconds
   ns = spikes.nsp(c);
   mt = [fix(rand(1,ns)*spikes.nc(c))+1; spikes.t(c,1:ns)]';
   mt = sortrows(mt,[1 2])';
   spikes.t(c,1:ns) = mt(2,:);
   spikes.c(c,1:ns) = mt(1,:);
end

shuffle = spikes;