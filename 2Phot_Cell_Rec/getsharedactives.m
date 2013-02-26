function getsharedactives(filename,range,varargin);
%"width" is how many frames on either side of a single frame peak will be
%included in an event.

disp(mode)

mode=lower(mode);%put in lower case for comparisons
        for a=1:size(temp,1)%for each separate group of frames
            t{a}=temp(a,:);%assign to its own cell array... this is so later other sized groups can be added manually
        end
    case 'array'

r=[];
if strcmp(mode,'signif') | strcmp(mode,'array');%if non manual mode, display which cells overlap so far
	for a=1:length(t);%for each set of frames corresponding to a peak
        r(a,:)=logical(sum(spk(:,t{a}),2))';%find and record all active neurons, put them in a matrix of (peak# x cell#)
	end
    if ~isempty(r);%if some useable peaks were found
		axis equal
		axis tight
        disp('press return to continue')
	else
        disp('No statistically significant peaks of synchrony');
	end
end

figure;
bar(sum(spk));%plot active cells per frame
set(gcf,'position',[5 500 1275 450])%make window a wide window across top of monitor
if ~isempty(t);%if some frames were already analyzed
ind=0;
    if strcmp(i,'n');%if proper yes or no leave loop
        ind=1;
    end
	if strcmp(i,'y');
        title('TO ADD: USING LEFT BUTTON: click left and right bounds of frames of interest.  TO SUBTRACT: CLICK WITH RIGHT BUTTON.');%add title
            framenum=round(framenum);%round x-axis values, these indicate the first and last frames to be analyzed
            hold on
            t2=framenum(1:end);%store the frame numbers in a vector
            t{end+1}=t2;%put in t array
            t3=sum(spk);%find the number of cells on for each frame in the movie
            t3=t3(t2);%extract the number of cells for the frames already analyzed
            hold on
            bar(t2,t3,'r')%highlight the bars of those cells red
        elseif button==2;
            framenum=round(framenum(1));%find the frame first clicked on
            for a=1:length(t);
                rec(a)=logical(sum(t{2}==framenum));%find which group that frame was in, to delete it later
            end
            rec=find(rec);%determine which group that frame is in
            temp=t(rec);
            temp2=sum(spk);
            temp2=temp2(temp);%record values at those frames... for later covering over with blue
            t(rec)=[];
            bar(t2,t3)%highlight the bars of those cells red
        end
    end
end

%%%%%%%%%%%%%Copied from above... plotting shared cells%%%%%%%%%%%%
if ~isempty(r);%if some useable peaks were found
	multi=sum(r);%add along the peaks dimension, to find how many peaks each cell was active in
	cl=hsv(max(multi)+1);%get a colorwheel for this number of cells (+1)
	cl(end,:)=[];%eliminate extra, so there is a ramping up of colors towards red (ie not circular)
	cl=flipud(cl);%orient so red is most repeats
    figure;
	for a=1:max(multi);%for neurons of different numbers of repetitions
        temp=zeros(size(multi));%make a new matrix...
        temp(find(multi==a))=1;%where cells of a particular number of repetitions are marked with 1's all others are 0s
        highlightonscolor(cn,temp,cl(a,:));
	end
	axis equal
	axis tight
end

% legend ('pos',4


% shared.region=region;
% shared.cellvalues=tr;
% shared.signif=signif;
% shared.sharedcells=matches;
% save filename shared