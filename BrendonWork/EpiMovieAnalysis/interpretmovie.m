function sorted=interpretmovie(moviecell)
% moviecell has a row for each slice, each row has 4 columns:
% -ons
% -movienotes
% -lengths
% -contours
% this program will rearrange things so that each slice is broken into
% different types of movies depending on their stimprotocol:
% tstrain - generated while stimulating thalamus multiple times
% tssingle - generated while stimulating thalamus once
% spont - movies made with no thalamic stim, of two types
%     look - just take a movie and hope it picks up some activity
%     wdnostim - after patching, start a movie when a window discriminator detects a spike (or sufficent depolarization)
% wdsingle - like wdnostim, but also stimulate thalamus once as the movie is intiated
% wdtrains - like wdnostim, but also stimulate thalamus many times as the movie is initated
%     Each slice is represented (in the output cell "sorted") as a cell array with subheadings: 
%     *Groups of movies, which will actually be structures inside the larger structure (within the cell)
%     -tstrain
%     -tssingle
%     -spont
%     -look
%     -wdnostim
%     -wdsingle
%     -wdtrain
%     *General info/data about the slice at hand
%     -age
%     -gender
%     -weight
%     -thickness
%     -temperature
%     -loading
%     -other
%     -contours
%     -image
% Inside tstrain, tssingle, spont, look, wdnostim, wdsingle, wdtrain for each slice, will be data regarding 
% each individual movie (again these will be structures inside the larger structure for each slice).  They will include:
% -ons (1's and 0's across cells and frames...1 if cell was on in that frame, 0 if not)
% -moviename
% -abfname
% -stimprotocol
% -stimnum
% -stimamp
% -stimfreq
% -timesincelast
% -otherdescrip
% -observations
%%%%%later will probably want to add atfs to this (electrophys data)
sorted={};
for a=1:size(moviecell,1);%for each slice
    stimtype=moviecell{a,2}.stimprotocol;%making it easier to work with this info
    dflengths=moviecell{a,3}-1;%making it easier to work with this info
    movies={};%a cell which will hold all the movies for a particular slice, broken up
    sorted{a}.contours=moviecell{a,4};
%     sorted{a}.image=
    sorted{a}.age=moviecell{a,2}.age{1};
    sorted{a}.gender=moviecell{a,2}.gender{1};
    sorted{a}.weight=moviecell{a,2}.weight{1};
    sorted{a}.thickness=moviecell{a,2}.thickness{1};
    sorted{a}.temparature=moviecell{a,2}.temperature{1};
    sorted{a}.loading=moviecell{a,2}.loading{1};    
    sorted{a}.other=moviecell{a,2}.other{1};
    for b=1:length(dflengths)%each movie
        lastframe=sum(dflengths(1:b));
        firstframe=lastframe-(dflengths(b)-1);
        movieons{b}=moviecell{a,1}(firstframe:lastframe,:);%a new cell array of ts movies from this slice
        tsfind(b)=strcmp(stimtype(b),'TS');%find movies which were Thalam Stim protocol
        lf1(b)=strcmp(stimtype(b),'LOOK');%find movies where LOOK protocol
        lf2(b)=strcmp(stimtype(b),'SCOPE');%find movies where SCOPE protocol
        lf3(b)=strcmp(stimtype(b),'scope');%find movies where scope protocol
        wdfind(b)=strcmp(stimtype(b),'WD');%find movies where WD protocol
    end
    lookfind=lf1+lf2+lf3;%"LOOK" and "SCOPE" and "scope" are equivalent
    dcounter=0;
    ddcounter=0;
    ecounter=0;
    ffcounter=0;
    fffcounter=0;
    fcounter=0;
    sorted{a}.tstrain=[];
    sorted{a}.tssingle=[];
    sorted{a}.look=[];
    sorted{a}.wdsingle=[];
    sorted{a}.wdtrain=[];
    sorted{a}.wdnostim=[];
    sorted{a}.spont=[];    
    for d=1:size(movieons,2);%each movie
        numstims=0;
        if ~isempty(moviecell{a,2}.stimnum{d});
            if ischar(moviecell{a,2}.stimnum{d});
                numstims=str2num(moviecell{a,2}.stimnum{d});%extracts how many stimuli were given by thalamic stim
            end
        end
        if tsfind(d)==1%if a thalamic stim movie
            if numstims>1;%and multiple stimuli were given
                dcounter=dcounter+1;
                sorted{a}.tstrain(dcounter).ons=movieons{d};
                sorted{a}.tstrain(dcounter).index=d;
                sorted{a}.tstrain(dcounter).moviename=moviecell{a,2}.moviename{d};
                sorted{a}.tstrain(dcounter).abfname=moviecell{a,2}.abfname{d};
                sorted{a}.tstrain(dcounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
                sorted{a}.tstrain(dcounter).stimnum=moviecell{a,2}.stimnum{d};
                sorted{a}.tstrain(dcounter).stimamp=moviecell{a,2}.stimamp{d};
                sorted{a}.tstrain(dcounter).stimfreq=moviecell{a,2}.stimfreq{d};
                sorted{a}.tstrain(dcounter).timesincelast=moviecell{a,2}.timesincelast{d};
                sorted{a}.tstrain(dcounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
                sorted{a}.tstrain(dcounter).observation=moviecell{a,2}.observation{d};
%                 sorted(a).tstrainons{dcounter}=movieons{d};%put movie into a structure array of ts movieons from slice "a"     
%                 sorted(a).tstrainindex(dcounter)=d;%saves the original index number of each movie in the whole series 
                %EVENTUALLY ADD ELECTOPHYS DATA
            end    
        end
        if tsfind(d)==1&numstims==1;
             ddcounter=ddcounter+1;
             sorted{a}.tssingle(ddcounter).ons=movieons{d};
             sorted{a}.tssingle(ddcounter).index=d;
             sorted{a}.tssingle(ddcounter).moviename=moviecell{a,2}.moviename{d};
             sorted{a}.tssingle(ddcounter).abfname=moviecell{a,2}.abfname{d};
             sorted{a}.tssingle(ddcounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
             sorted{a}.tssingle(ddcounter).stimnum=moviecell{a,2}.stimnum{d};
             sorted{a}.tssingle(ddcounter).stimamp=moviecell{a,2}.stimamp{d};
             sorted{a}.tssingle(ddcounter).stimfreq=moviecell{a,2}.stimfreq{d};
             sorted{a}.tssingle(ddcounter).timesincelast=moviecell{a,2}.timesincelast{d};
             sorted{a}.tssingle(ddcounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
             sorted{a}.tssingle(ddcounter).observation=moviecell{a,2}.observation{d};
%              sorted(a).tssingleons{ddcounter}=movieons{d};
%              sorted(a).tssingleindex(ddcounter)=d;%saves the original index number of each movie in the whole series
        end    
        if lookfind(d)==1;
            ecounter=ecounter+1;
            sorted{a}.look(ecounter).ons=movieons{d};
            sorted{a}.look(ecounter).index=d;
            sorted{a}.look(ecounter).moviename=moviecell{a,2}.moviename{d};
            sorted{a}.look(ecounter).abfname=moviecell{a,2}.abfname{d};
            sorted{a}.look(ecounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
            sorted{a}.look(ecounter).stimnum=moviecell{a,2}.stimnum{d};
            sorted{a}.look(ecounter).stimamp=moviecell{a,2}.stimamp{d};
            sorted{a}.look(ecounter).stimfreq=moviecell{a,2}.stimfreq{d};
            sorted{a}.look(ecounter).timesincelast=moviecell{a,2}.timesincelast{d};
            sorted{a}.look(ecounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
            sorted{a}.look(ecounter).observation=moviecell{a,2}.observation{d};
%             sorted(a).lookons{ecounter}=movieons{d};%a cell array of look movieons from slice a
%             sorted(a).lookindex(ecounter)=d;%saves the original index number of each movie in the whole series    
        end
        if wdfind(d)==1;
            stimornot=0;
            if ~isempty(moviecell{a,2}.stimnum{d});
                if ~isempty(str2num(moviecell{a,2}.stimnum{d}));%will give an empty value if the entry was not the text version of a number... will continue if was a text version of a number
                    if moviecell{a,2}.stimnum{d}>0;
                        stimornot=str2num(moviecell{a,2}.stimamp{d});%the value of the amplitude of a shock if any...
                    %will serve as a test for whether the WD triggered a stim or not
                    end
                end
            end    
            if stimornot>0;
                stimnum=str2num(moviecell{a,2}.stimnum{d});
                if stimnum==1;
                    ffcounter=ffcounter+1;
                    sorted{a}.wdsingle(ffcounter).ons=movieons{d};
                    sorted{a}.wdsingle(ffcounter).index=d;
                    sorted{a}.wdsingle(ffcounter).moviename=moviecell{a,2}.moviename{d};
                    sorted{a}.wdsingle(ffcounter).abfname=moviecell{a,2}.abfname{d};
                    sorted{a}.wdsingle(ffcounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
                    sorted{a}.wdsingle(ffcounter).stimnum=moviecell{a,2}.stimnum{d};
                    sorted{a}.wdsingle(ffcounter).stimamp=moviecell{a,2}.stimamp{d};
                    sorted{a}.wdsingle(ffcounter).stimfreq=moviecell{a,2}.stimfreq{d};
                    sorted{a}.wdsingle(ffcounter).timesincelast=moviecell{a,2}.timesincelast{d};
                    sorted{a}.wdsingle(ffcounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
                    sorted{a}.wdsingle(ffcounter).observation=moviecell{a,2}.observation{d};
%                     sorted(a).wdsingleons{ffcounter}=movieons{d};%a cell array of wdstim movieons from slice a
%                     sorted(a).wdsingleindex(ffcounter)=d;%saves the original index number of each movie in the whole series    
                end
                if stimnum>1;
                    fffcounter=fffcounter+1;
                    sorted{a}.wdtrain(fffcounter).ons=movieons{d};
                    sorted{a}.wdtrain(fffcounter).index=d;
                    sorted{a}.wdtrain(fffcounter).moviename=moviecell{a,2}.moviename{d};
                    sorted{a}.wdtrain(fffcounter).abfname=moviecell{a,2}.abfname{d};
                    sorted{a}.wdtrain(fffcounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
                    sorted{a}.wdtrain(fffcounter).stimnum=moviecell{a,2}.stimnum{d};
                    sorted{a}.wdtrain(fffcounter).stimamp=moviecell{a,2}.stimamp{d};
                    sorted{a}.wdtrain(fffcounter).stimfreq=moviecell{a,2}.stimfreq{d};
                    sorted{a}.wdtrain(fffcounter).timesincelast=moviecell{a,2}.timesincelast{d};
                    sorted{a}.wdtrain(fffcounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
                    sorted{a}.wdtrain(fffcounter).observation=moviecell{a,2}.observation{d};                
%                     sorted(a).wdtrainons{fffcounter}=movieons{d};
%                     sorted(a).wdtrainindex(fffcounter)=d;
                end
            end
            if stimornot==0;    
                fcounter=fcounter+1;
                sorted{a}.wdnostim(fcounter).ons=movieons{d};
                sorted{a}.wdnostim(fcounter).index=d;
                sorted{a}.wdnostim(fcounter).moviename=moviecell{a,2}.moviename{d};
                sorted{a}.wdnostim(fcounter).abfname=moviecell{a,2}.abfname{d};
                sorted{a}.wdnostim(fcounter).stimprotocol=moviecell{a,2}.stimprotocol{d};
                sorted{a}.wdnostim(fcounter).stimnum=moviecell{a,2}.stimnum{d};
                sorted{a}.wdnostim(fcounter).stimamp=moviecell{a,2}.stimamp{d};
                sorted{a}.wdnostim(fcounter).stimfreq=moviecell{a,2}.stimfreq{d};
                sorted{a}.wdnostim(fcounter).timesincelast=moviecell{a,2}.timesincelast{d};
                sorted{a}.wdnostim(fcounter).otherdescrip=moviecell{a,2}.otherdescrip{d};
                sorted{a}.wdnostim(fcounter).observation=moviecell{a,2}.observation{d};         
%                 sorted(a).wdnostimons(fcounter)=movieons(d);%a cell array of plain wd movieons from slice a
%                 sorted(a).wdnostimindex(fcounter)=d;%saves the original index number of each movie in the whole series    
            end  
        end
    end
    %%%%output is ts, look, wd, wdstim.... matrices with 4 different
    %%%%types of movies.  Also tsrecord, lookrecord, wdrecord,
    %%%%wdstimrecord... which give numbers from original movie sequence
    %%%%represented in ts, look, wd, wdstim.
    if ~isempty(sorted{a}.look) & ~isempty(sorted{a}.wdnostim);
        for gg=1:size(sorted{a}.look,2);
            spontind(gg)=sorted{a}.look(gg).index;
        end
        for ggg=1:size(sorted{a}.wdnostim,2);
            spontind(ggg+size(sorted{a}.look,2))=sorted{a}.wdnostim(ggg).index;
        end
        spontind=sort(spontind);
        for g=1:size(spontind,2);
            sorted{a}.spont(g).index=spontind(g);
            sorted{a}.spont(g).ons = movieons{spontind(g)};%making a category called "spont" by combining "wd" and "look"
            sorted{a}.spont(g).moviename=moviecell{a,2}.moviename{spontind(g)};
            sorted{a}.spont(g).abfname=moviecell{a,2}.abfname{spontind(g)};
            sorted{a}.spont(g).stimprotocol=moviecell{a,2}.stimprotocol{spontind(g)};
            sorted{a}.spont(g).stimnum=moviecell{a,2}.stimnum{spontind(g)};
            sorted{a}.spont(g).stimamp=moviecell{a,2}.stimamp{spontind(g)};
            sorted{a}.spont(g).stimfreq=moviecell{a,2}.stimfreq{spontind(g)};
            sorted{a}.spont(g).timesincelast=moviecell{a,2}.timesincelast{spontind(g)};
            sorted{a}.spont(g).otherdescrip=moviecell{a,2}.otherdescrip{spontind(g)};
            sorted{a}.spont(g).observation=moviecell{a,2}.observation{spontind(g)};         
        end
    end
    if ~isempty(sorted{a}.look) & isempty(sorted{a}.wdnostim);
        for h=1:size(sorted{a}.look,2);
            sorted{a}.spont(h).index=sorted{a}.look(h).index;
            sorted{a}.spont(h).ons=sorted{a}.look(h).ons;
            sorted{a}.spont(h).moviename=moviecell{a,2}.moviename{sorted{a}.look(h).index};
            sorted{a}.spont(h).abfname=moviecell{a,2}.abfname{sorted{a}.look(h).index};
            sorted{a}.spont(h).stimprotocol=moviecell{a,2}.stimprotocol{sorted{a}.look(h).index};
            sorted{a}.spont(h).stimnum=moviecell{a,2}.stimnum{sorted{a}.look(h).index};
            sorted{a}.spont(h).stimamp=moviecell{a,2}.stimamp{sorted{a}.look(h).index};
            sorted{a}.spont(h).stimfreq=moviecell{a,2}.stimfreq{sorted{a}.look(h).index};
            sorted{a}.spont(h).timesincelast=moviecell{a,2}.timesincelast{sorted{a}.look(h).index};
            sorted{a}.spont(h).otherdescrip=moviecell{a,2}.otherdescrip{sorted{a}.look(h).index};
            sorted{a}.spont(h).observation=moviecell{a,2}.observation{sorted{a}.look(h).index};  
        end
    end
    if isempty(sorted{a}.look) & ~isempty(sorted{a}.wdnostim);
        for hh=1:size(sorted{a}.wdnostim,2);
            sorted{a}.spont(hh).index=sorted{a}.wdnostim(hh).index;
            sorted{a}.spont(hh).ons=sorted{a}.wdnostim(hh).ons;
            sorted{a}.spont(hh).moviename=moviecell{a,2}.moviename{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).abfname=moviecell{a,2}.abfname{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).stimprotocol=moviecell{a,2}.stimprotocol{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).stimnum=moviecell{a,2}.stimnum{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).stimamp=moviecell{a,2}.stimamp{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).stimfreq=moviecell{a,2}.stimfreq{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).timesincelast=moviecell{a,2}.timesincelast{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).otherdescrip=moviecell{a,2}.otherdescrip{sorted{a}.wdnostim(hh).index};
            sorted{a}.spont(hh).observation=moviecell{a,2}.observation{sorted{a}.wdnostim(hh).index};  
        end
        %%%% spont is all movieons that were either look or wd type... spont
            %%%% record corresponds
    end
    clear tsfind lookfind wdfind movieons spontind
end