function handles = find_overlap(handles)
% function handles = find_overlap(handles)
% Find the contours that are overlapping in the various maps and
% highlight them.  

% The way overlaps are kept track of is with the tags of the 
% objects (and line thickness)(!).  Only the first mask ('movie contours')
% are highlighted or not.  -BW

h = msgbox({'Calculating Overlaps';'(This window will close when finished)'});
nmaps = handles.exp.numMasks;
nregions = handles.exp.numRegions;
cl = hsv(nmaps);

%set up a system to keep track of which movie contour each other contour overlaps with
%always within the same region
handles.exp.contourMaskIdx={};
for ridx = 1:nregions;
    numcontours=length(handles.exp.regions.contours{ridx}{1});
    handles.exp.contourMaskIdx{ridx}=ones(1,numcontours);%default for which mask the 
%         movie contours overlapped with
    for midx = 1:nmaps;
        numcontours = length(handles.exp.regions.contours{ridx}{midx});
        handles.exp.overlapsInfo{ridx}{midx} = zeros(numcontours, 2);
    end
end

% Reset all the overlap information as if it's already happened
% before.  This way the user can keep trying with various overlap %
% values.q
for n = 1:1				% only movie
    for r = 1:nregions
        nmovie_contours = length(handles.exp.regions.contours{r}{n});
        for mc = 1:nmovie_contours
            set(handles.guiOptions.face.handl{r}{n}(mc), ...
            'linewidth', 1, ...
            'Color', cl(n,:));		    
            set(handles.guiOptions.face.handl{r}{n}(mc), ...
            'Tag', '');
        end    
    end
end

% Collect all the contours for a given map.  Compare those contours to
% the contours in the FIRST map.  If the contours overlap then
% highlight them.  In order to optimize this, we can see if the
% centroid is in a certain radius, so that it's not completely N^2.
overlap_pct = str2num(uiget(handles, 'consolidatemaps','txoverlap', 'String'));
overlap_pct = overlap_pct/100;
for n = 2:nmaps
    for r = 1:nregions
        movie_contours = handles.exp.regions.contours{r}{1};
        nmovie_contours = length(handles.exp.regions.contours{r}{1});
        contours = handles.exp.regions.contours{r}{n};
        ncontours = length(handles.exp.regions.contours{r}{n});
%         h = waitbar(0, ['Calculating overlap in region ',num2str(r)]);
        for mc = 1:nmovie_contours
            ps = round(movie_contours{mc});
            [mcmaskx mcmasky] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
                       min(ps(:,2)):max(ps(:,2)));
            for c = 1:ncontours
                pix_in_con = inpolygon(mcmaskx, mcmasky, ...
                               contours{c}(:,1), ...
                               contours{c}(:,2));

                npix_in_con = prod(size(pix_in_con));
                % Set the movie contour with informatoin so that we
                        % can delete it later.  If overlap_pct% of the map
                        % contour is in the movie contour we mark the movie
                        % contour.
                if (length(find(pix_in_con)) > overlap_pct*npix_in_con)%if overlap is great enough
                    set(handles.guiOptions.face.handl{r}{1}(mc), ...%set line thickness
                    'linewidth', 2, ...
                    'Color', cl(1,:));

                    set(handles.guiOptions.face.handl{r}{1}(mc), ...%and change tag...
                    'Tag', 'cellcontour - overlap');
                
                    handles.exp.overlapsInfo{r}{n}(c,:)=[mc r];%which movie contour each contour in a 
                        %region in a mask is overlapped with... default = 0 
                    handles.exp.contourMaskIdx{r}(mc)=n;%record which mask each movie contour overlapped with
                end    
%                 waitbar(mc/nmovie_contours,h);
            end
        end
    end
end


%make a vector ignoring regions for .contourMaskIdx
if length(handles.exp.contourMaskIdx)>1
    new = [];
    for idx = 1:length(handles.exp.contourMaskIdx);
        new = [new handles.exp.contourMaskIdx{idx}];
    end
    handles.exp.contourMaskIdx{1} = new;
end
try %in case user closed it
    close (h)
end
refresh;