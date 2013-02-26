function getsharedactives(filename,range,varargin);
%"width" is how many frames on either side of a single frame peak will be
%included in an event.
if nargin==2;%if no specified mode input    mode='signif';%default is mode based on finding significant peaks of synch.elseif nargin==3 & ischar(varargin{1});%if a character input was specified, that will determine the mode used below    mode=varargin{1};elseif nargin==3 & ~ischar(varargin{1});%if a numeric array    mode='array';end
disp(mode)[spk,tr,cn]=bprintout(filename);%find probable spikest={};%establish for "isempty" comparison

mode=lower(mode);%put in lower case for comparisonsswitch mode%note if case is 'manual', we'll skip ahead to the bottom    case 'signif'%this case finds peaks based on whether they represent stastically significant synchronizations        for a=1:1000;%1000 times            newspk=reshuffleisis(spk');%reshuffle the spike trains and save the result            m(a)=max(sum(newspk,2));%record the maximum number of cells synchronized in any frame of that reshuffled data... max is somewhat conservative        end		m=sort(m);%rank those max synchronizations		signif=m(.95*length(m)+1);%define and record level above which you have less than 5% chance of getting such a max syhcro. 		s=find(sum(spk)>=signif);%find frames in movie in which there are at least a significant number of co-active neurons        s(find(s<10 | s>size(spk,2)-10))=[];%eliminate any peaks too near the start or end of the movie    	numperpeak=sum(spk(:,s));%storing how many neurons per major peak for later	    p=find(diff(s)<=(range(1)+range(2)));%find peaks that are too close together        for a=1:length(p);%for each pair of too-close peaks (we'll keep only the larger)            [trash,index]=min(numperpeak([p(a) p(a)+1]));%find the peak that had less neurons active (answer will be either 1 or 2)            index=index-1;%transform 1 or 2 to 0 or 1, denoting how much we'll have to add to the number p(a) to address the correct peak            s(p(a)+index)=[];%delete the frame with lesser neurons from the list        end        [u,v]=meshgrid([-range(1):range(2)],s);%set up for next step        temp=(u+v);%each row in t is a list of frames corresponding to a peak of synchrony
        for a=1:size(temp,1)%for each separate group of frames
            t{a}=temp(a,:);%assign to its own cell array... this is so later other sized groups can be added manually
        end
    case 'array'        s=varargin{1}(1:end);%make sure this is a 1D vector        ends=find(diff(s)~=1);%find breaks between groups of points	    ends(end+1)=0;%for the purposes of creating lengths of each group	    ends(end+1)=length(s);%set last end as end of whole set        ends=sort(ends);        lengths=diff(ends);	    ends(1)=[];%lose the 0 added before        starts=ends-lengths+1;        for a=1:length(ends);            t{a}=s(starts(a):ends(a));        endend

r=[];
if strcmp(mode,'signif') | strcmp(mode,'array');%if non manual mode, display which cells overlap so far
	for a=1:length(t);%for each set of frames corresponding to a peak
        r(a,:)=logical(sum(spk(:,t{a}),2))';%find and record all active neurons, put them in a matrix of (peak# x cell#)
	end
    if ~isempty(r);%if some useable peaks were found		multi=sum(r,1);%add along the peaks dimension, to find how many peaks each cell was active in		cl=hsv(max(multi)+1);%get a colorwheel for this number of cells (+1)		cl(end,:)=[];%eliminate extra, so there is a ramping up of colors towards red (ie not circular)		cl=flipud(cl);%orient so red is most repeats		for a=1:max(multi);%for neurons of different numbers of repetitions            temp=zeros(size(multi));%make a new matrix...            temp(find(multi==a))=1;%where cells of a particular number of repetitions are marked with 1's all others are 0s            highlightonscolor(cn,temp,cl(a,:));        end
		axis equal
		axis tight
        disp('press return to continue')        pause
	else
        disp('No statistically significant peaks of synchrony');
	end
end

figure;title('Frames have already been selected are in red');
bar(sum(spk));%plot active cells per frame
set(gcf,'position',[5 500 1275 450])%make window a wide window across top of monitor
if ~isempty(t);%if some frames were already analyzed    t2=t(1:end);%store the frame numbers in a vector    t3=sum(spk);%find the number of cells on for each frame in the movie    t3=t3(t2);%extract the number of cells for the frames already analyzed    hold on    bar(t2,t3,'r')%highlight the bars of those cells redend
ind=0;while ind==0;%as long as no yes or no answer is given keep asking the following question    i=input('Do you want to edit selected frames by hand? y/n: ','s');
    if strcmp(i,'n');%if proper yes or no leave loop
        ind=1;
    end
	if strcmp(i,'y');
        title('TO ADD: USING LEFT BUTTON: click left and right bounds of frames of interest.  TO SUBTRACT: CLICK WITH RIGHT BUTTON.');%add title        [framenum,trash,button]=ginput(2);%record two points (only care about x values)        if button==1;
            framenum=round(framenum);%round x-axis values, these indicate the first and last frames to be analyzed            framenum=framenum(1):framenum(end);%create an integer sequence of the first frame number to the last            r(end+1,:)=logical(sum(spk(:,framenum),2))';%find and record all active neurons, put them in a matrix of (peak# x cell#)
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