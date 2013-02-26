function exres = exres(spk)
%exres = exres(spk)
%   performs exchange resampling on the set of spike trains

sz = size(spk,2);
ct = cat(2,spk{:});
ct = ct(randperm(size(ct,2)));
sm = 1;
for c = 1:sz
   exres{c} = ct(sm:sm+size(spk{c},2)-1);
   sm = sm + size(spk{c},2);
end