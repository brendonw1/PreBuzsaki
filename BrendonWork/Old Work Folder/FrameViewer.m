function varargout = FrameViewer(varargin)
% FRAMEVIEWER M-file for FrameViewer.fig
%      FRAMEVIEWER, by itself, creates a new FRAMEVIEWER or raises the existing
%      singleton*.
%
%      H = FRAMEVIEWER returns the handle to a new FRAMEVIEWER or the handle to
%      the existing singleton*.
%
%      FRAMEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRAMEVIEWER.M with the given input arguments.
%
%      FRAMEVIEWER('Property','Value',...) creates a new FRAMEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FrameViewer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FrameViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FrameViewer

% Last Modified by GUIDE v2.5 22-Jul-2003 11:35:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FrameViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @FrameViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FrameViewer is made visible.
function FrameViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FrameViewer (see VARARGIN)

% Choose default command line output for FrameViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% Populate the listbox
update_listbox(handles)
set(handles.VariableBox,'Value',[])
% UIWAIT makes FrameViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FrameViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function VariableBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VariableBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function update_listbox(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
set(handles.VariableBox,'String',vars)





% --- Executes on selection change in VariableBox.
function VariableBox_Callback(hObject, eventdata, handles)
% hObject    handle to VariableBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns VariableBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VariableBox


