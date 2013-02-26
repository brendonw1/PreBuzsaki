function handles = adjust_overlap(handles)
% function handles = adjust_overlap(handles)
nregions = handles.exp.numRegions;

% Find out what action the user would like.
%do_keep = uiget(handles, 'consolidatemaps', 'adjustkeep',
%'value');
% do_keep = 0;				% obsolete -DCS:2005/09/01
% Seperate means to delete from the current mask.
do_delete = uiget(handles, 'consolidatemaps', 'adjustseparate', 'value');
adjust_action = 'keep';
% if (do_keep)
%     adjust_action = 'keep';
% else
if (do_delete)
    adjust_action = 'delete';
end

lidx = get_label_idx(handles, 'image');
children_handles = get(handles.uigroup{lidx}.imgax, 'Children');
types = get(children_handles, 'Tag');
overlap_contour_handles_idx = strmatch('cellcontour - overlap', types);
overlap_contour_handles = children_handles(overlap_contour_handles_idx);

% region, map, contour
contour_info = get(overlap_contour_handles, 'UserData'); % cell array.
noverlap_contours = size(contour_info, 1);

if noverlap_contours > 0
    % Array for setdiff.
    overlap_contour_info = reshape([contour_info{:}], 3, noverlap_contours)';

    for r = 1:nregions
        movie_contours = handles.exp.regions.contours{r}{1};
        nmovie_contours = length(handles.exp.regions.contours{r}{1});
        if (nmovie_contours < 1) % no movie contours in this region.
            continue;
        end
        movie_contour_idxs = (1:nmovie_contours)';
        switch adjust_action 
            case 'keep'			
                %do nothing (bw)

                % keep the overlapping contours.
                  %saved_contour_infos = overlap_contour_info;
                  % Since we are doing this in a region for loop, we have to pick out the
                  % right region every time.
    %               saved_contour_infos = overlap_contour_info(:,1);
             case 'delete'			
    %             % info array             region                 map    contour
    %             movie_contour_array = ...
    %             [r*ones(nmovie_contours,1) ...
    %             ones(nmovie_contours, 1), ...
    %             movie_contour_idxs];
    %             saved_contour_infos = setdiff(movie_contour_array, ...
    %                             overlap_contour_info, ...
    %                             'rows');      
    %             % Now that we've decided what to save, we can save it.
    %             saved_contour_idxs = saved_contour_infos(:,3);
    %             nsaved_contours = length(saved_contour_idxs);
    %             handles.exp.regions.contours{r}{1} = cell(1,nsaved_contours);
    %             for c = 1:nsaved_contours
    %                 handles.exp.regions.contours{r}{1}{c} = ...
    %                     movie_contours{saved_contour_idxs(c)};
    %             end
                tokill = overlap_contour_info(find(overlap_contour_info(:,1)==r),3);
                handles.exp.regions.contours{r}{1}(tokill) = [];
                handles.exp.contourMaskIdx{r}(tokill) = [];%record which mask each movie contour overlapped with
            otherwise
                errordlg('Case not implemented yet.');
        end    
    end
end