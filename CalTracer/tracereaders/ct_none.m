function [tr, trhalo, param] = epo_none_(expirement)
% Program used by epo.
% Does not read traces
param = [];
tr = zeros(length(experiment.regions.contours),0);
trhalo = [];