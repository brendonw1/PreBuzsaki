function frames = gethamaframes(integout,varargin)
% Email from SimplePCI guy:
% I am not a Hamamatsu camera engineer so I cannot in all certainty speak on
% the digital outputs of the camera.  However, I can definitively speak on
% what the software is doing and try to relate that to your observed data.
% 
% Fastest frame rates are achieved only in the camera's free run mode: camera
% is continuously capturing, exposure and read-out are overlapped.  In this
% mode, we have no control over when a particular frame's exposure has
% started.  To ensure our first frame starts exposing when we request it, we
% toggle camera modes.  We first set the camera into an external trigger mode:
% the camera is waiting for an electrical pulse to begin its exposure.   I
% expect that this is the timing gap you see.  Then, we switch the mode to
% free-run.  This causes the camera to reset its exposure, which should
% account for the first small-exposure frame after the gap.
% 
% With respect to the requested exposure frames, it is the last frame that is
% not used.  The camera is in an overlapped mode.  One frame is exposing while
% another is reading out.  So when we realize our count of 50 has been met and
% that the 50th frame is safely saved, frame 51 is already on its way.
% 
% When we have completed our sequence, we send a command to stop the camera's
% acquisition.  If the camera is in the middle of capturing an image, the
% process is aborted and the image is invalid.  I believe this will account
% for the last small-exposure frame


frames = continuousabove(integout,zeros(size(integout)),1,1,Inf);

if ~isempty(varargin)
    if strcmp(varargin{1},'lastmovieonly')
        %if multiple movies acquired, assume separated by more than 1
        %second, and keep only last in that file.
        endprev = find(frames(2:end,1)-frames(1:end-1,2)>10000,1,'last');
        frames(1:endprev,:) = [];
    end
end

frames = frames(5:end-2,:);

% ifis = frames(2:end,1)-frames(1:end-1,2);%time between frames

