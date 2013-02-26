function [repeats1,repeats2]=findbestrepeats(ons1,ons2)
% function [repeats1,repeats2]=findbestrepeats(ons1,ons2,conts);
%
% This function looks for and returns the largest repeat of activity
% between two events (of a particular type).
%
% Inputs ons1 and ons2 are logical matrices denoting the activity of cells
% in each frame of two separate movies/events/epochs.  (If a cell 19 was 
% active in frame 3 of the second event, ons2 element (3,19) will be a one,
% otherwise it will be zero.  
% 
% The output of the function is in the same format as ons1/2 but only
% includes the largest single repeated sequence of events
warning off MATLAB:conversionToLogical
len1=size(ons1,1);%get the number of frames in each movie
len2=size(ons2,1);
%next lines set up a series of frames against which to compare each
%other... movies will be "slid" across each other one frame at a time for
%comparison.  The numbers below will specify the frames to be used in each
%step of the slide.
avect=[ones(1,len2-1) 1:len1];
bvect=[1:len1, len1*ones(1,len2-1)];
yvect=[0:(len2-1) (len2-1)*ones(1,len1-1)];
zvect=[zeros(1,len1-1) 0:(len2-1)];
yvect=len2-yvect;
zvect=len2-zvect;
%stepwise sliding.  Keep number of matching activations in sumreps
%This would be faster if a matrix were set up before hand to replace the
%loop
for a=1:length(avect);
    comp1=ons1(avect(a):bvect(a),:);%extract addressed frames
    comp2=ons2(yvect(a):zvect(a),:);
    reps{a}=comp1.*comp2;%find matches ("overlaps") by logical multiply in those frames
    sumreps(a)=sum(sum(reps{a}));%sums for deciding which to keep
end
%Below tackles the problem that even identical events may look different in
%two movies because the activity may be parsed differently into the frames
%of each movie.  This will look for a consistent shift (offset) between
%where the activity lies in the frames (ie events in frame 2 ons1 are found
%in frames 2 and 3 of ons2).
%  It also only keeps the largest repeat, that is of course not necessary.
doublesums=sumreps(1:end-1)+sumreps(2:end);%adding up each pair of comparisons
    %(to look for offsets as well as overlaps)
ind1=find(doublesums==max(doublesums));%find the pair of comparisons with the
    %max number of overlaps... use that as our "repeats"
if prod(size(ind1))>1;%if there are two points with the same max value, then...
    g=ind1-(len2-.5);%find the distance of each from a zero offset
    [trash,gind]=min(g);%find the one that is closer to zero offset (and if
        %there is a tie, just take the first one)
    ind1=ind1(gind);%ind1 is the ID of the largest doublesum... 
        %which corresponds with the ID of the largest single sum
end

ind2=ind1+1;
%find the addresses of the repeated frames within ons1
repeats1=zeros(size(ons1));
repeats1(avect(ind1):bvect(ind1),:)=reps{ind1};%take first half of doublesum
repeats1(avect(ind2):bvect(ind2),:)=repeats1(avect(ind2):bvect(ind2),:)+reps{ind2};%and second half
repeats1=logical(repeats1);%cancel out any artifactual 2's that resulted
%...and within ons2... for output from function
repeats2=zeros(size(ons2));
repeats2(yvect(ind1):zvect(ind1),:)=reps{ind1};
repeats2(yvect(ind2):zvect(ind2),:)=repeats2(yvect(ind2):zvect(ind2),:)+reps{ind2};
repeats2=logical(repeats2);


% figure;%for showing echos... 
% shift=(1:(size(ons2,1)+size(ons1,1)-2))-len2+.5;%offsets will not be integers, since we're looking at pairs of offsets... give them as X.5 frames
% plot(shift,doublesums);
% 
% for a=1:size(ons1,1);
%     figure;
%     set(gcf,'position',[0 0 500 500])
%     highlightshared(conts,ons1(a,:),repeats1(a,:));
% end
% for a=1:size(ons1,1);
%     figure;
%     set(gcf,'position',[525 200 500 500])
%     highlightshared(conts,ons2(a,:),repeats2(a,:));
% end