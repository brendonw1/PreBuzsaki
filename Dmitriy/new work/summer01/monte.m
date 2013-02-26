function monte = monte(num,maxt)
%monte = monte(num,maxt)
%   creates a Monte-Carlo spike train with num spikes, that is maxt data points long

monte = sort(fix(rand(1,num)*maxt)+1);