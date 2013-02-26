function varargout=register_images(varargin)
% Adam Packer  July 18th, 2008
% Quick image registration wrapper/script
% Inputs
% 1) base image
% 2) unregistered image
% Outputs
% 1) handle to base image to change transparency

% read images
base=imread(varargin{1});
unregistered=imread(varargin{2});

% run cpselect tool to match up image points
% make sure to export points to workspace!
temp=cpselect(unregistered,base);
waitfor(temp);
input_points = evalin('base','input_points');
base_points = evalin('base','base_points');

% uncomment next line to refine the matching points via image correlation
% input_points = cpcorr(input_points,base_points,rgb2gray(unregistered),rgb2gray(base));

% calculate affine image transformation using matched image points
tform = cp2tform(input_points, base_points, 'affine');

% create registered image that fits in the size of the base image
registered = imtransform(unregistered,tform,...
'FillValues', 255,...
'XData', [1 size(base,2)],...
'YData', [1 size(base,1)]);

% set up the figure
newfig=figure;
set(newfig,'Renderer','opengl');
imshow(registered)
hold on
h = imshow(base);
set(h,'AlphaData',0.5);

% set outputs
varargout{1}=h;