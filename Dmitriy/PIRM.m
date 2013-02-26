function PIRM

%Analysis program for calculating properties of post-inhibitory rebound 
%Analysis program for calculating properties of post-inhibitory rebound. 
%Program loads data as a text file and analyzes sag voltage, latency, 
%and interspike intervals.
%Program designed by Dr. Jason Maclean and Damian O. Elias.
 
clear all;
clf;
set (gcf,'resize','off');
set (gcf,'position',[100 100 800 600]);
%saves results of analysis 
saveit = uicontrol ('style','pushbutton',...
'string','Save',...
'callback','saveit = 1;',...
'position',[339.3750 101.25 61.5 17.25]);
 
uicontrol ('style','text',...
'string','Calculate',...
'position', [658.5 500.75 100 17.25]);
%picks the type of analysis (ISI,Sag,or Latency)
analysistype = uicontrol ('style','popupmenu',...
'string','Sag Voltage|Latency|ISI',...
'value',1,...
'callback','analyzeit = get (analysistype,''value'');',...
'position',[658.5 404.25 100 100]);
%displays the original data traces
dataplot = axes ('position',[.56738 .052706 .2344 .3006]);
%clears axis
uicontrol('style','pushbutton',...
'position',[585 260 50 15],...
'callback','dataplot (cla)',...
'string','Clear');
%title for data columns
datatitle = uicontrol ('style','text',...
'position',[133.5 195 183 25],...
'string','');
%displays the raw data from analysis
dataresult = uicontrol ('style','text',...
'string','no results selected',...
'position',[133.5 20 183 175]);
%plots results from analysis
axestrace = axes ('position',[.1729 .4131 .6299 .5470]);
%specifies the traces to be displayed and/or highlighted. This array of strings 
% is needed to properly label the tracepick listbox.
tracestrs = {'All','Trace 1','Trace 2','Trace 3','Trace 4','Trace 5','Trace6','Trace 7','Trace 8','Trace 9','Trace 10','Trace 11','Trace 12','Trace 13','Trace 14','Trace 15','Trace 16','Trace 17','Trace 18','Trace 19','Trace 20'};
%picks the traces to plot and/or highlight. If you choose the All option of 
% tracepicks all the traces are displayed in one color. Picking an individual 
% trace cause that trace to be highlighted within the %data set.
tracepick = uicontrol ('style','listbox',...
'string',tracestrs(1:5),...
'value',2,...
'callback','traceplot = 1;',... 
'position',[15 430 70 100]);
%command allows you to save a loaded file as a .mat file
%.mat files load much faster than .txt files. The resulting file name is the 
% same as the original .txt %file but with a .mat extension. This was done below 
% by "subtracting" 4 characters from the inputted %pathname and filename (input by 
% the loadit pushbutton-see below). After subtracting the 4 %characters, .mat was 
% concatenated with the original filename and then saved using this new filename.
saveasmat = uicontrol ('style','pushbutton',...
'string','Save as mat.file',...
'callback','temp=strcat (pathname,filename(1:length(filename)-4),''.mat''); save (temp, ''postinhib'');',...
'position',[15 400 78 15]);
%command allows you to load a .mat file. This significantly speeds up the load 
% time
loadasmat = uicontrol ('style','pushbutton',...
'string','Load mat.file',...
'callback',' [filenamel,pathnamel]=uigetfile(''C:\My Documents\DamJas\*.*'',''Choose File''); load (strcat(pathnamel,filenamel));time = (postinhib(:,1)); traces=postinhib(:,2:end);ntrace = inputdlg (''Enter Number of Traces''); ntrace = str2num(ntrace{1});set (tracepick,''string'',tracestrs (1: ntrace + 1 ));',... 
'position',[15 380 78 15]);
%quits program by breaking all loops and closing the figure window
quitit = uicontrol ('style','pushbutton',...
'callback','quitit = 1;break;close;',...
'string','Quit',...
'position',[678 550 54 15]);
%picks .txt file to be loaded and analyzed. This command takes original data 
% saved as a text file and %converts it to a matlab matrix.
loadit = uicontrol ('style','pushbutton',...
'callback','loadit=1; ',...
'string','Load',...
'position',[15 550 45 15]);
%initializes commands, counters, and matrices
loadit = 0;
quitit = 0;
plotit = 0;
traceplot = 0;
tracepicks = 0;
analyzeit = 0;
datamatrix = [];
%main command loop
while (quitit ==0)
drawnow;
%loads .txt or .atf files and creates postinhib data array
if (loadit == 1)
i=1; %array size counter
%menu to pick file to be loaded
[filename,pathname]=uigetfile('C:\My Documents\DamJas\*.*','Choose File'); 
%dialog box to enter total number of data traces. This sets several program 
% parameters most impotantly %the tracepick menu.
ntrace = inputdlg ('Enter Number of Traces');
ntrace = str2num(ntrace{1});
%generates matrix to insert data array. Increases loading speed substantially 
% (10X fold).
postinhib = zeros(10000,ntrace);
fid =fopen (strcat(pathname,filename)); 
txtline = fgetl(fid); 
txtline = fgetl(fid); 
%sets tracepick listbox menu
set (tracepick,'string',tracestrs (1: ntrace + 1 ));
 
%reads .txt or .atf file line for line
while feof(fid) == 0 %are we done reading the file yet?
txtline = fgetl(fid); %get one line
token = strtok(txtline) ; %get first word of the line
xtest = str2double(token); %see if the word is a number
if isnan(xtest) == 0 %if not throw away the line
onerow = sscanf( txtline, '%f', ntrace *2+1);
postinhib(i,1:(ntrace*2+1)) = onerow';
i = i + 1; 
% figure illustrating ongoing load of .txt or .atf files. This command opens a 
% figure window showing a %rectangle that gets filled as rows are read into the 
% matrix. When the matrix is full the figure %window closes itself. The counter 
% was created by making two rectangles. One rectangle is used as the %border. The 
% other rectangle is a filled rectangle that increases in width as subsequent rows 
% are %read. When all rows are read both rectangles are the same size and the 
window closes itself. 
if mod(i,100)==0 
figure (3);
counterload = figure (3);
clf;
set (counterload,'Resize','off');
set (counterload,'MenuBar','none');
set (counterload,'position',[800 600 200 15]);
rectangle ('Position',[10 10 10000 10]);
set (counterload,'DoubleBuffer','on');
axis off
set(counterload,'name', 'Loading');
rectangle ('Position',[10 10 i 10],'FaceColor','k')
drawnow;
if (i==10000)
close (counterload)
end
end
end 
loadit =0;
drawnow;
end
%defines time and individual traces from postinhib array (see above). This 
% program was designed for %data collected by Axon Instruments P-Clamp 8. Raw data 
% from this program has the following %attributes: %The first column is time, even 
% numbered columns are current pulses, and odd numbered %columns (excluding the 
% first column) are voltage traces. Data collected with different programs may 
%necessitate %changes in this part of the program.
time = (postinhib(:,1));
traces=postinhib(:,2:end);
end
%plots traces
if (traceplot ==1) 
axes(axestrace);
%gets menu value from the tracepick list box.
tracepicks = get (tracepick,'value');
%picks all the C
if (tracepicks ==1)
cla;
 
%Displays all the traces as grey
plot (time,traces,'color',[.4 .4 .4]);
xlabel ('time (seconds)');
ylabel ('voltage');
hold on; 
end
%highlights selected traces C the line and plotting it in red
if (tracepicks >1)
axes (axestrace);
cla;
plot (time,traces,'color',[.4 .4 .4]);
lnw = plot (time,traces(:,tracepicks*2-3),'r',time, traces(:,tracepicks*2-2),'r');
%It proved difficult to set the linewidth parameter when the traces were 
% actually plotted. In order to %thicken the lines of the highlighted trace the 
% linewidth parameter was set following the actual %plotting of the data 
set (lnw,'linewidth',1.5); 
end
drawnow; 
traceplot = 0;
end
%performs Sag analysis (measures amount of depolarization the cell
%exhibits during prolonged hyperpolarizing current injection).
if (analyzeit ==1)
n = 1;
%isolates the section of time that we are interested in. In this case it is the 
% time during which the %cell is hyperpolarized.
limtime = time (450:5400);
%intializes the sagmat matrix
sagmat= [2,ntrace];
while (n<=ntrace)
spectrace =traces (:,n*2-1);
limtrace =spectrace(450:5400);
%finds min voltage
[mini,indmin] = min (limtrace);
%only the max voltage following the minimum is applicable so the following lines 
% of code limit the %points to be analyzed to points after the min voltage has 
% been reached
limlimtrace = limtrace (indmin:end);
%finds max voltage
[maxi,indmax] = max (limlimtrace);
% subtracts max and min voltage to find sag voltage
temp = maxi - mini;
%places all relevant data into the sagmat array
sagmat(2,n) = temp;
sagmat(1,n) = mini;
n = n+1;
end
%plots data and datamatrix
axes(dataplot)
cla;
plot (sagmat(1,:),sagmat(2,:),'r-x');
xlabel ('Voltage');
ylabel ('Sag Voltage');
plotlimmaxx = max(sagmat(1,:))+5;
plotlimminx = min(sagmat(1,:))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(sagmat(2,:))+1;
plotlimminy = min(sagmat(2,:))-1;
ylim ([plotlimminy plotlimmaxy]);
set (dataplot,'xdir','reverse');
%In order to show the raw number calculations of the sag voltage on the user 
% interface, an uneditable %text field (see above), dataresult, was set by turning 
% the sagmat matrix into a string and setting the %string parameter in dataresult 
% with this sagmat string.
set (dataresult,'string',num2str(sagmat'));
set (datatitle, 'String',' Voltage Sag Voltage')
analyzeit = 0;
datamatrix = sagmat';
%sets additional figure (outside of user interface) for export to illustrator 
% file. It proved %difficult to export only part of the user interface. In order 
% to make it possible to export the %plotted data, we had to open a figure outside 
% of the user interface and export this. This part of the %program is regrettably 
% unwieldy and in need of some improvement. The major problem is that the figure 
%flashes on the screen and at times may bog down the program.
figure (2);
plot (sagmat(1,:),sagmat(2,:),'r-x');
xlabel ('Voltage');
ylabel ('Sag Voltage');
plotlimmaxx = max(sagmat(1,:))+5;
plotlimminx = min(sagmat(1,:))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(sagmat(2,:))+1;
plotlimminy = min(sagmat(2,:))-1;
ylim ([plotlimminy plotlimmaxy]);
set (gca,'xdir','reverse');
fig = figure(2);
%hides figure 2
figure(1);
end 
%performs latency analysis (measures time to first spike following
%termination of hyperpolarizing current injection).
if (analyzeit ==2)
n = 1;
%isolates time window that we are interested in. In this case it is time after 
% the hyperpolarizing %current.
limtime = time (5400:end);
limtimeb = limtime (100:end);
latmat= [2,ntrace];
while (n<=ntrace)
spectrace =traces (:,n*2-1);
limtrace =spectrace(5400:end);
%filters (low pass) the data and takes the first derivative of data. 
%The drifting baseline following removal of hyperpolarizing current made it 
% difficult to systematically %detect action potentials. The first derivative 
% allows us to isolate the spikes from the underlying %depolarization. The record 
% is then filtered to remove the spurious high frequency noise. 
[b,a]=butter(3,.1);
fil=filter(b,a,limtrace);
dif=diff(fil);
limdif = dif (100:end);
[maxpap,indap] = max (limdif);
%searches for first spike and finds the corresponding time of that spike
aps = find (limdif>.90 *maxpap);
% creates aps matrix consisting of candidate action potentials.
latency = (limtimeb (aps(1))-limtime(1)) *1000; 
latmat(2,n) = latency;
limtraceb =spectrace(450:5400);
[mini,indmin] = min (limtraceb);
latmat(1,n) = mini;
n = n+1;
end
axes(dataplot)
cla;
%plots data and datamatrix
plot (latmat(1,:),latmat(2,:),'b-x');
xlabel ('Voltage');
ylabel ('Latency');
plotlimmaxx = max(latmat(1,:))+5;
plotlimminx = min(latmat(1,:))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(latmat(2,:))+1;
plotlimminy = min(latmat(2,:))-1;
ylim ([plotlimminy plotlimmaxy]);
set (dataplot,'xdir','reverse');
set (dataresult,'string',num2str(latmat'));
set (datatitle, 'String',' Voltage Latency')
analyzeit = 0;
datamatrix = latmat';
%sets additional figure (outside of user interface) for export to illustrator 
% file.
%see above for details.
figure (2)
plot (latmat(1,:),latmat(2,:),'b-x');
xlabel ('Voltage');
ylabel ('Latency');
plotlimmaxx = max(latmat(1,:))+5;
plotlimminx = min(latmat(1,:))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(latmat(2,:))+1;
plotlimminy = min(latmat(2,:))-1;
ylim ([plotlimminy plotlimmaxy]);
set (gca,'xdir','reverse');
fig = figure(2);
figure(1);
end
%calculation of interspike interval (time between the action potentials)
if (analyzeit ==3); 
count = 1;
maxspikenum =0;
limtime = time (5400:end);
%isolates the time window that we wish to measure (time during which action 
% potentials are generated)
limtimeb = limtime (100:end);
isimat= zeros(27,ntrace);
while (count<=ntrace)
spectrace =traces (:,count*2-1);
limtrace =spectrace(5400:end);
[b,a]=butter(3,.1);
fil=filter(b,a,limtrace);
dif=diff(fil);
limdif = dif (100:end);
[maxpap,indap] = max (limdif);
%sets up array of possible spike indexes
aps = find (limdif>.90 *maxpap);
n = 1;
i=1;
spikenum = [limtimeb(aps(1))];
sizeaps = size (aps);
%The aps matrix may return multiple indices for the same action potential. By 
% isolating only those %indices which are far enough apart to be individual action 
% potentials we can create a spike count %array. (Spikes need to be greater than 
% 2.4 ms apart to be resolved).
while (n<sizeaps(1))
c = 1; 
n = n+1;
%finds true spikes in possible spike array
isidiff = aps(n)-aps(n-1);
%creates spike array
if(isidiff>25)
i = i+1;
spikenum (i) = limtimeb(aps(n));
end 
end
%sets up the spikenumber array size limit
lim = size (spikenum);
sizespikenum = lim(2);
if (sizespikenum>maxspikenum)
maxspikenum = sizespikenum;
end
%caluculates times between spikes (interspike interval) and places values into 
% an array
while (c < lim(2))
isimat (count,c+1) = (spikenum (c+1) - spikenum (c));
c = c+1;
end
limtraceb =spectrace(450:5400);
[mini,indmin] = min (limtraceb);
isimat(count,1) = mini;
count = count+1;
end
%creates final interspike interval array
isimat = isimat(1:ntrace,1:maxspikenum);
%plots data for first interspike interval of each trace 
% axes(dataplot)
cla;
plot (isimat(:,1),isimat(:,2),'g-x');
xlabel ('Voltage');
ylabel ('ISI');
plotlimmaxx = max(isimat(:,1))+5;
plotlimminx = min(isimat(:,1))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(isimat(:,2)+.01);
plotlimminy = min(isimat(:,2))-.01;
ylim ([plotlimminy plotlimmaxy]);
set (dataplot,'xdir','reverse');
set (dataresult,'string',num2str(isimat (:,1:2)));
set (datatitle, 'String',' Voltage ISI')
analyzeit = 0;
datamatrix = isimat;
%sets addtional figure (outside of user interface) for export to illustrator 
% file
figure (2)
plot (isimat(:,1),isimat(:,2),'g-x');
xlabel ('Voltage');
ylabel ('ISI');
plotlimmaxx = max(isimat(:,1))+5;
plotlimminx = min(isimat(:,1))-5;
xlim ([plotlimminx plotlimmaxx]);
plotlimmaxy = max(isimat(:,2)+.01);
plotlimminy = min(isimat(:,2))-.01;
ylim ([plotlimminy plotlimmaxy]);
set (gca,'xdir','reverse');
fig = figure(2);
figure(1); 
end
%saves data analysis as an excel readable file and creates an illustrator file 
% of the data.
if (saveit==1)
[filenameb,pathnameb] = uiputfile('C:\My Documents\DamJas\*.*','Choose File Name'); 
fileid =strcat(pathnameb,filenameb); 
%creates excel file
dlmwrite (fileid,datamatrix,'\t');
figure (1)
%creates illustrator file
print(fig, '-dill', fileid );
saveit = 0;
end
end
if (quitit == 1)
close
close (fig);
break
end
 
 
 
 
 
 
 
 
 
 
 
 