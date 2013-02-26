function moviecell = InteractionGatherMovies %#ok<STOUT>

try
    path = 'D:\Exchange\Analyses\Interaction Project\For Neuron 7-07\';
    [trash1,trash2,info] = xlsread([path,'MoviesSheetNewOct07Only.xls']);
catch
    path = 'E:\Current Lab\SpontStim Movies\';
    [trash1,trash2,info] = xlsread([path,'MoviesSheetNewOct07Only.xls']);
end
try
    paqpath = 'D:\Exchange\Analyses\Interaction Project\For Neuron 7-07\SpontStim Ephys\';
catch
    paqpath = 'E:\Current Lab\SpontStim Ephys\';
end


midx = 0;
for idx = 2:size(info,1);
    disp(['*Line ' num2str(idx)])
    if ~isnan(info{idx,1})
        sname = info{idx,1};
        midx = midx+1;
    else
        midx = 0;
        continue
    end
    thismovie = info{idx,2};
    prot = info{idx,3};
    interframe = info{idx,4};
    framexy = info{idx,5};
    objective = info{idx,6};
    ephysfile = info{idx,7};
    timesnoise = info{idx,8};
    interactburstnum = info{idx,9};
    interactgood = info{idx,10};
    comment = info{idx,11}; %#ok<NASGU>

    eval(['moviecell.s',sname,'(midx).Name = thismovie;']);
    eval(['moviecell.s',sname,'(midx).Protocol = prot;']);
    eval(['moviecell.s',sname,'(midx).InterFrameTime = interframe;']);
    eval(['moviecell.s',sname,'(midx).FrameXYDim = framexy;']);
    eval(['moviecell.s',sname,'(midx).Objective = objective;']);
    eval(['moviecell.s',sname,'(midx).TimesImagingNoise = timesnoise;']);
    eval(['moviecell.s',sname,'(midx).InteractBurstNum = interactburstnum;']);
    eval(['moviecell.s',sname,'(midx).InteractGood = interactgood;'])
    eval(['moviecell.s',sname,'(midx).Comment = comment;']);
    
    
%% get contours from file next to movie tif file
    conts = load([path,'Interaction Movies 7-07\',sname,'\',thismovie,'_conts']);
    conts = conts.CONTS;
    
    mov = readtifstack([path,'Interaction Movies 7-07\',...
        sname,'\',thismovie,'.tif']);
    if framexy == 512;
       %average quads of pixels in each frame.  Make 256x256
       q1 = mov;
       q1(2:2:end,:,:) = [];
       q1(:,2:2:end,:) = [];
       q2 = mov;
       q2(1:2:end,:,:) = [];
       q2(:,2:2:end,:) = [];
       q3 = mov;
       q3(2:2:end,:,:) = [];
       q3(:,1:2:end,:) = [];
       q4 = mov;
       q4(1:2:end,:,:) = [];
       q4(:,1:2:end,:) = [];
       mov = (q1+q2+q3+q4)/4;
       clear q1 q2 q3 q4
       %shrink conts by 50 to go from 512x512 to 256x256
       for cidx = 1:length(conts)
          conts{cidx} = conts{cidx}/2; 
       end
    end
    eval(['moviecell.s',sname,'(midx).Conts = conts;']);

    
    if interframe == .0279;
        %%average every 4 framess
        s1 = mov(:,:,1:4:end);
        s2 = mov(:,:,2:4:end);
        s3 = mov(:,:,3:4:end);
        s4 = mov(:,:,4:4:end);
        sz = min([size(s1,3),size(s2,3),size(s3,3),size(s4,3)]);
        s1 = s1(:,:,1:sz);
        s2 = s2(:,:,1:sz);
        s3 = s3(:,:,1:sz);
        s4 = s4(:,:,1:sz);
        mov = (s1+s2+s3+s4)/4;
        clear s1 s2 s3 s4
    end

    numframes = size(mov,3);
    movmod = mod(numframes,3);
    mov = mov(:,:,1:(numframes-movmod));%toss out frames past the section divisible by 3 (2 at most)
    finlen = size(mov,3)/3 - 1;%length of the final product movies, after frame averaging
    
    s1 = mov(:,:,1:3:end);%grab every 3 frames 1,4,7...
    s2 = mov(:,:,2:3:end);%grab every 3 frames 2,5,8...
    s3 = mov(:,:,3:3:end);%grab every 3 frames 3,6,9...
    
    %sum groups of consecutive threes to make movies... different groups of
    %3s.  Also write these movies out to file so can be viewed later
    mov1 = s1(:,:,1:finlen) + s2(:,:,1:finlen) + s3(:,:,1:finlen);%1+2+3,4+5+6,...
    mov1 = mov1/3;
%     writetiffstack(mov1,[path,'Interaction Movies 7-07\',...
%         sname,'\',thismovie,'_Mov1.tif']);
    mov2 = s2(:,:,1:finlen) + s3(:,:,1:finlen) + s1(:,:,2:(finlen+1));%2+3+4,5+6+7,...
    mov2 = mov2/3;
%     writetiffstack(mov2,[path,'Interaction Movies 7-07\',...
%         sname,'\',thismovie,'_Mov2.tif']);
    mov3 = s3(:,:,1:finlen) + s1(:,:,2:(finlen+1)) + s2(:,:,2:(finlen+1));%3+4+5,6+7+8,...
    mov3 = mov3/3;
%     writetiffstack(mov3,[path,'Interaction Movies 7-07\',...
%         sname,'\',thismovie,'_Mov3.tif']);
    
    %gather a sliding "bin" of frames... a continuous and non-choppy
    %version of the activity.  Make sure to pass through the
    %keepfirstactive fcn.  Need to keep thinking, should be useful.
    oversampmov = zeros(size(mov,2),size(mov,2),size(mov,3)-2);
    for fidx = 1:(size(mov,3)-2);
        oversampmov(:,:,fidx) = mean(mov(:,:,(fidx:fidx+2)),3);
    end
    oversampmov = uint16(oversampmov);
%     writetiffstack(oversampmov,[path,'Interaction Movies 7-07\',...
%         sname,'\',thismovie,'_Oversamp.tif']);

    
    ons1 = epimovies2(mov1,conts,timesnoise,objective);
    ons2 = epimovies2(mov2,conts,timesnoise,objective);
    ons3 = epimovies2(mov3,conts,timesnoise,objective);
    onsoversamp = epimovies2(oversampmov,conts,timesnoise,objective);
    
    ons1 = keepfirstonframe(ons1); %#ok<NASGU>
    ons2 = keepfirstonframe(ons2); %#ok<NASGU>
    ons3 = keepfirstonframe(ons3); %#ok<NASGU>
    onsoversamp = keepfirstonframe(onsoversamp); %#ok<NASGU>
    
    eval(['moviecell.s',sname,'(midx).Ons1 = ons1;']);
    eval(['moviecell.s',sname,'(midx).Ons2 = ons2;']);
    eval(['moviecell.s',sname,'(midx).Ons3 = ons3;']);
    eval(['moviecell.s',sname,'(midx).OnsOversampled = onsoversamp;']);
    
    if strcmp(prot,'ss') || strcmp(prot,'spontstim')
        if ephysfile
            ephyspath = [paqpath,'\',sname,'\',thismovie,'.paq'];
        else %this only happens once, special case
            ephyspath = 'D:\Exchange\Analyses\Interaction Project\For Neuron 7-07\Interaction Movies 7-07\070410a\070410aSubFor9-Really10.paq';
        end
        eval(['moviecell.s',sname,'(midx).EphysFilePath = ephyspath;']);
        
        paqinfo = paqread(ephyspath,'info');
        for cidx = 1:size(paqinfo.ObjInfo.Channel,2)
            if strcmp(paqinfo.ObjInfo.Channel(cidx).ChannelName,'CameraIntegOut') ||...
                    strcmp(paqinfo.ObjInfo.Channel(cidx).ChannelName,'Frames');
                framechannum = cidx;
            elseif strcmp(paqinfo.ObjInfo.Channel(cidx).ChannelName,'StimCommand') || ...
                strcmp(paqinfo.ObjInfo.Channel(cidx).ChannelName,'StimCmd')
                stimchannum = cidx;
            end       
        end
        stimchandata = paqread(ephyspath,'channels',stimchannum);
        stims = findin62(stimchandata);
        bursts = separatein6(stims,5000);
        
        if interactburstnum == 0
            interact = bursts{end}(1);
        else
            interact = bursts{interactburstnum}(1);
        end
        framechandata = paqread(ephyspath,'channels',framechannum);
        origframes = gethamaframes(framechandata,'lastmovieonly');
        %correct for 36fps movies, group every four frames
        if interframe == .0279;
            if mod(size(origframes,1),4) == 0;
                origframes = [origframes(1:4:end,1) origframes(4:4:end,2)];
            else
                startinds = 1:4:(size(origframes,1));
                origframes = [origframes(startinds(1:end-1),1) origframes(4:4:end,2)];               
            end
        end
        
        mov1framesA = 3*(1:finlen-1)-2;
        mov1framesB = 3*(1:finlen-1);
        mov2framesA = 3*(1:finlen-1)-1;
        mov2framesB = 3*(1:finlen-1)+1;
        mov3framesA = 3*(1:finlen-1);
        mov3framesB = 3*(1:finlen-1)+2;
        mov1framesA(mov1framesA > size(origframes,1)) = [];
        mov1framesB(mov1framesB > size(origframes,1)) = [];
        mov2framesA(mov2framesA > size(origframes,1)) = [];
        mov2framesB(mov2framesB > size(origframes,1)) = [];
        mov3framesA(mov3framesA > size(origframes,1)) = [];
        mov3framesB(mov3framesB > size(origframes,1)) = [];
        m1len = min([length(mov1framesA) length(mov1framesB)]);
        m2len = min([length(mov2framesA) length(mov2framesB)]);
        m3len = min([length(mov3framesA) length(mov3framesB)]);
        mov1framesA = mov1framesA(1:m1len);
        mov1framesB = mov1framesB(1:m1len);
        mov2framesA = mov2framesA(1:m2len);
        mov2framesB = mov2framesB(1:m2len);
        mov3framesA = mov3framesA(1:m3len);
        mov3framesB = mov3framesB(1:m3len);
        
        movoverframesA = 1:size(oversampmov,3)-3;
        movoverframesB = 3:(size(oversampmov,3)-1);
        movoverframesA(movoverframesA > size(origframes,1)) = [];
        movoverframesB(movoverframesB > size(origframes,1)) = [];
        movoverlen = min([length(movoverframesA) length(movoverframesB)]);
        movoverframesA = movoverframesA(1:movoverlen);
        movoverframesB = movoverframesB(1:movoverlen);
        
        mov1frames = [origframes(mov1framesA,1) origframes(mov1framesB,2)];
        mov2frames = [origframes(mov2framesA,1) origframes(mov2framesB,2)];
        mov3frames = [origframes(mov3framesA,1) origframes(mov3framesB,2)];
        movoversampframes = [origframes(movoverframesA,1) origframes(movoverframesB,2)];
        
        mov1interactframe = find(mov1frames(:,1)<interact,1,'last'); %#ok<NASGU>
        mov2interactframe = find(mov2frames(:,1)<interact,1,'last'); %#ok<NASGU>
        mov3interactframe = find(mov3frames(:,1)<interact,1,'last'); %#ok<NASGU>
        movoversampinteractframe = find(movoversampframes(:,1)<interact,1,'last'); %#ok<NASGU>
        
        eval(['moviecell.s',sname,'(midx).OriginalFrameTimes = origframes;']);
        eval(['moviecell.s',sname,'(midx).Movie1FrameTimes = mov1frames;']);
        eval(['moviecell.s',sname,'(midx).Movie2FrameTimes = mov2frames;']);
        eval(['moviecell.s',sname,'(midx).Movie3FrameTimes = mov3frames;']);
        eval(['moviecell.s',sname,'(midx).MovieOversampledFrameTimes = movoversampframes;']);
        eval(['moviecell.s',sname,'(midx).InteractTime = interact;']);        %save interact 
        eval(['moviecell.s',sname,'(midx).Movie1InteractFrame = mov1interactframe;']);
        eval(['moviecell.s',sname,'(midx).Movie2InteractFrame = mov2interactframe;']);
        eval(['moviecell.s',sname,'(midx).Movie3InteractFrame = mov3interactframe;']);
        eval(['moviecell.s',sname,'(midx).MovieOversampledInteractFrame = movoversampinteractframe;']);
    end
end

moviecell = FindMovieUpstates(moviecell); %#ok<NODEF>