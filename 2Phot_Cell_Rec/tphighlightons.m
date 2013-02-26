function tphighlightons(cn,ons)
% cn is a countour file generated by "findcells" or "labelcells".  This
% will plot and label the contours specified in that cell array.  Labels
% will correspond with cell numbers in matrices generated from in other
% m-files (except in cases where activeon or activevalues are used, because
% those variables have inactive cells deleted from them).

% this function is different from "plotfromcontours" in that it uses the
% "ons" to highlight specific cells (contours).  "ons" should correspond to
% the cells which are on in just one frame.  

% figure
for t=1:length(cn);
%     xlim([0 255]);
%     ylim([0 255]);
    set(gca,'YDir','reverse');
    hold on;
    plot(cn{t}(:,1), cn{t}(:,2),'color',[.5,.5,.5]);
%     label=num2str(t);
%     text(cn{t}(1,1),cn{t}(1,2),label);
end

n=ons;
for u=1:length(n);
    patch(cn{n(u)}(:,1),cn{n(u)}(:,2),'red','edgecolor','red');
    %     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.4 .5 1],'edgecolor',[.4 .5 1]);
%     patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.4 .7 .4],'edgecolor',[.4 .7 .4]);
%      patch(cn{n(u)}(:,1),cn{n(u)}(:,2),[.4 .4 .4],'edgecolor',[.4 .4 .4]);
%     label=num2str(u);
%     text(cn{n(u)}(1,1),cn{n(u)}(1,2),label);
end

axis equal
axis tight
% axis off
% plot([0 255 255 0 0],[0 0 255 255 0],'k')