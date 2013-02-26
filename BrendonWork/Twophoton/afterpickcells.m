eval(['save ',filename,' cn tr'])
[cellrepeats,pickedframes]=getsharedactives(filename,[1 2],'manual');
save filename cn tr cellrepeats pickedframes
pause
picked=cellpicker(cn,find(cellrepeats>1))
save filename cn tr cellrepeats pickedframes picked
pause
centers=cellcenters(cn,picked);

targets=zeros(6,1);
for a=1:size(centers,1);
    temp=complextarget(centers(a,:),4,12);
    targets=cat(2,targets,temp);
end

targets=circshift(targets,[0 -1]);
targets(:,end)=[0.000;0.000;-1.000;1.000;0.000;1.000];%specifying dummy target parameters

targets(3,find(targets(5,:)==1))=5;%set time for stimulation targets to 5ms 
targets(3,find(targets(5,:)==0))=5;%set time for imaging targets to 5ms

targets(4,find(targets(5,:)==1))=100;%set (pockels cell voltage) percentage for stimulation targets to 100%
targets(4,find(targets(5,:)==0))=25;%set (pockels cell voltage) percentage for stimulation targets to 25%

writevnt('ablationtargets',targets);