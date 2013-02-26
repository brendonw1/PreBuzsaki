function app_data = ct_add_missing_options(appdata)

app_data = appdata;

if (~isfield(appdata, 'isPreprocessedValid'))
    app_data.isPreprocessedValid = 0;
end

if (~isfield(appdata, 'didSetupExperiment'))
    app_data.didSetupExperiment = 0;
end

if (~isfield(appdata, 'title'))
    app_data.title = 'CalTracer';
end

if (~isfield(appdata, 'versionNum'))
    app_data.versionNum = 1.1;
end

if (1 | ~isfield(appdata, 'ctPath'))
    [pathstr, name, ext, versn] = fileparts(which('caltracer'));
    app_data.ctPath = pathstr;
end

if (~isfield(appdata, 'logo'))    
    %app_data.logo = imread('e-po.bmp');
    app_data.logo = imread('hippo.bmp');
end

if (~isfield(appdata, 'currentCellId'))
    app_data.currentCellId = 1;
end

if (~isfield(appdata, 'currentRegionIdx'))
    app_data.currentRegionIdx = 1;
end

if (~isfield(appdata, 'currentContourOrderId') ...
    & isfield(appdata, 'currentNeuronOrderId'))
    app_data.currentContourOrderId = appdata.currentNeuronOrderId;
elseif (~isfield(appdata, 'currentContourOrderId'))
    app_data.currentContourOrderId = 1;
end

% No idea why I didn't use a consisent Idx vs. Id. -DCS:2005/08/23
if (~isfield(appdata, 'currentContourOrderIdx'))
    app_data.currentContourOrderIdx = app_data.currentContourOrderId;
    app_data = rmfield(app_data, 'currentContourOrderId');
end

if (~isfield(appdata, 'contourOrder'))
    app_data.contourOrder = struct;
end

if (isfield(appdata, 'currentDetectionIdx'))
    if (appdata.currentDetectionIdx==0)
        app_data.currentDetectionIdx = 1;
    end
end
if (~isfield(appdata, 'currentDetectionIdx'))
    app_data.currentDetectionIdx = 1;
end

% The current clustering or 'partition' of the data.  This is a set of
% clusters.
if (~isfield(appdata, 'currentPartitionIdx'))
    app_data.currentPartitionIdx = 0;
end

% legacy. -DCS:2005/08/09
if (~isfield(appdata, 'numPartitions'))
    0;
end


if (~isfield(appdata, 'activeContourColor'))
    app_data.activeContourColor = [1 1 1];
end

if (~isfield(appdata, 'activeCells'))
    app_data.activeCells = [];
end

if (~isfield(appdata, 'showCheckBoxTag'))
    app_data.showCheckBoxTag = 'showcheckbox';
end
if (~isfield(appdata, 'showHaloCheckBoxTag'))
    app_data.showHaloCheckBoxTag = 'showhalocheckbox';
end

if (~isfield(appdata, 'maskLabels'))
    app_data.maskLabels = {'tcImage'};
end    

if (~isfield(appdata, 'useContourSlider'))
    app_data.useContourSlider = 1;
end


% {'inputarg', 'file'};
if (~isfield(appdata, 'currentImageInputType'))
    app_data.currentImageInputType = 'file';
end

% For downward signals such as Fura2.
if (~isfield(appdata, 'multiplySignalsbyNegOne'))
    app_data.multiplySignalsbyNegOne = 0;
end

% For downward signals such as Fura2.
if (~isfield(appdata, 'centroidDisplay'))
    app_data.centroidDisplay.on = 0;
    app_data.centroidDisplay.points = [];
    app_data.centroidDisplay.text = [];
end

%%
% To determine whether to allow user to click "next" without "update halos".

if (~isfield(app_data, 'skipThroughSettings'));
    app_data.skipThroughSettings = struct;
end
if (~isfield(app_data.skipThroughSettings, 'haloUpdate'));
    app_data.skipThroughSettings.haloUpdate.index = 0;%0 means no skipthrough
end

% To determine whether user must answer question about flipping traces
if (~isfield(app_data.skipThroughSettings, 'flipSignalQuestion'));
    app_data.skipThroughSettings.flipSignalQuestion.index = 0;%0 means no skipthrough
    app_data.skipThroughSettings.flipSignalQuestion.options = 'No';%whether to flip signals or not
end

if (~isfield(app_data.skipThroughSettings, 'skipRegions'));
    app_data.skipThroughSettings.skipRegions.index = 0;%0 means no skipthrough
end

if (~isfield(app_data.skipThroughSettings, 'skipFilter'));
    app_data.skipThroughSettings.skipFilter.index = 0;%0 means no skipthrough
end

if (~isfield(app_data.skipThroughSettings, 'autoLoadContours'));
    app_data.skipThroughSettings.autoLoadContours.index = 0;%0 means no skipthrough
end

if (~isfield(app_data.skipThroughSettings, 'skipHaloWindow'));
    app_data.skipThroughSettings.skipHaloWindow.index = 0;%0 means no skipthrough
end




% For keeping track of whether the expt has been saved since opening
if (~isfield(appdata, 'didSaveExperiment'))
    app_data.didSaveExperiment = 0;
end

if (~isfield(appdata, 'haloMode'))%set default as yes use halos
    app_data.haloMode = 1;%ie yes use halos
end

if (~isfield(appdata, 'haloArea'))%set default halo size as 1
    app_data.haloArea = 1;%ie same area as the cell contour itself
end

if (~isfield(appdata, 'openedAs'))%was it opened same way as another movie?
    app_data.openedAs = [];
end