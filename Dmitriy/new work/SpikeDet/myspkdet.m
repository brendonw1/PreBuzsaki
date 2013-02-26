LoadDefs;
fig = figure('Name','Spike Detection','NumberTitle','off','MenuBar','none','CloseRequestFcn','SpkDetQuit');
set(gcf,'position',[107 99 804 581],'Color',[0 0 0]);

mfile = uimenu('Label','&File');
	uimenu(mfile,'Label','&Open...','Callback','OpenFile');
   uimenu(mfile,'Label','&Save...');
   uimenu(mfile,'Label','E&xit','Separator','on','Callback','SpkDetQuit');
mview = uimenu('Label','&View','Enable','off');
   mvbas = uimenu(mview,'Label','&Baseline','Checked','off','CallBack','ViewBaseline');
   mvcen = uimenu(mview,'Label','&Cell centroid','Checked','off','CallBack','ViewCentroid');
   mvpts = uimenu(mview,'Label','&Data points','Checked','off','Callback','ViewDataPoints');
mtrac = uimenu('Label','&Trace','Enable','off');
   mfilt = uimenu(mtrac,'Label','&Filter');
   msubb = uimenu(mtrac,'Label','&Subtract baseline');
   myaxs = uimenu(mtrac,'Label','&Y-axis');
   	mtrad = uimenu(myaxs,'Label','DF/F...','Checked','on','Callback','n = 1; TraceType');
   	mtraf = uimenu(myaxs,'Label','Fluorescence','Checked','off','Callback','n = 2; TraceType');
msdet = uimenu('Label','&Spike detection','Enable','off');
	mbase = uimenu(msdet,'Label','Set &baseline...');
	
   
slide = uicontrol('Style', 'slider','Units','Normalized','Position', [.05 .025 .75 .025],'Enable','off',...
   'Callback','HowChange = 1; PlotTrace;');
sblev = uicontrol('Style', 'slider','Units','Normalized','Position', [.7825 .0725 .0175 .88],'Enable','off',...
   'Callback','MoveBaseline;');
bback = uicontrol('Style', 'pushbutton', 'String', '<','Units','Normalized','Position', [.86 .86 .02 .03],...
   'Callback','CellNum = CellNum - 1; PlotTrace;','Enable','off','FontWeight','bold');   
bforw = uicontrol('Style', 'pushbutton', 'String', '>','Units','Normalized','Position', [.92 .86 .02 .03],...
   'Callback','CellNum = CellNum + 1; PlotTrace;','Enable','off','FontWeight','bold');
bwbck = uicontrol('Style', 'pushbutton', 'String', '<<','Units','Normalized','Position', [.83 .86 .02 .03],...
   'Callback','CellNum = 1; PlotTrace;','Enable','off','FontWeight','bold');
bwfrw = uicontrol('Style', 'pushbutton', 'String', '>>','Units','Normalized','Position', [.95 .86 .02 .03],...
   'Callback','CellNum = size(Traces,1); PlotTrace;','Enable','off','FontWeight','bold');
ftext = uicontrol('Style', 'text', 'String', 'No traces loaded','Units','Normalized',...
   'Position',[.8 .9 .2 .05],'HorizontalAlignment','center','BackgroundColor',[0 0 0],...
   'ForegroundColor',[1 1 1],'FontSize',12);
atext = uicontrol('Style', 'text', 'String', 'No cells loaded','Units','Normalized',...
   'Position',[.8 .25 .2 .05],'HorizontalAlignment','center','BackgroundColor',[0 0 0],...
   'ForegroundColor',[1 1 1],'FontSize',12);