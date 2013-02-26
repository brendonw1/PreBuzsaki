function [clean_contours, clean_halos] = preprocess(handles)
% function handles = preprocess(handles)
% 
% We pass the entire matrix of image recordings in the hopes that the
% authors of the preprocess routines will be smart about their
% implementation.  If the preprocessor wants to make explicit use of
% the halos, they are the second half of the traces.
npreprocess_steps = length(handles.exp.preprocessStrings);


clean_contours = [];
clean_halos = [];

num_contours = handles.exp.numContours;
num_images_process = handles.exp.globals.numImagesProcess;

% Put the contours and the halos together as a single matrix where
% each contour/halo is a row in the matrix.
contours = reshape([handles.exp.contours.intensity], ...
		   num_images_process, ...
		   num_contours)';
if (handles.exp.haloMode == 0)
    x = [contours];
else
    halos = reshape([handles.exp.contours.haloIntensity],...
        num_images_process, ...
        num_contours)';
    x = [contours; halos];   
end

for i = 1:npreprocess_steps
    preprocessor = ['ct_' handles.exp.preprocessStrings{i}];
    if strcmpi ('ct_signal_binary_data', preprocessor);
        handles.exp.preprocesssStrings = {'ct_signal_binary_data'};
        break
    end
end

% Now run the preprocessing steps on the matrix.
for i = 1:npreprocess_steps
    preprocessor = ['ct_' handles.exp.preprocessStrings{i}];
    options = handles.exp.preprocessOptions{i};
    options = add_options_from_gui(handles, options);
    if strcmpi ('ct_signal_binary_data', preprocessor);
        x=feval(preprocessor, x, handles, options);
    else
        x = feval(preprocessor, x, options);
    end    
end
%make sure no NaNs... probably never good and specifically messes up graphing
%intensityplot
x(isnan(x))=0;


% Setup the clean matrices.  Should this be regenerated each time in
% the future to avoid confusion? -DCS:2005/05/30
if (handles.exp.haloMode == 0)
    clean_contours = x;
else
    clean_contours = x(1:end/2,:);
    clean_halos = x(end/2+1:end,:);
end




