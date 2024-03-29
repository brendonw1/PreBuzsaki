function ons=keepfirstonframe(ons)
%eliminates times where cells are on more than frame in a row... keeps only
%the first frame a cell is on and puts zeros in any consecutive frames that
%show the cell is on.  Non-consecutive "on" frames are not changed... Ie
%only if the same cell is "on" many frames in a row.
%Assumes ons is 1's and 0's with the dimensions of frames x cells
a=ons(1:end-1,:)+ons(2:end,:);
a(end+1,1)=0;
a=circshift(a,1);
a=a>1;
ons(find(a))=0;