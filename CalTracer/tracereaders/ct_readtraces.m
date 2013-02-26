function [traces, halo_traces, param] = ct_readtraces(experiment, midx)
% Program used by EPO.
% Reads traces as average fluorescence values inside the contours.
errordlg(['This function has not been kept up.  If you reallly want' ...
	  ' to use it you should make it similar to epo_readtraces_mem.m' ...
	  ' -DCS:2005/08/04.']);
return;	  
fnm = [experiment.tcImage(midx).pathName experiment.tcImage(midx).fileName];
regions = experiment.regions;
contours = experiment.contourLines;
contourslen = length(contours);
%image = experiment.tcImage.image;	%%% not the filtered, right?
nx = experiment.tcImage(midx).nX;
ny = experiment.tcImage(midx).nY;
traces = [];
halo_traces = [];
param = [];
% Try it this way and see if it's faster. (It's fractionally
% faster.)
h = waitbar(0, 'Calculating contour indices in image.  Please wait.');
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
    cidx{c} = sub2ind([nx ny], cidxx, cidxy);% contour indices in image.
end
close(h);
trace_contour_len = length(cidx);
% Calculate the halo intensities, if we so choose.
f = {};
if (experiment.haloMode == 1)
    halos = experiment.halos;
    ff = [];
    for c = 1:contourslen
        ff = [ff; cidx{c}];
    end
    ff = unique(ff);
    
    %%% Setup the halos, but I'm not certain in what way. -DCS:2005/03/21
    for c = 1:contourslen
	%cent = create_centroid(contours{c});
	%cent = handles.exp.centroids(:,c);
        %ct = repmat(cent, size(contours{c},1),1);
        %halos{c} = (contours{c}-ct)*sqrt(1+experiment.haloArea)+ct;
	% The halos are create earlier, right?  Why regenerate them
        % here?
        halos{c}(find(halos{c}(:,1) < 1), 1) = 1;
        halos{c}(find(halos{c}(:,2) < 1), 2) = 1;
        halos{c}(find(halos{c}(:,1) > nx), 1) = nx;
        halos{c}(find(halos{c}(:,2) > ny), 2) = ny;
    end
    h = waitbar(0, 'Calculating halo contour indices in image.  Please wait.');
    for c = 1:contourslen
        waitbar(c/contourslen);
        ps = round(halos{c});
        [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)),min(ps(:,2)):max(ps(:,2)));
        inp = inpolygon(subx,suby,halos{c}(:,1),halos{c}(:,2));
        fx = subx(find(inp==1));
        fy = suby(find(inp==1));
        f{c} = setdiff(sub2ind([nx ny],fx,fy),ff);
    end
    close(h);
    %halo_traces = read_contour_intensities_from_file(fnm, f);
end
%traces = read_contour_intensities_from_file(fnm, cidx);
%halo_traces = read_contour_intensities_from_file(fnm, f);
halo_contour_len = length(f);
all_traces_contours = [cidx f];
all_traces = read_contour_intensities_from_file(fnm, all_traces_contours);
traces = all_traces(1:trace_contour_len,:);
halo_traces = all_traces(trace_contour_len+1:end,:);
function traces = read_contour_intensities_from_file(fullfilename, contours_idx)
% function traces = read_intensities_from_file(fullfilename, contours_idx)
%
% Read the contours from the given fullfilename. Contours_idx is a the
% indices into each frame that you want.
inf = imfinfo(fullfilename);
inflen = length(inf);
contourslen = length(contours_idx);
if strcmp(inf(1).ByteOrder,'little-endian');
    readspec='ieee-le';
elseif strcmp(inf(1).ByteOrder,'big-endian');
    readspec='ieee-be';
end
fid = fopen(fullfilename, 'rb', readspec);
traces = zeros(contourslen, inflen);
h = waitbar(0, 'Reading traces from file.  Please wait.');
for d = 1:inflen
    waitbar(d/inflen);
    for c = 1:contourslen
	cidx = contours_idx{c};
        fseek(fid,inf(d).StripOffsets(1)+2*min(cidx)-2,'bof');
        [im count] = fread(fid,max(cidx)-min(cidx)+1,'*uint16');
        % Average over all pixels that define the contour, per
        % image: intensity/area.
	traces(c,d) = mean(im(cidx-min(cidx)+1)); 
    end
end
close(h);
fclose(fid);