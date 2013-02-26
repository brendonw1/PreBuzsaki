function [stn, decpt] = hippodettrial2(x)

stp = fix(rand*50)+20;
stn = stp:stp:size(x,2)-stp;
decpt = stn+10;