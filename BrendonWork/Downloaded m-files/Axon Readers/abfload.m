function [d,si,recChNames]=abfload(fn,varargin)
% ** function [d,recChNames,si]=abfload(fn,varargin)
% loads and returns data in the Axon abf format.
% Data may have been acquired in the following modes:
% (1) event-driven variable-length
% (2) event-driven fixed-length 
% (3) gap-free
% Information about scaling, the time base and the number of channels and 
% episodes is extracted from the header of the abf file (see also abfinfo.m).
% All optional input paramters listed below (= all except the file name) 
% must be specified as parameter/value pairs, e.g. as in 
%          d=abfload('d:\data01.abf','start',100,'stop','e');
%
%                    >>> INPUT VARIABLES >>>
%
% NAME        TYPE, DEFAULT      DESCRIPTION
% fn          char array         abf data file name
% start       scalar, 0          only gap-free-data: start of cutout to be read (unit: sec)
% stop        scalar or char,    only gap-free-data: end of cutout to be read (unit: sec). 
%             'e'                 May be set to 'e' (end of file).
% sweeps      1d-array or char,  only episodic data: sweep numbers to be read. By default, 
%             'a'                 all sweeps will be read ('a')
% channels    cell array         names of channels to be read, like {'IN 0','IN 8'};
%              or char, 'a'       ** make sure spelling is 100% correct (including blanks) **
%                                 if set to 'a', all channels will be read
%
%                    <<< OUTPUT VARIABLES <<<
%
% NAME        TYPE            DESCRIPTION
% d                           the data read, the format depending on the recording mode
%             1. GAP-FREE:
%             2d array        2d array of size 
%                              '<data pts>' by '<number of chans>'
%                              Examples of access:
%                              d(:,2)       data from channel 2 at full length
%                              d(1:100,:)   first 100 data points from all channels
%             2. EPISODIC FIXED-LENGTH:
%             3d array        3d array of size 
%                              '<data pts per sweep>' by '<number of chans>' by '<number of sweeps>'
%                              Examples of access:
%                              d(:,2,:)            is a matrix which contains all events (at full length) 
%                                                  of channel 2 in its columns
%                              d(1:200,:,[1 11])   contains first 200 data points of events #1 
%                                                  and #11 of all channels
%             3. EPISODIC VARIABLE-LENGTH:
%             cell array      cell array whose elements correspond to single sweeps. Each element is
%                              a (regular) array of size
%                              '<data pts per sweep>' by '<number of chans>'
%                              Examples of access:
%                              d{1}                 a 2d-array which contains the sweep #1 (all of it, all channels)
%                              d{2}(1:100,2)        a 1d-array containing first 100 data points of of channel 2 in sweep #1
%
% si          scalar          the sampling interval in usec
% recChNames  vector          a list the names of channels that were recorded
%
% (c) H. Hentschke 2004


% future improvements:
% - handle expansion of header in transition to file version 1.65 better
% - gap-free: abfload internally reads data from all channels of the data file if 
%  more than one channel is requested, which wastes enormous amounts of memory. An
%  improved version would repeatedly load chunks of data and split them up,
%  instead of reading all data at once
            
% defaults   
% gap-free
start=0.0;
stop='e';
% episodic
sweeps='a';
channels='a';
verbose=1;

% assign values of optional input parameters, if any were given
pvpmod(varargin);   

% if verbose, disp(['** ' mfilename]); end
d=[]; si=[];
if ischar(stop)
  if ~strcmpi(stop,'e')
    error('input parameter ''stop'' must be specified as ''e'' (=end of recording) or as a scalar');
  end
end

% --- obtain vital header parameters and initialize them with -1 
% temporary initializing var
tmp=repmat(-1,1,16);
% for the sake of typing economy set up a cell array (and convert it to a struct below)
% column order is 
%        name, position in header in bytes, type, value)
headPar={
  'fFileVersionNumber',4,'float',-1;
  'nOperationMode',8,'short',-1; 
  'lActualAcqLength',10,'long',-1;
  'nNumPointsIgnored',14,'short',-1;
  'lActualEpisodes',16,'long',-1;        
  'lFileStartTime',24,'long',-1;
  'lDataSectionPtr',40,'long',-1;
  'lSynchArrayPtr',92,'long',-1;
  'lSynchArraySize',96,'long',-1; 
  'nDataFormat',100,'int',-1;            
  'nADCNumChannels', 120, 'int', -1;
  'fADCSampleInterval',122,'float', -1; 
  'fSynchTimeUnit',130,'float',-1;
  'lNumSamplesPerEpisode',138,'long',-1;        
  'lPreTriggerSamples',142,'long',-1;        
  'lEpisodesPerRun',146,'long',-1; 
  'fADCRange', 244, 'float', -1;
  'lADCResolution', 252, 'long', -1;
  'nFileStartMillisecs', 366, 'short', -1;  
  'nADCPtoLChannelMap', 378, 'int16', tmp;
  'nADCSamplingSeq', 410, 'int16',  tmp;
  'sADCChannelName',442, 'uchar', repmat(tmp,1,10);
  'fADCProgrammableGain', 730, 'float', tmp;
  'fInstrumentScaleFactor', 922, 'float', tmp;
  'fInstrumentOffset', 986, 'float', tmp;
  'fSignalGain', 1050, 'float', tmp;
  'fSignalOffset', 1114, 'float', tmp;
  'nTelegraphEnable',4512,'short',tmp;
  'fTelegraphAdditGain',4576,'float',tmp
};

fields={'name','offs','numType','value'};
s=cell2struct(headPar,fields,2);
numOfParams=size(s,1);
clear tmp headPar;


[pathstr,name,ext,versn] = fileparts(fn);
if isempty(ext);
    fn=[fn '.abf'];
end

if ~exist(fn,'file'), error(['could not find file ' fn]); end
% if verbose, disp(['opening ' fn '..']); end
[fid,messg]=fopen(fn);
if fid == -1,error(messg);end;   
% determine absolute file size
fseek(fid,0,'eof');
fileSz=ftell(fid);
fseek(fid,0,'bof');

% read all vital information in header
% convert names in structure to variables and read value from header
for g=1:numOfParams,
  if fseek(fid, s(g).offs,'bof')~=0, 
    fclose(fid);
    error(['something went wrong locating ' s(g).name]); 
  end;
  sz=length(s(g).value);
  eval(['[' s(g).name ',n]=fread(fid,sz,''' s(g).numType ''');']);
  if n~=sz, 
    fclose(fid);    
    error(['something went wrong reading value(s) for ' s(g).name]); 
  end;
end;

if lActualAcqLength<nADCNumChannels, error('less data points than sampled channels in file'); end;
% the numerical value of all recorded channels (numbers 0..15)
recChIdx=nADCSamplingSeq(1:nADCNumChannels);
% the corresponding indices into loaded data d
recChInd=1:length(recChIdx);
% the channel names, e.g. 'IN 8'
recChNames=[reshape(char(sADCChannelName),10,16)]';
recChNames=recChNames(recChIdx+1,:);

chInd=[];
eflag=0;
if ischar(channels) 
  if strcmp(channels,'a')
    chInd=recChInd;
  else
    fclose(fid);
    error('input parameter ''channels'' must either be a cell array holding channel names or the single character ''a'' (=all channels)');
  end
else
  for i=1:length(channels)
    tmpChInd=strmatch(channels{i},recChNames,'exact');
    if ~isempty(tmpChInd)
      chInd=[chInd tmpChInd];
    else
      % set error flag to 1
      eflag=1;
    end
  end;
end
if eflag
  fclose(fid);
  disp('**** available channels:');
  disp(recChNames);
  disp(' ');
  disp('**** requested channels:');
  disp(strvcat(channels));
  error('at least one of the requested channels does not exist in data file (see above)');
end

% fFileVersionNumber needs a fix - for whatever reason its value is always 
% a little less than what it should be (e.g. 1.6499999xxxx instead of 1.65)
fFileVersionNumber=.001*round(fFileVersionNumber*1000);

% gain of telegraphed instruments, if any
if fFileVersionNumber>=1.65
  addGain=nTelegraphEnable.*fTelegraphAdditGain;
  addGain(addGain==0)=1;
else
  addGain=ones(size(fTelegraphAdditGain));
end

% tell me where the data start
blockSz=512;
switch nDataFormat
  case 0
    dataSz=2;  % bytes/point
    precision='int16';
  case 1
    dataSz=4;  % bytes/point
    precision='float32';
  otherwise
    fclose(fid);
    error('invalid number format');
end;
headOffset=lDataSectionPtr*blockSz+nNumPointsIgnored*dataSz;
% fADCSampleInterval is the TOTAL sampling interval
si=fADCSampleInterval*nADCNumChannels;

if ischar(sweeps) & sweeps=='a'
  nSweeps=lActualEpisodes;
  sweeps=1:lActualEpisodes;
else
  nSweeps=length(sweeps);
end;  

switch nOperationMode
  case 1
%     if verbose, disp('data were acquired in event-driven variable-length mode'); end
    warndlg('function abfload has not yet been thorougly tested for data in event-driven variable-length mode - please double-check that the data loaded is correct','Just a second, please');
    if (lSynchArrayPtr<=0 | lSynchArraySize<=0), error('internal variables ''lSynchArraynnn'' are zero or negative'); end;  
    switch fSynchTimeUnit
      case 0  % time information in synch array section is in terms of ticks
        synchArrTimeBase=1;
      otherwise % time information in synch array section is in terms of usec
        synchArrTimeBase=fSynchTimeUnit;    
    end;  
    % the byte offset at which the SynchArraySection starts
    lSynchArrayPtrByte=blockSz*lSynchArrayPtr;
    % before reading Synch Arr parameters check if file is big enough to hold them
    % 4 bytes/long, 2 values per episode (start and length)
    if lSynchArrayPtrByte+2*4*lSynchArraySize<fileSz, error('file seems not to contain complete Synch Array Section'); end;
    if fseek(fid,lSynchArrayPtrByte,'bof')~=0, error('something went wrong positioning file pointer to Synch Array Section'); end;
    [synchArr,n]=fread(fid,lSynchArraySize*2,'int32');
    if n~=lSynchArraySize*2, error('something went wrong reading synch array section'); end;
    % make synchArr a lSynchArraySize x 2 matrix
    synchArr=permute(reshape(synchArr',2,lSynchArraySize),[2 1]);
    % the length of episodes in sample points
    segLengthInPts=synchArr(:,2)/synchArrTimeBase;
    % the starting ticks of episodes in sample points WITHIN THE DATA FILE
    segStartInPts=cumsum([0 (segLengthInPts(1:end-1))']*dataSz)+headOffset;
    % start time (synchArr(:,1)) has to be divided by nADCNumChannels to get true value
    % go to data portion
    if fseek(fid,headOffset,'bof')~=0, error('something went wrong positioning file pointer (too few data points ?)'); end;
    for i=1:nSweeps,
      % if selected sweeps are to be read, seek correct position
      if ~isequal(nSweeps,lActualEpisodes), 
        fseek(fid,segStartInPts(sweeps(i)),'bof'); 
      end;
      [tmpd,n]=fread(fid,segLengthInPts(sweeps(i)),precision);
      if n~=segLengthInPts(sweeps(i)), 
        warning(['something went wrong reading episode ' int2str(sweeps(i)) ': ' segLengthInPts(sweeps(i)) ' points should have been read, ' num2str(n) ' points actually read']); 
      end;
      dataPtsPerChan=n/nADCNumChannels;
      if rem(n,nADCNumChannels)>0, error('number of data points in episode not OK'); end;
      % separate channels..
      tmpd=reshape(tmpd,nADCNumChannels,dataPtsPerChan);
      % retain only requested channels
      tmpd=tmpd(chInd,:);
      tmpd=tmpd';
      % if data format is integer, scale appropriately; if it's float, tmpd is fine 
      if ~nDataFormat
        for j=1:length(chInd),
          ch=recChIdx(chInd(j))+1;
          tmpd(:,j)=tmpd(:,j)/(fInstrumentScaleFactor(ch)*fSignalGain(ch)*fADCProgrammableGain(ch)*addGain(ch))...
            *fADCRange/lADCResolution+fInstrumentOffset(ch)-fSignalOffset(ch);
        end;
      end
      % now place in cell array, an element consisting of one sweep with channels in columns
      d{i}=tmpd;
    end;  
  case {2,5}
%     if nOperationMode==2, if verbose, disp('data were acquired in event-driven fixed-length mode');  end
%     else 
%       if verbose, disp('data were acquired in waveform fixed-length mode (clampex only)');  end
%     end;
    % determine first point and number of points to be read 
    startPt=0;
    dataPts=lActualAcqLength;
    dataPtsPerChan=dataPts/nADCNumChannels;
    if rem(dataPts,nADCNumChannels)>0, error('number of data points not OK'); end;
    dataPtsPerChanPerSweep=dataPtsPerChan/lActualEpisodes;
    if rem(dataPtsPerChan,lActualEpisodes)>0, error('number of data points not OK'); end;
    dataPtsPerSweep=dataPtsPerChanPerSweep*nADCNumChannels;
    if fseek(fid,startPt*dataSz+headOffset,'bof')~=0, error('something went wrong positioning file pointer (too few data points ?)'); end;
    d=zeros(dataPtsPerChanPerSweep,length(chInd),nSweeps);
    % the starting ticks of episodes in sample points WITHIN THE DATA FILE
    selectedSegStartInPts=[(sweeps-1)*dataPtsPerSweep]*dataSz+headOffset;
    for i=1:nSweeps,
      fseek(fid,selectedSegStartInPts(i),'bof'); 
      [tmpd,n]=fread(fid,dataPtsPerSweep,precision);
      if n~=dataPtsPerSweep, 
        error(['something went wrong reading episode ' int2str(sweeps(i)) ': ' dataPtsPerSweep ' points should have been read, ' num2str(n) ' points actually read']); 
      end;
      dataPtsPerChan=n/nADCNumChannels;
      if rem(n,nADCNumChannels)>0, error('number of data points in episode not OK'); end;
      % separate channels..
      tmpd=reshape(tmpd,nADCNumChannels,dataPtsPerChan);
      % retain only requested channels
      tmpd=tmpd(chInd,:);
      tmpd=tmpd';
      % if data format is integer, scale appropriately; if it's float, d is fine 
      if ~nDataFormat
        for j=1:length(chInd),
          ch=recChIdx(chInd(j))+1;
          tmpd(:,j)=tmpd(:,j)/(fInstrumentScaleFactor(ch)*fSignalGain(ch)*fADCProgrammableGain(ch)*addGain(ch))...
            *fADCRange/lADCResolution+fInstrumentOffset(ch)-fSignalOffset(ch);
        end;
      end
      % now fill 3d array
      d(:,:,i)=tmpd;
    end;  
    
  case 3
%     if verbose, disp('data were acquired in gap-free mode'); end
    % from start, stop, headOffset and fADCSampleInterval calculate first point to be read 
    %  and - unless stop is given as 'e' - number of points
    startPt=floor(1e6*start*(1/fADCSampleInterval));
    % this corrects undesired shifts in the reading frame due to rounding errors in the previous calculation
    startPt=floor(startPt/nADCNumChannels)*nADCNumChannels;
    % if stop is a char array, it can only be 'e' at this point (other values would have 
    % been caught above)
    if ischar(stop),
      dataPtsPerChan=lActualAcqLength/nADCNumChannels-floor(1e6*start/si);
      dataPts=dataPtsPerChan*nADCNumChannels;
    else
      dataPtsPerChan=floor(1e6*(stop-start)*(1/si));
      dataPts=dataPtsPerChan*nADCNumChannels;
      if dataPts<=0 error('start is larger than or equal to stop'); end
    end;
    if rem(dataPts,nADCNumChannels)>0, error('number of data points not OK'); end;
    if fseek(fid,startPt*dataSz+headOffset,'bof')~=0, error('something went wrong positioning file pointer (too few data points ?)'); end;
    % decide on the way to read data:
    % a) one (of more than one) channel requested: use the 'skip' feature of fread
    % b) more than one channels requested: read all channels, purge non-requested ones
    % A (not yet implemented) improved version would read a reasonable chunk of data 
    % (all channels), separate channels, purge non-requested ones, concatenate, repeat until done 
    if length(chInd)==1 & nADCNumChannels>1
      % jump to proper reading frame position in file
      if fseek(fid,(chInd-1)*dataSz,'cof')~=0, error('something went wrong positioning file pointer (too few data points ?)'); end;        
      % read, skipping nADCNumChannels-1 data points after each read
      dataPtsPerChan=dataPts/nADCNumChannels;
      [d,n]=fread(fid,dataPtsPerChan,precision,dataSz*(nADCNumChannels-1));
    else
      [d,n]=fread(fid,dataPts,precision);
      if n~=dataPts, 
        disp(['WARNING: something went wrong reading file (' num2str(dataPts) ' points should have been read, ' num2str(n) ' points actually read']); 
        dataPts=n;
        dataPtsPerChan=dataPts/nADCNumChannels;
      end;
      % separate channels..
      d=reshape(d,nADCNumChannels,dataPtsPerChan);
      % retain only requested channels
      d=d(chInd,:);
      d=d';
    end
    % if data format is integer, scale appropriately; if it's float, d is fine 
    if ~nDataFormat
      for j=1:length(chInd),
        ch=recChIdx(chInd(j))+1;
        d(:,j)=d(:,j)/(fInstrumentScaleFactor(ch)*fSignalGain(ch)*fADCProgrammableGain(ch)*addGain(ch))...
          *fADCRange/lADCResolution+fInstrumentOffset(ch)-fSignalOffset(ch);
      end;
    end
  otherwise
    disp('recording mode of data must be event-driven variable-length (1), event-driven fixed-length (2) or gap-free (3) -- returning empty matrix');
    d=[];
    si=[];
end;
  
fclose(fid);