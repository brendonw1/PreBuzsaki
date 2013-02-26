function region=viewcellsbyactivity(varargin);

if nargin==1;
    if isstruct(varargin{1});
        if isfield(varargin{1},'contours');
            region=varargin{1};
            funcmode='draw';
        end
    end
elseif nargin==3;
%     if isstruct(varargin{1})
%         if isfield(varargin{a},'tag');
            currentobj=varargin{1};
%         end
%     end
    handles=varargin{2};
    funcmode=varargin{3};
end

switch lower(funcmode)
    case 'draw'
		contours=region.contours;
		
		handles.fig=figure('Name','Number of Activations Viewer','NumberTitle','off','doublebuffer','on');
		hObject = handles.fig;
		hold on;
		axis off;
		axis equal
		axis tight;
        set(handles.fig,'position',[336 435 661 453]);
		set(gca,'YDir','reverse')
		for x=1:length(contours);
            handles.cells{x}=patch(contours{x}(:,1),contours{x}(:,2),'k','FaceColor','none');%plot a black-edged patch for each contour
            set(handles.cells{x},'tag',num2str(x),'buttondownfcn','viewcellsbyactivity(gcbo,guidata(gcbo),''displayactivity'')');%sets value in oncells to 1 when contour is clicked
%             set(handles.cells{x},'tag',num2str(x),'buttondownfcn','assignin(''base'',''currentobj'',gcbo);assignin(''base'',''handles'',guidata(gcbo))');%sets value in oncells to 1 when contour is clicked
		end
		
		for a=1:length(region.onsets);%for each cell
            handles.cellons(a)=length(region.onsets{a});%calculate how many times it came on
		end
		
		cl=hsv(2*max(handles.cellons));%create a colormap of cell activity levels
		cl(size(cl,1)/2+1:size(cl,1),:)=[];%eliminate extra, so there is a ramping up of colors towards red (ie not circular)
		cl=flipud(cl);%orient so red is most repeats
		
		for a=1:length(handles.cellons);%for each contour    
            if handles.cellons(a);%if cell was active
                set(handles.cells{a},'FaceColor',cl(handles.cellons(a),:));%color it according to its activity
%                 cent=centroid(contours{a});
%                 text(max(contours{a}(:,1))+1,cent(2),num2str(handles.cellons(a)),'FontSize',11);
            end
		end
        handles.region=region;
		guidata(hObject,handles);
    case 'displayactivity'
        handles=varargin{2};
%         disp (handles)
   		hObject = handles.fig;
        whichcell=str2num(get(currentobj,'tag'));
%         if ~isfield(handles,'fig2');
		    handles.fig2=figure('Name',['Brightness Profile of Cell # ',num2str(whichcell)],'NumberTitle','off','doublebuffer','on');
            set(handles.fig2,'position',[2 35 1276 377]);
%         else
%             figure(handles.fig2);
%         end
        plot(handles.region.traces(whichcell,:));
        hold on
        onsets=handles.region.onsets{whichcell};
        offsets=handles.region.offsets{whichcell};
        plot(onsets,handles.region.traces(whichcell,onsets),'o','color','green');
%             plot(onsets,handles.region.traces(whichcell,offsets),'o','color','red');    
end