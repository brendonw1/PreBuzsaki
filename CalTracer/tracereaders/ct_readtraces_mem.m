function [traces, halo_traces, param] = ct_readtraces_mem(experiment, ...
						  midx)
% Program used by CalTrace.
% Reads traces as average fluorescence values inside the contours.

fnm = [experiment.tcImage(midx).pathName experiment.tcImage(midx).fileName];

regions = experiment.regions;
contours = experiment.contourLines;
contourslen = length(contours);
nx = experiment.tcImage(midx).nX;
ny = experiment.tcImage(midx).nY;
traces = [];
halo_traces = [];
param = [];

% Try it this way and see if it's faster. (It's fractionally
% faster.)
% Find pixels in each contour
h = waitbar(0, 'Calculating masks from contours.  Please wait.');
cidx = {};
for c = 1:contourslen    
    waitbar(c/contourslen);
    ps = round(contours{c});
    [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
			   min(ps(:,2)):max(ps(:,2)));
    inp = inpolygon(subx, suby, ...
		    contours{c}(:,1), ...
		    contours{c}(:,2));
    cidxx = subx(find(inp == 1));
    cidxy = suby(find(inp == 1));
    
    outsideim=cidxx<1|cidxx>nx;%find x-axis components that are less than 1
    cidxx(outsideim)=[];%delete them 
    cidxy(outsideim)=[];%and the y coords for the corresponding points
    outsideim=cidxy<1|cidxy>ny;    %repeat with y's that are too low
    cidxx(outsideim)=[];
    cidxy(outsideim)=[];
    
    cidx{c} = sub2ind([nx ny], cidxx, cidxy);% contour masks
    
    %indices in image.
    %cidx{c} = sub2ind(size(image), cidxy, cidxx);% contour indices in image.
end
close(h);
trace_contour_len = length(cidx);

% Find pixels in halos.
f = {};
if (experiment.haloMode == 1)
    halo_borders = experiment.haloBorders;
    h = waitbar(0, 'Calculating halo border masks from contours.  Please wait.');
    for c = 1:contourslen    
        waitbar(c/contourslen);
        ps = round(halo_borders{c});
        [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
                       min(ps(:,2)):max(ps(:,2)));
        if size(subx,1)==1;
            subx=subx';
            suby=suby';
        end
        inp = inpolygon(subx, suby, ...
                halo_borders{c}(:,1), ...
                halo_borders{c}(:,2));
        cidxx = subx(find(inp == 1));
        cidxy = suby(find(inp == 1));

        outsideim=cidxx<1|cidxx>nx;%find x-axis components that are outside image
        cidxx(outsideim)=[];%delete them 
        cidxy(outsideim)=[];%and the y coords for the corresponding points
        outsideim=cidxy<1|cidxy>ny;    %repeat with y's that are outside
        cidxx(outsideim)=[];
        cidxy(outsideim)=[];

        border{c} = sub2ind([nx ny], cidxx, cidxy);% contour indices in image.
    end
    close(h);
    ff = [];
    for c = 1:contourslen
        ff = [ff; border{c}];
    end
    ff = unique(ff);

    % Setup the halos by creating a mask for the halo plus the
    % contour, and then getting rid of any pixels that overlap with
    % tha halo's contour, as well as any other contour.
    halos = experiment.halos;    
    h = waitbar(0, 'Calculating halo masks from contours.  Please wait.');
    for c = 1:contourslen
	waitbar(c/contourslen);
        ps = round(halos{c});
        [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)),min(ps(:,2)):max(ps(:,2)));
        inp = inpolygon(subx,suby,halos{c}(:,1),halos{c}(:,2));
        fx = subx(find(inp==1));%no need to worry about outside range values...
        fy = suby(find(inp==1));%b/c of the direction of the setdiff used below
        
        f{c} = setdiff(sub2ind([nx ny], fx, fy), ff);%create final halo masks
    end
    close(h);
end

% Now we get the traces from the movie.  If the user doesn't want
% halos, we create the data structure anyway so the future application
% doesn't have to consider it.  We fill the halo trace with zeros,
% which makes logical sense because mostly what people will want to do
% is subtract the halo anyways.
if (experiment.haloMode)
    % Put cell and halo contours together so we can speed things up.
    halo_contour_len = length(f);
    all_traces_contours = [cidx f];%cidx is contour pixel masks, f is same for halos
    all_traces = read_contour_intensities_from_mem(fnm, all_traces_contours);
    % Now take them apart.
    traces = all_traces(1:trace_contour_len,:);
    halo_traces = all_traces(trace_contour_len+1:end,:);
else
    all_traces_contours = cidx;
    all_traces = read_contour_intensities_from_mem(fnm, all_traces_contours);
    traces = all_traces;
    [traces_r, traces_c] = size(traces);
    halo_traces = zeros(traces_r, 0);
end
    

function traces = read_contour_intensities_from_mem(fullfilename, contours_idx)
% function traces = read_intensities_from_file(mem, contours_idx)
%
% Read the contours from the given fullfilename. Contours_idx is a the
% indices into each frame that you want.


def = {num2str(1000)};
dlgTitle = 'Working Memory Estimate';
prompt = ['Enter the max number of tiff images to open at once.  This is an estimate of the working memory you have right now.'];
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if (isempty(answer))
    errordlg('You must enter a number.');
end
maxstacksize = str2num(answer{1});

%mem = epo_readtifstack(filename);
%nframes = size(mem,3)
%height = size(mem,1)
%width = size(mem,2)
%%mem = reshape(ipermute(mem, [2 1 3]), height*width, nframes);
%mem = reshape(mem, height*width, nframes);
contourslen = length(contours_idx);   
i=imfinfo(fullfilename);
truestacksize = size(i,2);
traces = zeros(contourslen, truestacksize);
nfilereads = ceil(truestacksize / maxstacksize);
oldlaststackidx = 0;
for i = 1:nfilereads
    [mem, laststackidx, truestacksize] = ...
	ct_readtifstack(fullfilename, ...
			 'outputmode', 'linear', ...
			 'maxstacksize', maxstacksize, ...
			 'startstackidx', oldlaststackidx+1);
    
    nframes = size(mem, 2);
    h = waitbar(0, ...
		['Reading traces from file (' num2str(i) '/' ...
		 num2str(nfilereads) ').  Please wait.']);
    for c = 1:contourslen
        waitbar(c/contourslen);
        cidx = contours_idx{c};
        %fseek(fid,inf(d).StripOffsets(1)+2*min(cidx)-2,'bof');
        %[im count] = fread(fid,max(cidx)-min(cidx)+1,'*uint16');
        % Average over all pixels that define the contour, per
        % image: intensity/area.
        if (length(mem(cidx,:)) == 0)
            traces(c,oldlaststackidx+1:laststackidx) = 0;
        else
            traces(c,oldlaststackidx+1:laststackidx) = mean(mem(cidx,:));
        end
    end    
    oldlaststackidx = laststackidx;    
    clear mem;
%     pack;
    close(h);
end


