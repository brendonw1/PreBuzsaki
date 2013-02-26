function [spk,tr,cn] = bprintout(fin)

warning off;
load(fin);

f = find(sum(tr')>0);
f = 1:size(tr,1);
tr = tr(f,:);
cn = cn(f);
sz = size(f,2);

if strcmp(fin(end-1:end),'02') | strcmp(fin(end-1:end),'06')
   ind = 6.25;
else
   ind = 1;
end
nr = zeros(sz,size(tr,2));
nt = nr;
mt = nr;
sp = nr;
spk = [];

for c = 1:sz
   nr(c,:) = tr(c,:)-mean(tr(c,:));
   nr(c,:) = nr(c,:)/range(nr(c,:));
   nt(c,:) = dfoverf(tr(c,:));
   k = tr(c,:) - myfilter(tr(c,:),round(1/str2num(fin(end-1:end))*325));
   spk{c} = find(myfilter(k/std([k(find(k>0)) -k(find(k>0))]),2)<-1);
   f = intersect([1 find(k(2:end)-k(1:end-1)<0)+1],[find(k(1:end-1)-k(2:end)<0) size(k,2)]);
   spk{c} = intersect(spk{c},f);
   sp(c,spk{c}) = 1;
   are(c) = poly_area(cn{c})*ind;
end

spk=rast2mat(spk,size(tr,2));


% 
% subplot(3,2,1);
% imagesc(nr);
% set(gca,'ydir','normal');
% colormap(gray.^.5);
% ylabel('cell number');
% title([fin(1:8) ' population activity (normalized)']);
% subplot(3,2,2);
% ylim([0 size(spk,2)]);
% rasterplot(spk);
% xlim([0 size(tr,2)]);
% ylabel('cell number');
% title('Rasterplot (trace-base < -1.5*std)');
% box off;
% subplot(3,2,3);
% plot(mean(nt));
% ylim([-2 2]);
% xlim([0 size(tr,2)]);
% ylabel('mean dF/F/std');
% title('Activity of contours');
% box off;
% subplot(3,2,4);
% h = bar(sum(sp));
% xlim([0 size(tr,2)]);
% ylabel('number of spikes');
% title('Spike time histogram');
% box off;
% 
% a = find(are>5);
% b = find(are<5);
% subplot(3,2,5)
% plot(mean(nt(a,:)));
% ylim([-2 2]);
% xlim([0 size(tr,2)]);
% ylabel('mean dF/F/std');
% title(['Activity of contours > 5 \mum\rm^{2} (' num2str(round(size(a,2)/size([a b],2)*100)/100) ')']);
% box off;
% subplot(3,2,6)
% plot(mean(nt(b,:)));
% ylim([-2 2]);
% xlim([0 size(tr,2)]);
% ylabel('mean dF/F/std');
% title(['Activity of contours < 5 \mum\rm^{2} (' num2str(round(size(b,2)/size([a b],2)*100)/100) ')']);
% box off;
% 
% set(gcf,'paperposition',[.25 .25 8 10.5],'paperorientation','portrait');
% warning on;