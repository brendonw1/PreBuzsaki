function [onsets, offsets, params] = ...
    ct_risingfaces(rastermap, handles, ridxs, clustered_contour_ids, options)

% [onsets offsets] = detectspikesintegrals(rastermap)


%% Gather some parameters and set some variables
%NEED TO ADJUST THESE INTEGRAL CONSTANTS BY time!!
%RATIO OF WIDTH TO HEIGHT... MEANHEIGHT/NUMSECS TO GET RID OF TALL NARROW
%FALSE POSITIVES... MAYBE IN SMOOTHED SIGNAL... maybe easier just min duration
% diffintegralthreshconsthi = .025;
% diffintegralthreshconstlo = .008;

% diffintegraltimessdhi = 10;
% diffintegraltimessdlo = 3;


numcells = size(rastermap,1);
numframes = size(rastermap,2);
fps = handles.exp.fs;
framedur = 1/fps;
%below 3 for subtracting a baseline
% lagtime = .300;%(sec)
% lagframes = round(lagtime/framedur);%number of frames
% baselineframes = 5;

diffintegralthreshconstlo = options.RiseIntegralHardThreshLo.value;
diffintegraltimessdlo = options.RiseIntegralTimesNoise.value;
basicfiltlen = round(fps*options.BasicFiltLenInSec.value);

params.RiseIntegralHardThreshLo = options.RiseIntegralHardThreshLo.value;
params.RiseIntegralTimesNoise = options.RiseIntegralTimesNoise.value;
params.BasicFiltLenInSec = options.BasicFiltLenInSec.value;


% %% 
% %% Noise: first find the region w/ least SD, define that as the baseline
% %% region
% if numframes<100;%divide up traces into segments with at least 10 frames each
%     numnoisedivs = floor(numframes/10);
%     framesperdiv = 10;
% else%if long enough make into 10 total segments
%     numnoisedivs = 10;
%     framesperdiv = floor(numframes/numnoisedivs);
% end
% noiseraster = rastermap(:,1:end-(mod(numframes,numnoisedivs)));
% noiseraster = reshape(rastermap,[numcells numframes/numnoisedivs numnoisedivs]);
% sdnoise = mean(std(noiseraster,1,2),1);%mean of SDs of cells per division 
% [sdnoise,noisearea] = min(sdnoise);%find the min of those and record which div that was
% noiseframes = ((noisearea-1)*framesperdiv+1):(noisearea*framesperdiv);%take
%     %that division as the baseline division


%% get noise per cell based on how many pixels in each cell assumes median
%% of cell noises represents silent cells
noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);
%%



onsets = {};
offsets = {};

%% Go through each cell and analyze the signals in a few ways for both
%% noise and signal readings
for cidx = 1:numcells
%% Preprocessing for later    
    sig = rastermap(cidx,:);%signal
%     figure;plot(sig)
    if basicfiltlen > 1;
        smoothsig(cidx,:) = filtfilt(1/basicfiltlen*ones(1,basicfiltlen),1,sig);%smoothed so can look for peaks
    else
        smoothsig(cidx,:) = sig;
    end   
%     baseline = filtfilt(1/baselineframes*ones(1,baselineframes),1,sig);
%     baseline=[zeros(1,lagframes),baseline(1:end-lagframes)];
%     nobasesig(cidx,:) = sig-baseline;%sig w/ baseline of value lagframes ago removed
%     nobasesig(cidx,:) = sig;%unchanged

%% Find areas of monotonic increase and calculate the total increase over
%% them
    diffsig(cidx,:) = diff(smoothsig(cidx,:));
    [diffup{cidx},diffdown{cidx}] = ct_continuousabove(diffsig(cidx,:),...
        zeros(size(diffsig(cidx,:))),0,1,inf);
    %diffup is potential signal-related rises, diffdown is downward - noise
    
    %find which of those up periods is in region to be used to measure noise
%     afterstart = diffup{cidx}(:,1)>noiseframes(1);
%     beforestop = diffup{cidx}(:,2)<noiseframes(end);
%     noiseup = afterstart.*beforestop;
    
    % measure actual amount of rise
    for uidx = 1:size(diffup{cidx},1);
        diffintegrals{cidx}(uidx) = sum(diffsig(cidx,(diffup{cidx}(uidx,1):...
            diffup{cidx}(uidx,2))));
    end

%% Find thresholds based on downward transients
% 
%     noisediffintegrals{cidx} = [];%initiate noise matrix for each cell
%     % measure amount of fall, for noise
%     for didx = 1:size(diffdown{cidx},1);
%         noisediffintegrals{cidx}(didx) = -sum(diffsig(cidx,(diffdown{cidx}(didx,1):...
%             diffdown{cidx}(didx,2))));
%     end
% 
%     % calculate threshold based on noise times constants specified above
% %     diffintegralsnoisehi =  mean(noisediffintegrals{cidx})+...
% %         (diffintegraltimessdhi*std(noisediffintegrals{cidx}));
%     diffintegralsnoiselo =  mean(noisediffintegrals{cidx})+...
%         (diffintegraltimessdlo*std(noisediffintegrals{cidx}));
% 
%     %take more stringent of above vs absolute thresh's set at beginning
% %     diffintegralthreshhi = max([diffintegralthreshconsthi,diffintegralsnoisehi]);
%     diffintegralthreshlo = max([diffintegralthreshconstlo,diffintegralsnoiselo]);    
%     
%% Find thresholds based on number of pixels-based noise
    noisethiscell = mean(smoothsig(cidx,:))+noisepercell(cidx)*diffintegraltimessdlo;%mean + XSD
    diffintegralthreshlo = max([diffintegralthreshconstlo,noisethiscell]);%thresh for cell

%% Find epochs above each threshold    
    %adjust diffthresh percell... add a minimum if cell is really noisy
%     diffidxshi = find(diffintegrals{cidx}>diffintegralthreshhi);
%     diffstartstopshi = diffup{cidx}(diffidxshi,:);
%     diffstartstopshi(:,2) = diffstartstopshi(:,2)+1;
%     diffstartshi = diffstartstopshi(:,1);
%     diffstopshi = diffstartstopshi(:,2);
    
    diffidxslo = find(diffintegrals{cidx}>diffintegralthreshlo);
%     diffidxslo(ismember(diffidxslo,diffidxshi))=[];
    diffstartstopslo = diffup{cidx}(diffidxslo,:);
    diffstartstopslo(:,2) = diffstartstopslo(:,2)+1;
    diffstartslo = diffstartstopslo(:,1);
    diffstopslo = diffstartstopslo(:,2);
    
    if ~isempty(diffstartslo);
        onsets{cidx} = diffstartslo;
        offsets{cidx} = diffstopslo;
    elseif isempty(diffstartslo);
        onsets{cidx}=[];
        offsets{cidx}=[];
    end    
end


%%
function noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);

contours = handles.exp.contourLines(clustered_contour_ids);
midx = 1;
nx = handles.exp.tcImage(midx).nX;
ny = handles.exp.tcImage(midx).nY;
contourpixels = cell(1,numcells);
pixpercell = zeros(1,numcells);

h = waitbar(0, 'Calculating masks from contours.  Please wait.');

for cidx = 1:numcells    
    %%%%INSIDE LOOP... GET RID OF LOOP?
    waitbar(cidx/numcells);
    ps = round(contours{cidx});
    [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
			   min(ps(:,2)):max(ps(:,2)));
    inp = inpolygon(subx, suby, ...
		    contours{cidx}(:,1), ...
		    contours{cidx}(:,2));
    cidxx = subx(inp == 1);
    cidxy = suby(inp == 1);
    
    outsideim=cidxx<1|cidxx>nx;%find x-axis components that are less than 1
    cidxx(outsideim)=[];%delete them 
    cidxy(outsideim)=[];%and the y coords for the corresponding points
    outsideim=cidxy<1|cidxy>ny;    %repeat with y's that are too low
    cidxx(outsideim)=[];
    cidxy(outsideim)=[];
    
    contourpixels{cidx} = sub2ind([nx ny], cidxx, cidxy);% contour masks
    pixpercell(cidx) = length(contourpixels{cidx});
    %indices in image.
    %cidx{c} = sub2ind(size(image), cidxy, cidxx);% contour indices in image.
end
close(h);

% stdpercell = std(smoothsig(cidx,:),1,2);
stdpercell = std(rastermap,1,2);
% figure;
% subplot(5,1,1);
% plot(pixpercell,stdpercell,'.');
% subplot(5,1,5);
% plot(pixpercell,stdpercell,'.');

noiseconst = stdpercell'.*pixpercell.^.5;
% subplot(5,1,2);
% plot(pixpercell,noiseconst,'.');
% subplot(5,1,4);
% plot(pixpercell,noiseconst,'.');
% hold
% plot([min(pixpercell) max(pixpercell)],[median(noiseconst) median(noiseconst)],'r')
% subplot(5,1,3);
% hold on;
numbins = 1+3.332*log10(length(noiseconst));%Sturge's Rule
% hist(noiseconst,numbins);
[y,x]=hist(noiseconst,numbins);%
noiseconst = median(noiseconst);
% plot([noiseconst noiseconst],[0 max(y)],'r');

%other ways of getting central tendency possible 
%1) bin and take value of max bin
%2) bin then max of cubic spline-interpolated bin fcn
% [y,x]=hist(noiseconst,numbins);%
% xx = 0:.1:max(noiseconst)+1;
% yy = spline(x,y,xx);
% plot(xx,yy,'r')
%3) remove outliers in systematic and iterative way

noiseconst = noiseconst*ones(size(stdpercell));
noisepercell = noiseconst'./(pixpercell.^0.5);%derive a noise expected for each cell, based on num of pixels
% subplot(5,1,5);
% hold on;
% plot(pixpercell,noisepercell,'.','color','r')
