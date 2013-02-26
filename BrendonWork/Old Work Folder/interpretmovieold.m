function sorted=interpretmovieold(moviecell)

for a=1:size(moviecell,1);%for each slice
    stimtype=moviecell{a,2}.stimprotocol;%making it easier to work with this info
    dflengths=moviecell{a,3}-1;%making it easier to work with this info
    movies={};
    for b=1:length(dflengths)%each movie
        lastframe=sum(dflengths(1:b));
        firstframe=lastframe-(dflengths(b)-1);
        movies{b}=moviecell{a,1}(firstframe:lastframe,:);%a new cell array of ts movies from this slice

        tsfind(b)=strcmp(stimtype(b),'TS');%find movies which were Thalam Stim protocol
        lookfind(b)=strcmp(stimtype(b),'LOOK');
        wdfind(b)=strcmp(stimtype(b),'WD');
% whos
    end
        tstrain={};
        tssingle={};
        spont={};
        look={};
        wd={};
        wdonestim={};
        wdtrain={};
        dcounter=0;
        ddcounter=0;
        ecounter=0;
        fcounter=0;
        ffcounter=0;
        fffcounter=0;
        tstrainrecord=[];
        tssinglerecord=[];
        spontrecord=[];
        lookrecord=[];
        wdrecord=[];
        wdonestimrecord=[];
        wdtrainrecord=[];
        
    for d=1:size(movies,2);%each movie
        numstims=0;
        if ~isempty(moviecell{a,2}.stimnum{d});
            if ischar(moviecell{a,2}.stimnum{d});
                numstims=str2num(moviecell{a,2}.stimnum{d});
            end
        end
        if tsfind(d)==1
            if numstims>1;
                dcounter=dcounter+1;
                tstrain{dcounter}=movies{d};%a cell array of ts movies from slice a     
                tstrainrecord(dcounter)=d;%saves the original index number of each movie in the whole series   
            end    
        end
        if tsfind(d)==1&numstims==1;
             ddcounter=ddcounter+1;
             tssingle{ddcounter}=movies{d};
             tssinglerecord(ddcounter)=d;%saves the original index number of each movie in the whole series
        end    

        if lookfind(d)==1;
            ecounter=ecounter+1;
            look{ecounter}=movies{d};%a cell array of look movies from slice a  
            lookrecord(ecounter)=d;%saves the original index number of each movie in the whole series    
        end
        if wdfind(d)==1;
            stimornot=0;
            if ~isempty(moviecell{a,2}.stimamp{d});
                if ischar(moviecell{a,2}.stimamp{d});
                    stimornot=str2num(moviecell{a,2}.stimamp{d});%the value of the amplitude of a shock if any...
                    %will serve as a test for whether the WD triggered a stim or not
                end
            end    
       
            if stimornot>0;
                stimnum=str2num(moviecell{a,2}.stimnum{d});
                if stimnum==1;
                    ffcounter=ffcounter+1;
                    wdonestim{ffcounter}=movies{d};%a cell array of wdstim movies from slice a
                    wdonestimrecord(ffcounter)=d;%saves the original index number of each movie in the whole series    
                end
                if stimnum>1;
                    fffcounter=fffcounter+1;
                    wdtrain{fffcounter}=movies{d};
                    wdtrainrecord(fffcounter)=d;
                end
            end
            if stimornot==0;    
                fcounter=fcounter+1;
                wd(fcounter)=movies(d);%a cell array of plain wd movies from slice a
                wdrecord(fcounter)=d;%saves the original index number of each movie in the whole series    
            end  
        end
    end
    %%%%output is ts, look, wd, wdstim.... matrices with 4 different
    %%%%types of movies.  Also tsrecord, lookrecord, wdrecord,
    %%%%wdstimrecord... which give numbers from original movie sequence
    %%%%represented in ts, look, wd, wdstim.
    if ~isempty(lookrecord)&~isempty(wdrecord);
        spontrecord=[lookrecord wdrecord];
        spontrecord=sort(spontrecord);
        spont={};
        for g=1:length(spontrecord);
            spont{g} = movies{spontrecord(g)};%making a category called "spont" by combining "wd" and "look"
        end
    end
    if ~isempty(lookrecord)&isempty(wdrecord);
        spontrecord=lookrecord;
        spont=look;
    end
    if ~isempty(wdrecord)&isempty(lookrecord);
        spontrecord=wdrecord;
        spont=wd;
        %%%% spont is all movies that were either look or wd type... spont
            %%%% record corresponds
    end
    if ~isempty(tstrainrecord);
        sorted(a).tstrainons=tstrain;
        sorted(a).tstrainindex=tstrainrecord;
    end 
    if ~isempty(tssinglerecord);
        sorted(a).tssingleons=tssingle;
        sorted(a).tssingleindex=tssinglerecord;
    end
    if ~isempty(spontrecord);
        sorted(a).spontons=spont;
        sorted(a).spontindex=spontrecord;
    end
    if ~isempty(wdonestimrecord);
        sorted(a).wdonestimons=wdonestim;
        sorted(a).wdonestimindex=wdonestimrecord;
    end
    if ~isempty(wdtrainrecord);
        sorted(a).wdtrainons=wdtrain;
        sorted(a).wdtrainindex=wdtrainrecord;
    end
    if ~isempty(wdrecord);
        sorted(a).wdnostimons=wd;
        sorted(a).wdnostimindex=wdrecord;
	end
	if ~isempty(lookrecord);
        sorted(a).lookons=look;
        sorted(a).lookindex=lookrecord;   
    end
    clear tsfind lookfind wdfind
end