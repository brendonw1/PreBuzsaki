function plotprof(fin,num,r)
%plotprof(fin,num,r)
%   plots the numth temporal profile

load(fin);
pr = prof(:,num)';
nr = mean(abs(pr));
pr = pr / nr;

lb = pr - lbar(:,num)'/nr;
ub = ubar(:,num)'/nr - pr;

if r == 1
   pr = -pr;
   t = lb;
   lb = ub;
   ub = t;
end

if size(lb,2)==32
   h = errorbar(0.473/64:0.473/32:0.473-0.473/64,pr,lb,ub,'k');
   set(h,'linewidth',2);
   xlim([0 0.473]);
   ylim([-max(abs(ylim)) max(abs(ylim))]);
   hold on;
   plot([0.237 0.237],ylim,'-.k','linewidth',1);
   plot(xlim,[0 0],'-.k','linewidth',1);
   xlabel('Time (sec)','fontsize',18);
   if num == 1
      ylabel('First temporal profile','fontsize',18);
   else
      ylabel('Second temporal profile','fontsize',18);
   end
   set(gca,'fontsize',14);
else
   h = errorbar(0.473/64:0.473/32:0.473-0.473/64,pr(1:32),lb(1:32),ub(1:32),'k');
   set(h,'linewidth',2);
   xlim([0 0.473]);
   ylim([-max(abs(ylim)) max(abs(ylim))]);
   hold on;
   plot([0.237 0.237],ylim,'-.k','linewidth',1);
   plot(xlim,[0 0],'-.k','linewidth',1);
   xlabel('Time (sec)','fontsize',18);
   if num == 1
      ylabel('First temporal profile','fontsize',18);
   else
      ylabel('Second temporal profile','fontsize',18);
   end
   set(gca,'fontsize',14);
   figure(2);
   h = errorbar(0.473/64:0.473/32:0.473-0.473/64,pr(33:end),lb(33:end),ub(33:end),'k');
   set(h,'linewidth',2);
   xlim([0 0.473]);
   ylim([-max(abs(ylim)) max(abs(ylim))]);
   hold on;
   plot([0.237 0.237],ylim,'-.k','linewidth',1);
   plot(xlim,[0 0],'-.k','linewidth',1);
   xlabel('Time (sec)','fontsize',18);
   if num == 1
      ylabel('First temporal profile','fontsize',18);
   else
      ylabel('Second temporal profile','fontsize',18);
   end
   set(gca,'fontsize',14);
end