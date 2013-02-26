function DetermineSliceTimesNoise(xlslines,timesnoises)

try
    path = 'D:\Exchange\Analyses\Interaction Project\For Neuron 7-07\';
    [trash1,trash2,info] = xlsread([path,'MoviesSheet.xls']);
catch
    path = 'E:\Current Lab\SpontStim Movies\';
    [trash1,trash2,info] = xlsread([path,'MoviesSheetNewOct07Only.xls']);
end

info = info(xlslines,:);

midx = 0;
for idx = 1:size(info,1);
    disp(['*Line ' num2str(xlslines(idx))])
    if ~isnan(info{idx,1})
        sname = info{idx,1};
        midx = midx+1;
    else
        midx = 0;
        continue
    end
    thismovie = info{idx,2};
    interframe = info{idx,4};
    framexy = info{idx,5};
    objective = info{idx,6};
    
    %% get contours from file next to movie tif file
    try
        conts = load([path,'Interaction Movies 7-07\',sname,'\',thismovie,'_conts']);
    catch
        conts = load([path,sname,'\',thismovie,'_conts']); 
    end
    conts = conts.CONTS;
    
    try
        mov = readtifstack([path,'Interaction Movies 7-07\',...
            sname,'\',thismovie,'.tif']);
    catch
        mov = readtifstack([path,sname,'\',thismovie,'.tif']);
    end
    
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
    for tnidx = 1:length(timesnoises);
        ons1 = epimovies2(mov1,conts,timesnoises(tnidx),objective);
        try
            movieobj = avifile([path,'Interaction Movies 7-07\',...
            sname,'\',thismovie,'TimesNoise',num2str(timesnoises(tnidx)),'_32.avi'],'compression','none');
        catch
            movieobj = avifile([path,...
            sname,'\',thismovie,'TimesNoise',num2str(timesnoises(tnidx)),'_32.avi'],'compression','none');
        end
        
        pixels = double(mov1);
        dffp=-diff(pixels,1,3)./pixels(:,:,1:(end-1));
        f=[];
        for fidx = 1:size(mov1,3)-1;
            f(fidx) = figure('units','pixels','position',[300 300 800 400]);
            subplot(1,2,1);
            imagesc(dffp(:,:,fidx));
            colormap gray
            axis equal
            axis tight
            title(thismovie)
            subplot(1,2,2);
            highlightons(conts,ons1(fidx,:));
            title(['Times Noise = ',num2str(timesnoises(tnidx))])
            movframe = getframe(f(fidx));
            movieobj = addframe(movieobj,movframe);
        end
        movieobj = close(movieobj);
        close(f)
    end
    %%display pairwise frames?
    
end