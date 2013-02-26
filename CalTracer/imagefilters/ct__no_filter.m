function [loca, param] = ct__no_filter(experiment, midx,param)
loca = experiment.tcImage(midx).image;
param.status = 'ok';