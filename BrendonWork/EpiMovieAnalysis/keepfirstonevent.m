function ons=keepfirstonevent(ons);
%Eliminates anytime a cell that does not come on in consecutive frames...
%ie if a cell is on then off then on again, it eliminates the 2nd on again.
%It keeps the first event, even if that includes consecutive frames of "on"
%in a row.

a=diff(ons,1);%find on/off events
a(end+1,1)=0;%add a frame of zeros to make this the same length as ons
a=(a==-1);%find all "off" events, set them equal to 1... a matrix of offs now

a=cumsum(a);%all on events
a=a>0;%tells you all points at or after first off event
a(end,:)=0;
a=circshift(a,1);%past two steps were to shift all points down by one frame... so that we can find all points after first off, not including first off
% b=b.*aaa;%keep only ons that are after the first off

ons(a)=0;
