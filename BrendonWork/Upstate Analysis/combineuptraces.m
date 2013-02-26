function uptraces1=combineuptraces(uptraces1,uptraces2);

[num2,address2]=max([size(uptraces1,2) size(uptraces2,2)]);%find which input uptraces has the smaller of each dimension except d1
[num3,address3]=max([size(uptraces1,3) size(uptraces2,3)]);
[num4,address4]=max([size(uptraces1,4) size(uptraces2,4)]);

address2=3-address2;%tells which uptraces has the min value (1 or 2)
address3=3-address3;%tells which uptraces has the min value (1 or 2)
address4=3-address4;%tells which uptraces has the min value (1 or 2)

name2=['uptraces',num2str(address2)];
eval([name2,'(size(',name2,',1),num2,size(',name2,',3),size(',name2,',4)).traces=[];']);%make d2 of the smaller uptraces equal to d2 of the larger, for concatenation
ng2=[name2,'(1).guide'];
eval([ng2,'(size(',ng2,',1),num2,size(',ng2,',3),size(',ng2,',4))=0;']);%similar with the d2 of the guide

name3=['uptraces',num2str(address3)];
eval([name3,'(size(',name3,',1),size(',name3,',2),num3,size(',name3,',4)).traces=[];']);
ng3=[name3,'(1).guide'];
eval([ng3,'(size(',ng3,',1),size(',ng3,',2),num3,size(',ng3,',4))=0;']);

name4=['uptraces',num2str(address4)];
eval([name4,'(size(',name4,',1),size(',name4,',2),size(',name4,',3),num4).traces=[];']);
ng4=[name4,'(1).guide'];
eval([ng4,'(size(',ng4,',1),size(',ng4,',2),size(',ng4,',3),num4)=0;']);

uptraces1(1).guide=cat(1,uptraces1(1).guide,uptraces2(1).guide);%keep guide information all at uptraces(1).guide by concatenating all guide info together at top

uptraces2(1).guide=[];%blank out guide which otherwise might go down low in the matrix... keep clean
uptraces1(end+1:end+size(uptraces2,1),:,:,:)=uptraces2;%concatenate uptraces main bodies... make output called uptraces1 for memory purposes