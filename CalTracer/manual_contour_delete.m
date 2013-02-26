function handles = manual_contour_delete(handles)
% function handles = manual_contour_delete(handles)
% Delete a contour by selecting it.

handles = uiset(handles,'detectcells','all','enable','off');
handles = uiset(handles,'filterimage','all','enable','off');

ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;

min_area = handles.guiOptions.face.minArea;
max_area = handles.guiOptions.face.maxArea;
%%% Is this right? -DCS:2005/04/04

% point
if (uiget(handles, 'detectcells', 'shaperad1', 'value') == 1)
    x = [];
    y = [];
    [x(1) y(1) butt] = ginput(1);
    newcn = [x y];
else					% random contour.
    nx = [];
    ny = [];
    butt = 1;
    while (butt <= 1)
        [x y butt] = ginput(1);
        nx = [nx; x];
        ny = [ny; y];
        if size(nx,1) == 1
            dummya = plot(nx,ny,'+r');
        else
            set(dummya, ...
                'xdata', nx, ...
                'ydata', ny, ...
                'linestyle',':', ...
                'linewidth', 2, ...
                'marker','none');
        end
    end
    newcn = [nx ny];
    delete(dummya);
end

nregions = handles.exp.numRegions;

if (length(newcn) == 2)			% simple click
    for r = 1:nregions
        didx = 1;
        cn = handles.exp.regions.contours{r}{midx};
        ncontours = length(cn);
        deleted_contours{r} = [];
        for c = 1:ncontours
            if (find(inpolygon(newcn(1), newcn(2), cn{c}(:,1), cn{c}(:,2))))
                deleted_contours{r}(didx) = c;
                didx = didx + 1;
            end
        end
    end
else					% custom region.
    for r = 1:nregions
        didx = 1;
        cn = handles.exp.regions.contours{r}{midx};
        ncontours = length(cn);
        deleted_contours{r} = [];
        for c = 1:ncontours
            ps = round(cn{c});	
            [cmaskx cmasky] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
                           min(ps(:,2)):max(ps(:,2)));
            pix_in_con = inpolygon(cmaskx, cmasky, newcn(:,1), newcn(:,2));
            npix_in_con = size(pix_in_con,1)*size(pix_in_con,2);

            if (length(find(pix_in_con)) > 0.5*npix_in_con)
                deleted_contours{r}(didx) = c;
                didx = didx + 1;
            end
        end
    end
end

% Now put it back together.
for r = 1:nregions
    if (isempty(deleted_contours{r}))
        continue;
    end
    cn = handles.exp.regions.contours{r}{midx};
    ncontours = length(cn);
    saved_contour_idxs = setdiff(1:ncontours, deleted_contours{r});
    nsaved_contours = length(saved_contour_idxs);
    handles.exp.regions.contours{r}{midx} = cell(1,nsaved_contours);
    for c = 1:nsaved_contours
	handles.exp.regions.contours{r}{midx}{c} = ...
	    cn{saved_contour_idxs(c)};
    end
end



%matr = [];
%for r = 1:nregions
%    cn = handles.exp.regions.contours{r}{midx};    
%    for d = 1:length(cn{r})
%        if (polyarea(cn{d}(:,1),cn{d}(:,2)) > min_area(r) & ...
%    	    polyarea(cn{d}(:,1),cn{d}(:,2)) < max_area(r))
%            matr = [matr; [create_centroid(cn{d}) r d]];
%        end
%    end
%end
%dst = sum((matr(:,1:2)-repmat([x y],size(matr,1),1)).^2,2);
%[dummy i] = min(dst);
%tempcn = [];
%for d = [1:matr(i,4)-1 matr(i,4)+1:length(cn{matr(i,3)})]
%    tempcn{length(tempcn)+1} = cn{matr(i,3)}{d};
%end
%cn{matr(i,3)} = [];
%for d = 1:length(tempcn)
%    cn{matr(i,3)}{d} = tempcn{d};
%end

%handles.exp.regions.contours{ridx}{midx} = cn;
%ridx = matr(i,3);
%%% Could be taken out to the GUI level. -DCS:2005/04/05
handles = draw_cell_contours(handles, 'ridx', 'all');
handles = uiset(handles,'detectcells','all','enable','on');
handles = uiset(handles,'filterimage','all','enable','on');