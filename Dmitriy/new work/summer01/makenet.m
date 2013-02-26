function [conns,tshort,ncells,nmore2] = makenet(fin)

text2spikes(fin,[ondesk 'spikes.mat']);
fprintf('\n');
load([ondesk 'spikes.mat']);
set(gcf,'position',[1          29        1024         672]);
ncells = size(spk,2);
for c = 1:size(spk,2)
   isb(c) = size(spk{c},2);
end
nmore2 = size(find(isb>2),2);
for c = 1:size(spk,2)
   for d = c:size(spk,2)
      subplot('position',[(c-1)/size(spk,2) (d-1)/size(spk,2) 1/size(spk,2) 1/size(spk,2)]);
      xlim([-1 1]);
      ylim([-1 1]);
      [m(c,d) v(c,d)] = corind(spk,c,d,5,100,'int',ttot+1);
      m(c,d) = m(c,d)+0.0001;
      tx = text(0,0,num2str(m(c,d)-0.0001),'horizontalalignment','center');
      if m(c,d) < 0.1 & ~(c==d)
         set(tx,'color',[0 0 1]);
         axis off;
         drawnow;
         [m(c,d) v(c,d)] = corind(spk,c,d,5,10000,'int',ttot+1);
         m(c,d) = m(c,d)+0.0001;
         set(tx,'string',num2str(m(c,d)-0.0001));
         if m(c,d) < 0.0501
            set(tx,'color',[1 0 0]);
         end
      end
      axis off;
      drawnow;
   end
end
delete(gcf);
m = m-2*eye(size(m,1));
[i j] = find(m>0 & m<0.05);
[x y] = diode(pos);
nshort = 0;
conns = [];
for c = 1:size(i,1)
   conns(c,:) = [i(c) j(c) m(i(c),j(c))-0.0001 v(i(c),j(c))*dt sqrt((x(i(c))-x(j(c)))^2+(y(i(c))-y(j(c)))^2)];
end
n = [];
for c = 1:size(x,2)
   for d = 1:c-1
      n = [n sqrt((x(c)-x(d))^2+(y(c)-y(d))^2)];
   end
end
tshort = size(find(n<26),2);