function plotvectprotocol

[FileName,PathName] = uigetfile('*.tif','Pick an image file');%allow user to pick file containing target information
imf=imfinfo([PathName,FileName]);
if size(imf,2)>1;
    im=inputmovie([PathName,FileName]);
    im=max(im,[],3);
else
    im=imread([PathName,FileName]);%read in the image file
end
figure;
imagesc(im-min(min(im)))
colormap gray

stimtarg=[];%so can use "isempty" test later
imagingtarg=[];%same

[FileName,PathName] = uigetfile('*.vnt','Pick a targets file');%allow user to pick file containing target information
button = questdlg('Include Stimulation targets?');

% s = tdfread([PathName,FileName]);
% fie = fieldnames(s);
% for fidx = 1:length(fie);
%     eval(['t',num2str(fidx),'=s.',fie{fidx},';'])
% end
% prot=[t1 t2 t3 t4 t5 t6];
prot = load([PathName, FileName]);
matrixends = [0; find(prot(:,3)<0)];%vovan apparently appends new data to the end of old data when one 
    %tries to overwrite a file.  Each dataset (targets set) is separated by
    %a line where execution time = 0.  Find these and keep from the
    %second-to-last to the last ones.
prot = prot(matrixends(end-1)+1:matrixends(end)-1,:);
exec=find(prot(:,6));%find targets that were executed
exec=prot(exec,:);%make a new matrix of only those
real=find(exec(:,3)>=0);%find target other than the last "fake" end target
real=exec(real,:);%make a new matrix of only real targets
imagingtarg=find(real(:,5)==0);%find imaging targets
imagingtarg=real(imagingtarg,:);%make a new matrix of only those

if strcmp(button,'Yes');
    stimtarg=find(real(:,5)==1);%find stimulation targets
    stimtarg=real(stimtarg,:);%make a new matrix of only those
end

hold on
for a=1:size(imagingtarg,1);%for each imaging target
    plot(imagingtarg(a,1),imagingtarg(a,2),'.','MarkerSize',5,'color','green');%plot a green point
    text(imagingtarg(a,1),imagingtarg(a,2)+2,num2str(a),'color','green');
end
for a=1:size(stimtarg,1);%for each stimulation target
    plot(stimtarg(a,1),stimtarg(a,2),'.','MarkerSize',5,'color','red');%plot a red point
    text(stimtarg(a,1),stimtarg(a,2)+2,num2str(a),'color','red');
end

if ~isempty(imagingtarg) && ~isempty(stimtarg);
    legend([num2str(size(imagingtarg,1)),' targets, ',num2str(imagingtarg(1,3)),'ms, ',num2str(imagingtarg(1,4)),'% power'],[num2str(size(stimtarg,1)),' targets, ',num2str(stimtarg(1,3)),'ms, ',num2str(stimtarg(1,4)),'% power'])
elseif ~isempty(imagingtarg) && isempty(stimtarg);
    legend([num2str(size(imagingtarg,1)),' targets, ',num2str(imagingtarg(1,3)),'ms, ',num2str(imagingtarg(1,4)),'% power'])
elseif isempty(imagingtarg) && ~isempty(stimtarg);
    legend([num2str(size(stimtarg,1)),' targets, ',num2str(stimtarg(1,3)),'ms, ',num2str(stimtarg(1,4)),'% power'])
end