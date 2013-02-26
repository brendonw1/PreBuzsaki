function [trainlist,spontlist,tslist]=pairwisecompareups(upstates,abfnotes);

warning off MATLAB:divideByZero
trainlist={};
spontlist={};
tslist={};
for a=1:size(upstates,1);%for every slice
    trainemp=zeros(size(abfnotes{a}.stim,1),size(upstates,3));%establish an empty matrix
    spontemp=zeros(size(abfnotes{a}.stim,1),size(upstates,3));%same
    for aa=1:size(abfnotes{a}.stim,1);%look across all notes for that slice
        for aaa=1:size(upstates,3);%for each cell
            if strcmp(abfnotes{a}.stim{aa},'tstrain');
                if ~isempty(upstates{a,aa,aaa});
                    trainemp(aa,aaa,1:size(upstates{a,aa,aaa},1))=1;%record how many upstates in each file
                end
            elseif strcmp(abfnotes{a}.stim{aa},'spont');
                if ~isempty(upstates{a,aa,aaa});
                    spontemp(aa,aaa,1:size(upstates{a,aa,aaa},1))=1;%record how many upstates in each file
                end
            end
        end  
    end
    trainemp2=sum(sum(trainemp,3),1);%find how many upstates per cell
    spontemp2=sum(sum(spontemp,3),1);
    for c=1:size(upstates,3);%for each cell
        trainfilenames=[];
        spontfilenames=[];
        if trainemp2(c)>2;%if more than one upstate was found for that cell
            trainind=nchoosek(1:trainemp2(c),2);%index of combos of train ups
            [trainii1,trainii2]=find(trainemp(:,c,:));%finding places in the matrix where there are files to be used
            for cc=1:length(trainii1);%for each file to be us.ed... this loop is for saving
                load(abfnotes{a}.abfname{trainii1(cc)});
                chan=channelnames(header);
                if c==1;
                    for ch=1:length(chan);
                        if strcmp('IN 5',chan(ch)) | strcmp('IN 11',chan(ch));
                            reading=ch;
                        end
                    end
                elseif c==2;
                    for ch=1:length(chan);
                        if strcmp('IN 10',chan(ch)) | strcmp('IN 7',chan(ch));
                            reading=ch;
                        end
                    end                    
                elseif c==3;
                    for ch=1:length(chan);
                        if strcmp('IN 14',chan(ch)) | strcmp('IN 15',chan(ch));
                            reading=ch;
                        end
                    end                    
                end
                up=upstates{a,trainii1(cc),c}(trainii2(cc),:);%get starts and stops of this upstate
                start=max([up(1)-1000 1]);%start either 100ms before the upstate, or if not space, start at start of the trace
                stop=min([up(4)+1000 size(data,1)]);%start at 100ms after upstate, or if not space, start at end of the trace
                uptrace=data(start:stop,reading);%extract piece of reading
                uptrace=decimatebymean(uptrace,10);%decimate data to 1 point per millisecond
                uptrace(find(uptrace>-30))=-30;%trunkate ap's
                trainfilenames{end+1}=['slice',num2str(a),'trainc',num2str(c),'n',num2str(cc)];
                pathname=['c:\Data\Ephys in MATLAB\Final UPs analysis\Correlation\',trainfilenames{end}];
                save(pathname,'uptrace','-ascii');
                clear data
            end%end for each file
            for d=1:size(trainind,1);%for each comparison to be made
                trainlist{end+1,1}=trainfilenames{trainind(d,1)};
                trainlist{end,2}=trainfilenames{trainind(d,2)};
            end%end making list of upstate file names to be compared    
        end%end train part
        if spontemp2(c)>2;%if more than one upstate was found for that cell
            spontind=nchoosek(1:spontemp2(c),2);%index of combos of spont ups
            [spontii1,spontii2]=find(spontemp(:,c,:));
            for cc=1:length(spontii1);%for each file to be us.ed... this loop is for saving
                load(abfnotes{a}.abfname{spontii1(cc)});
                chan=channelnames(header);
                if c==1;
                    for ch=1:length(chan);
                        if strcmp('IN 5',chan(ch)) | strcmp('IN 15',chan(ch));
                            reading=ch;
                        end
                    end
                elseif c==2;
                    for ch=1:length(chan);
                        if strcmp('IN 10',chan(ch)) | strcmp('IN 7',chan(ch));
                            reading=ch;
                        end
                    end                    
                elseif c==3;
                    for ch=1:length(chan);
                        if strcmp('IN 14',chan(ch));
                            reading=ch;
                        end
                    end                    
                end
                up=upstates{a,spontii1(cc),c}(spontii2(cc),:);%get starts and stops of this upstate
                uptrace=data((up(1)-1000):(up(4)+1000),reading);%extract piece of reading
                uptrace=decimatebymean(uptrace,10);%decimate data to 1 point per millisecond
                uptrace(find(uptrace>-30))=-30;%trunkate ap's
                spontfilenames{end+1}=['slice',num2str(a),'spontc',num2str(c),'n',num2str(cc)];
                pathname=['c:\Data\Ephys in MATLAB\Final UPs analysis\Correlation\',spontfilenames{end}];
                save(pathname,'uptrace','-ascii');
                clear data
            end%end for each file
            for d=1:size(spontind,1);%for each comparison to be made
                spontlist{end+1,1}=spontfilenames{spontind(d,1)};
                spontlist{end,2}=spontfilenames{spontind(d,2)};
            end%end making list of upstate file names to be compared
        end%end spont part
        if trainemp2(c)>2 & spontemp2(c)>2;
            tsind=[];
            for i1=1:spontemp2(c);%for each spont up
                for i2=1:spontemp2(c);%for each spont up
                    tsind(end+1,:)=[i1 i2];%make a comparison
                end
            end
            for d=1:size(tsind,1);%for each comparison to be made
                tslist{end+1,1}=trainfilenames{tsind(d,1)};
                tslist{end,2}=spontfilenames{tsind(d,2)};
            end%end making list of upstate file names to be compared
        end%end if
    end%end each cell
end%end each slice