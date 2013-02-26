function rawread=readnotebook(filename);
%save file as Excel 95 type.  Get rid of "min" on time column.  Find way to
%specify which row numbers to include... ie which movies are included in
%the "pixels" file

% filename=input('Enter name of file to be read: ','s');
% filename=strcat(filename,'.xls');
[num,text]=xlsread(filename);
if ~isempty(num);
    disp ('excel file incorrectly formatted.  Highlight all of file and put all cells in "Text" format.')
    disp ('Next go to every cell which has just a number in it, highlight the text and hit the ENTER key ON THE KEYBOARD section, not the numberpad ENTER');
    disp ('This will fix this class of problem')
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