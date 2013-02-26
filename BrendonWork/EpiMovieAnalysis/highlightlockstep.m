function f = highlightlockstep(conts,ons1,ons2,varargin)

if ~isempty(varargin);
    interactionframes = varargin{1};
else
    interactionframes = [0 0];
end

[lock1,lock2] = findbestrepeats(ons1,ons2);
% ons2 = changeframespace(ons1,ons2);

%get first start frame and last stop frame of lockstepping
framenums1 = logical(sum(lock1,2));
framenums1 = find(framenums1);
framenums2 = logical(sum(lock2,2));
framenums2 = find(framenums2);
framenums(1) = min([framenums1(1) framenums2(1)]);
framenums(2) = max([framenums1(end) framenums2(end)]);

framenums(end) = min([framenums(end) size(ons1,1) size(ons2,1)]);%so don't try to overrun
%   a shorter movie with lock from a longer one
len = framenums(end)-framenums(1)+1;
framenums = framenums(1):framenums(end);


f = figure;
axwidth = 1/len-.01;
for fidx = 1:len;
    xpos1 = (fidx-1)/len;
    thisframe = framenums(fidx);
    a1 = axes('parent',f,'units','normalized','position',[xpos1 .75 axwidth .24]);
    localhighlightons(conts,ons1(thisframe,:),[0 0 0],a1);
    if interactionframes(1)==thisframe
        plotboundingbox(a1,conts);
    end
    
    a2 = axes('parent',f,'units','normalized','position',[xpos1 .5 axwidth .24]);
    localhighlightons(conts,ons2(thisframe,:),[0 0 1],a2);    
    if interactionframes(2)==thisframe
        plotboundingbox(a2,conts);
    end
    
    a3 = axes('parent',f,'units','normalized','position',[xpos1 .25 axwidth .24]);
    localhighlightons(conts,lock1(thisframe,:),[1 0 0],a3);
    if interactionframes(1)==thisframe
        plotboundingbox(a3,conts);
    end
    
    a4 = axes('parent',f,'units','normalized','position',[xpos1 0 axwidth .24]);
    localhighlightons(conts,lock2(thisframe,:),[1 0 1],a4);
    if interactionframes(2)==thisframe
        plotboundingbox(a4,conts);
    end
    
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localhighlightons(cn,ons,color,axes)
for t=1:length(cn);
    set(gca,'YDir','reverse');
    hold on;
    line(cn{t}(:,1), cn{t}(:,2),'color',[.5,.5,.5],'parent',axes);
end

n=find(ons);
for u=1:length(n);
    patch(cn{n(u)}(:,1),cn{n(u)}(:,2),color,'edgecolor',color,'parent',axes);
end

axis equal
axis off
axis tight
% plot([0 511 511 0 0],[0 0 511 511 0],'k')
% xlim([0 512

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotboundingbox(axes,conts)
for cidx = 1:size(conts,2);
    xmaxes(cidx) = max(conts{cidx}(:,1));
    ymaxes(cidx) = max(conts{cidx}(:,2));
end
xmax = max(xmaxes);
ymax = max(ymaxes);

line([1 xmax xmax 1 1],[1 1 ymax ymax 1],'color',[1 0 0])
xlim([0 xmax])
ylim([0 ymax])