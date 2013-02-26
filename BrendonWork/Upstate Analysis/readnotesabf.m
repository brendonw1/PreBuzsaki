function abfnotes=readnotesabf(filename);

[num,text]=xlsread(filename);

if ~isempty(num);
    disp ('excel file incorrectly formatted.  Highlight all of file and put all cells in "Text" format.')
    disp ('Next go to every cell which has just a number in it, highlight the text and hit the ENTER key ON THE KEYBOARD section, not the numberpad ENTER');
    disp ('This will fix this class of problem')
end

%if no abfs recorded... all of column one is not used
for a=1:size(text,1);%for each row
    numtest(a)=isempty(num2str(text{a,1}));
    strtest(a)=strcmp(lower(text{a,1}),'ts') | ...
        strcmp(lower(text{a,1}),'tc') | ...
        strcmp(lower(text{a,1}),'wd') | ...
        strcmp(lower(text{a,1}),'scope');% | ...
%         strcmp(lower(text{a,1}(1:3)),'PIR') | ...
%         strcmp(lower(text{a,1}(1:4)),'TRIG');
end
numtest=double(numtest);

if prod(numtest) & sum(strtest)%if none of them were numeric 
        %and at least one matched the known experiment type-specifying strings
    text=[repmat({''},size(text,1),1),text];%add on a column of blank text
        %boxes for the abfnames
end

rawread(:,1).moviename=text(:,3);
rawread(:,1).abfname=text(:,1);
rawread(:,1).stimprotocol=text(:,2);
rawread(:,1).stimnum=text(:,4);%
rawread(:,1).stimfreq=text(:,5);%
rawread(:,1).stimamp=text(:,6);%
rawread(:,1).timesincelast=text(:,7);%
rawread(:,1).otherdescrip=text(:,8);
rawread(:,1).observation=text(:,9);
rawread(:,1).wddelay=text(:,11);
rawread(1,1).age=text(3,13);%
rawread(1,1).gender=text(2,15);
rawread(1,1).temperature=text(2,16);
rawread(1,1).loading=text(3,15);
rawread(1,1).weight=text(2,18);%
rawread(1,1).thickness=text(2,20);%
if size(rawread,2)>=21;
    rawread(1,1).other=text(2,21);
else
    rawread(1,1).other={''};
end

rawread(:,1).originfile=filename;


if size(text,1)>=7;
	rawread(1,1).in5cell=text{5,13};%cell types... interneuron(IN), spiny stellate(SS), pyramidal(PYR)
	rawread(1,1).in10cell=text{6,13};
	rawread(1,1).in14cell=text{7,13};
else
    rawread(1,1).in5cell=[];%cell types... interneuron(IN), spiny stellate(SS), pyramidal(PYR)
	rawread(1,1).in10cell=[];
	rawread(1,1).in14cell=[];
end

abfnotes=rawread;
abfnotes.stim{size(rawread.moviename,1),1}=[];


for a=1:size(rawread.moviename,1);%for each row
%     if ~isempty(rawread.abfname{a});%if there is an abf indicated there
        if strcmp(rawread.stimprotocol{a},'TS') | strcmp(rawread.stimprotocol{a},'TC');%if Thalamic Stimulation protocol and...
            if strcmp(rawread.stimnum{a},'1');%if single stim given
                abfnotes.stim{a,1}='tssingle';%call it tssingle
            elseif ~isempty(rawread.stimnum{a}) & ~isempty(str2num(rawread.stimnum{a}));%or if is a number other than one
                abfnotes.stim{a,1}='tstrain';%call it tstrain
            end
        end
        if strcmp(rawread.stimprotocol{a},'TC');%if Thalamic Stimulation protocol and...
            if strcmp(rawread.stimnum{a},'1');%if single stim given
                abfnotes.stimprotocol{a}='TS';%correct differently-entered note entries
                abfnotes.stim{a,1}='tssingle';%call it tssingle
            elseif ~isempty(rawread.stimnum{a}) & ~isempty(str2num(rawread.stimnum{a}));%or if is a number other than one
                abfnotes.stimprotocol{a}='TS';%correct differently-entered note entries
                abfnotes.stim{a,1}='tstrain';%call it tstrain      
            else
                abfnotes.stimprotocol{a}='TS';%correct differently-entered note entries
            end
        end        
        if strcmp(rawread.stimprotocol{a},'WD');%if Window Discriminator protocol and...
            if strcmp(rawread.stimnum{a},'1');%if single stim given
                abfnotes.stim{a,1}='wdsingle';%call it wdsingle
            elseif ~isempty(rawread.stimnum{a}) & ~isempty(str2num(rawread.stimnum{a}));%or if is a number other than one
                abfnotes.stim{a,1}='wdtrain';%call it wdtrain
            else%or if neither of the above
                abfnotes.stim{a,1}='spont';%call its spont
            end
        end
        if strcmp(rawread.stimprotocol{a},'scope') | strcmp(rawread.stimprotocol{a},'SCOPE');%if scope recording protocol and...
            if strcmp(rawread.stimnum{a},'1');%if single stim given
                abfnotes.stimprotocol{a}='WD';%correct differently-entered note entries
                abfnotes.stim{a,1}='wdsingle';%call it wdsingle
            elseif ~isempty(rawread.stimnum{a}) & ~isempty(str2num(rawread.stimnum{a}));%or if is a number other than one
                abfnotes.stimprotocol{a}='WD';%correct differently-entered note entries
                abfnotes.stim{a,1}='wdtrain';%call it wdtrain
            else%or if neither of the above
                abfnotes.stim{a,1}='spont';%call its spont
            end
        end
    end
end