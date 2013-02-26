function highlightshared(cn,ons1,ons2)

figure
for t=1:length(cn);
%     xlim([0 255]);
%     ylim([0 255]);
    set(gca,'YDir','reverse');
    hold on;
    plot(cn{t}(:,1), cn{t}(:,2),'color',[.5,.5,.5]);
end

ons1=logical(ons1);
ons2=logical(ons2);
shared=ons1.*ons2;
% shared=ons1+ons2;
% shared(find(shared<2))=0;
% shared(find(shared==2))=1;

n=find(ons1);
for u=1:length(n);
%      patch(cn{n(u)}(:,1),cn{n(u)}(:,2),'k','edgecolor','k');

    patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.4 .4 .4],'edgecolor',[.4 .4 .4]);
%     label=num2str(u);
%     text(cn{n(u)}(1,1),cn{n(u)}(1,2),label);
end

n=find(ons2);
for u=1:length(n);
%     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[0/255 147/255  221/255],'edgecolor',[0/255 147/255  221/255]);%baby blue

%         patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.4 .4 .4],'edgecolor',[.4 .4 .4]);
        patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.1 .7 .1],'edgecolor',[.1 .7 .1]);
    %     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[102/255 178/255  102/255],'edgecolor',[102/255 178/255  102/255]);%pukey green
%     label=num2str(u);
%     text(cn{n(u)}(1,1),cn{n(u)}(1,2),label);
end

n=find(shared);
for u=1:length(n);
%     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[1 0 1],'edgecolor',[1 0 1]);
    patch(cn{n(u)}(:,1),cn{n(u)}(:,2),'r','edgecolor','r');
%     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[0/255 147/255  221/255],'edgecolor',[0/255 147/255  221/255]);
%     label=num2str(u);
%     text(cn{n(u)}(1,1),cn{n(u)}(1,2),label);
end

title (['Ons1 in gray (',num2str(sum(ons1)),').  Ons2 in green (',num2str(sum(ons2)),').  Shared in red (',num2str(sum(shared)),...
    ').  ',num2str(size(ons1,2)),' total cells.'])

axis equal
axis off
% plot([0 255 255 0 0],[0 0 255 255 0],'k')