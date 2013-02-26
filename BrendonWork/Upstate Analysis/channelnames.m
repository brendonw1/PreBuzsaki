function names=channelnames(header)
% function names=channelnames(header,labels);
% This function takes the header file from an imported .atf file (from the
% program import_atf.m).  From this character matrix, it extracts the names
% of all channels in the data set corresponding to this header file.
% Output is the cell aray "names".  1st channel is always called "Time"
% since it is alwayst the same
% totalchannels=size(labels,2)-1;%number of channels in the data file
% corresponding to this
for a=1:length(header)-7;
    start(a)=strcmp('Signals=',header(a:a+7));%find the part of the header file where it says "Signals="
end
start=find(start);%extract the index number of the beginning of this 
labelspart=header(start:end);
for b=1:length(labelspart);
    quotes(b)=strcmp('"',labelspart(b));%find all places where there is a quote in the header file
end%quote 1 in all figures is not important, it comes after the word Signals=
quotes=find(quotes);%find addresses (in labelspart) of all quotation marks
quotes(1)=[];%eliminate the first one (see 2 lines up)
names{1}='Time (10^-5 sec)';
for c=1:length(quotes)/2;%for each pair of quotes
    names{c+1}=labelspart(quotes(c*2-1)+1:quotes(c*2)-1);%the name of the channel is the characters from just after the 1st quote of the pair to just before the 2nd of the pair
end