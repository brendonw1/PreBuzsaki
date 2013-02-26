function brightness=calciumtransient(points,percenttopeak,decaytimeconstant);
% From F. Helmchen chapter in Yuste, Lanni & Konnerth 2005.
% Max amplitude = 1;


% timeperpoint=1/35.8;%frame duration in seconds

% percenttopeak=.3;%percent of timepoints into signal at which 
%     %transition from onset to offset occurs
percenttopeak=round(length(points)*percenttopeak);

onsetpoints=points(1:percenttopeak);
offsetpoints=points(percenttopeak:length(points));
onset=0:(1/length(onsetpoints)):1;%straight line to max point... height = 1

% decaytimeconstant=.9;%decay per time point
offset=decaytimeconstant.^(1:length(offsetpoints));
multfactor=1/offset(1);
offset=offset*multfactor;

brightness=[onset offset(2:end)];