function quant=quantifyuptraces(uptraces);

warning off MATLAB:divideByZero

guide=uptraces(1,1,1,1).guide;
allaps=cell(size(guide));

for a=1:size(guide,1);%for every slice
    for b=1:size(guide,2);%for each file
        if sum(sum(guide(a,b,:,:)));%if there is any upstate in this file...
            disp ([num2str(a),' ',num2str(b),' ',uptraces(a,b,1,1).abfname])
            for c=1:size(guide,3);%for each cell
                for d=1:size(guide,4);%for every potential upstate in the file
                    if guide(a,b,c,d);%if an upstate found in that position
                        ups=uptraces(a,b,c,d).ups-(uptraces(a,b,c,d).ups(1)-1);%save info relative to the start of the uptrace in storage
                        trace=uptraces(a,b,c,d).traces;%for easier addressing later
                        allaps{a,b,c,d}=findaps2(trace)+(uptraces(a,b,c,d).ups(1)-1);%placement of ap peaks, relative to the whole record, not just this upstate trace
                        
                        ontau=[trace(ups(1)) trace(ups(2))];%extract offset portion of the trace
                        ontau=-ontau;
                        ontau(find(ontau<=0))=1;
                        ontau=log(ontau);
                        ontau=polyfit([ups(1) ups(2)],ontau,1);
                        ontau=abs(.1/ontau(1));
                        
                        offtau=[trace(ups(3)) trace(ups(4))];%extract offset portion of the trace
                        offtau=-offtau;
                        offtau(find(offtau<=0))=1;
                        offtau=log(offtau);
                        offtau=polyfit([ups(3) ups(4)],offtau,1);
                        offtau=abs(.1/offtau(1));
                        
                        stimname=uptraces(a,b,c,d).stim;
                        if strcmp(stimname,'wdtrain') | strcmp(stimname,'wdsingle');
                            if ~isempty(uptraces(a,b,c,d).wddelay);
                                stimname=strcat(stimname,num2str(uptraces(a,b,c,d).wddelay));
                                temp=separatetrains(uptraces(a,b,c,d).in6,5000);
                                m=0;%clear this from last time
                                if ~isempty(temp{1});%if some in6 found
                                    for e=1:size(temp,2);%for each separate set of stims given
%                                         temp
%                                         temp{e}
                                        m(e)=temp{e}(1)>uptraces(a,b,c,d).ups(2) & temp{e}(1)<uptraces(a,b,c,d).ups(3);%record whether that stim was during an upstate
                                    end
                                end
                                if max(m>0);%if any stims were during an upstate
                                    stimname=strcat(stimname,'in');%indicate that in the name
                                else%if the stim didn't come during the upstate
                                    stimname=strcat(stimname,'out');%indicate that
                                end
                            end
                        end
                        if strcmp(stimname,'wdtrains');
                            stimname='spont';
                        end
                        eval(['lengths.',stimname,'(a,b,c,d)=ups(3)-ups(2);']);
                        eval(['amps.',stimname,'(a,b,c,d)=mean(trace(ups(2):ups(3)))-mean([trace(ups(1)),trace(ups(4))]);']);%mean of upstate minus the value before the upstate
                        if ~isempty(allaps{a,b,c,d});%if any spikes, then fill in the following
                            eval(['apnumber.',stimname,'(a,b,c,d)=size(allaps{a,b,c,d},2);']);%number of spikes found
                            eval(['avgfiring.',stimname,'(a,b,c,d)=size(allaps{a,b,c,d},2)/(ups(3)-ups(2))*10000;']);%number of spikes found/lengths of the upstate
                            if length(allaps{a,b,c,d})>=2;%if at least two spike
                                eval(['minisi.',stimname,'(a,b,c,d)=min(diff(allaps{a,b,c,d}));']);%find the shortest distance between any two aps
                            end
                        end
                        eval(['ontaus.',stimname,'(a,b,c,d)=ontau;']);
                        eval(['offtaus.',stimname,'(a,b,c,d)=offtau;']);
                        eval(['aps.',stimname,'{a,b,c,d}=allaps{a,b,c,d};']);
                    end
                end
            end
        end
    end
end

fnames=fieldnames(lengths);

aps.all=allaps;

lengths.all=zeros(size(guide));
amps.all=zeros(size(guide));
ontaus.all=zeros(size(guide));
offtaus.all=zeros(size(guide));
apnumber.all=zeros(size(guide));
avgfiring.all=zeros(size(guide));
minisi.all=zeros(size(guide));

for a=1:size(fnames,1);
    eval(['if sum(size(lengths.',fnames{a},'))~=sum(size(guide));lengths.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    eval(['lengths.all=lengths.all+lengths.',fnames{a},';'])
    eval(['quant.byfile.lengths.',fnames{a},'=lengths.',fnames{a},';']);
    eval(['quant.bycell.lengths.',fnames{a},'=byfiletobycell(lengths.',fnames{a},');']);
    
    eval(['if sum(size(amps.',fnames{a},'))~=sum(size(guide));amps.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    eval(['amps.all=amps.all+amps.',fnames{a},';'])
    eval(['quant.byfile.amps.',fnames{a},'=amps.',fnames{a},';']);
    eval(['quant.bycell.amps.',fnames{a},'=byfiletobycell(amps.',fnames{a},');']);

    eval(['if sum(size(ontaus.',fnames{a},'))~=sum(size(guide));ontaus.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    eval(['ontaus.all=ontaus.all+ontaus.',fnames{a},';'])
    eval(['quant.byfile.ontaus.',fnames{a},'=ontaus.',fnames{a},';']);
    eval(['quant.bycell.ontaus.',fnames{a},'=byfiletobycell(ontaus.',fnames{a},');']);

    eval(['if sum(size(offtaus.',fnames{a},'))~=sum(size(guide));offtaus.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    eval(['offtaus.all=offtaus.all+offtaus.',fnames{a},';'])
    eval(['quant.byfile.offtaus.',fnames{a},'=offtaus.',fnames{a},';']);
    eval(['quant.bycell.offtaus.',fnames{a},'=byfiletobycell(offtaus.',fnames{a},');']);

    eval(['if sum(size(aps.',fnames{a},'))~=sum(size(guide));aps.',fnames{a},'{size(guide,1),size(guide,2),size(guide,3),size(guide,4)}=[];end'])%note change since aps has a cell array, not numeric, also aps.all was already specified
    eval(['quant.byfile.aps.',fnames{a},'=aps.',fnames{a},';']);
    eval(['quant.bycell.aps.',fnames{a},'=byfiletobycell(aps.',fnames{a},');']);
    
    tfnames=fieldnames(apnumber);
	for b=1:size(tfnames,1);
		m(b)=strcmp(fnames{a},tfnames{b});
	end
    if sum(m)<1;
        eval(['apnumber.',fnames{a},'=zeros(size(guide));']);
    else
        eval(['if sum(size(apnumber.',fnames{a},'))~=sum(size(guide));apnumber.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    end
    eval(['apnumber.all=apnumber.all+apnumber.',fnames{a},';'])
    eval(['quant.byfile.apnumber.',fnames{a},'=apnumber.',fnames{a},';']);
    eval(['quant.bycell.apnumber.',fnames{a},'=byfiletobycell(apnumber.',fnames{a},');']);
    
    tfnames=fieldnames(avgfiring);
	for b=1:size(tfnames,1);
		m(b)=strcmp(fnames{a},tfnames{b});
	end
    if sum(m)<1;
        eval(['avgfiring.',fnames{a},'=zeros(size(guide));']);
    else
        eval(['if sum(size(avgfiring.',fnames{a},'))~=sum(size(guide));avgfiring.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    end
    eval(['avgfiring.all=avgfiring.all+avgfiring.',fnames{a},';'])
    eval(['quant.byfile.avgfiring.',fnames{a},'=avgfiring.',fnames{a},';']);
    eval(['quant.bycell.avgfiring.',fnames{a},'=byfiletobycell(avgfiring.',fnames{a},');']);

    tfnames=fieldnames(minisi);
	for b=1:size(tfnames,1);
		m(b)=strcmp(fnames{a},tfnames{b});
	end
    if sum(m)<1;
        eval(['minisi.',fnames{a},'=zeros(size(guide));']);
    else
        eval(['if sum(size(minisi.',fnames{a},'))~=sum(size(guide));minisi.',fnames{a},'(size(guide,1),size(guide,2),size(guide,3),size(guide,4))=0;end'])
    end    
    eval(['minisi.all=minisi.all+minisi.',fnames{a},';'])
    eval(['quant.byfile.minisi.',fnames{a},'=minisi.',fnames{a},';']);
    eval(['quant.bycell.minisi.',fnames{a},'=byfiletobycell(minisi.',fnames{a},');']);
end