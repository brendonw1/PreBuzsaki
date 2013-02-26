epo('inputimage',targetsimage);
h=0;
while ~h
	h=findobj('Type','figure');
end
waitfor(h);
close(gcf);

try%if contours is a current variable
	for a=1:length(CONTS)%for each contour
        targets(a,:)=centroid(CONTS{a});%get the centroid
	end
catch
    errordlg('Contours were not exported from epo.  Start over.')
end
clear h a CONTS