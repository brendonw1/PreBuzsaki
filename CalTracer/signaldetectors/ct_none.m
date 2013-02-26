function [onsets, offsets, param] = ct_None_(fname,region)
onsets = cell(1,length(region.contours));
offsets = cell(1,length(region.contours));
param = [];