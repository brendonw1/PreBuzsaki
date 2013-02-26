function rastermakerunsorted300(t,s,c);
%t is trig ons
%s is spont ons
%c is core ons

figure

[row,trash]=find(c);
row=max(row);
row=size(c,1)-row;
numb=3;
xw=.3;
yw=.005;
frames=size(c,2);

t(1:26,:)=c(1:26,:);
s(1:26,:)=c(1:26,:);

s(300,1)=0;
t(300,1)=0;
c(300,1)=0;

k=randperm(size(c,1));
for a=1:length(k);
    c2(a,:)=c(k(a),:);
end
for a=1:length(k);
    t2(a,:)=t(k(a),:);
end
for a=1:length(k);
    s2(a,:)=s(k(a),:);
end

c=c2;
s=s2;
t=t2;

c=keepfirstonevent(c');
t=keepfirstonevent(t');
s=keepfirstonevent(s');
c=c';
s=s';
t=t';
c=keepfirstonframe(c');
t=keepfirstonframe(t');
s=keepfirstonframe(s');
c=c';
s=s';
t=t';


ons=t;%accounting for fact that this program was written when ons was inverted
ons=flipdim(ons,1);
% ons=insertrows(ons,row,numb);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
color='black';
hold on;

for y=1:size(b)%for each cell
    patch([b(y)-yw b(y)+yw b(y)+yw b(y)-yw],[a(y)-xw a(y)-xw a(y)+xw a(y)+xw],color,'edgecolor',color);%plotting a vertical line at each point 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
ons=s;%accounting for fact that this program was written when ons was inverted
ons(:,(frames+2):(frames*2+1))=ons;
ons(:,1:frames)=0;
ons=flipdim(ons,1);
% ons=insertrows(ons,row,numb);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
color='green';
hold on;
for y=1:size(b)%for each cell
    patch([b(y)-yw b(y)+yw b(y)+yw b(y)-yw],[a(y)-xw a(y)-xw a(y)+xw a(y)+xw],color,'edgecolor',color);%plotting a vertical line at each point 
end

%%%%%%%%%%%%%%%%%%%%%%%%%
ons=c;%accounting for fact that this program was written when ons was inverted
% ons(:,(frames*2+3):(frames*3+2))=ons;
% ons(:,1:frames)=0;
ons=flipdim(ons,1);
% ons=insertrows(ons,row,numb);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
color='red';
hold on;
for y=1:size(b)%for each cell
    patch([b(y)-yw b(y)+yw b(y)+yw b(y)-yw],[a(y)-xw a(y)-xw a(y)+xw a(y)+xw],color,'edgecolor',color);%plotting a vertical line at each point 
end

%%%%%%%%%%%%%%%%%%%%%%%%%
ons=c;%accounting for fact that this program was written when ons was inverted
ons(:,(frames+2):(frames*2+1))=ons;
ons(:,1:frames)=0;
ons=flipdim(ons,1);
% ons=insertrows(ons,row,numb);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
color='red';
hold on;
for y=1:size(b)%for each cell
    patch([b(y)-yw b(y)+yw b(y)+yw b(y)-yw],[a(y)-xw a(y)-xw a(y)+xw a(y)+xw],color,'edgecolor',color);%plotting a vertical line at each point 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

ons=c;%accounting for fact that this program was written when ons was inverted
ons(:,(frames*2+3):(frames*3+2))=ons;
ons(:,1:frames)=0;
ons=flipdim(ons,1);
% ons=insertrows(ons,row,numb);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
color='red';
hold on;
for y=1:size(b)%for each cell
    patch([b(y)-yw b(y)+yw b(y)+yw b(y)-yw],[a(y)-xw a(y)-xw a(y)+xw a(y)+xw],color,'edgecolor',color);%plotting a vertical line at each point 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot([0 14.5],[row+numb/2 row+numb/2],'k')
plot([frames+1 frames+1],[0 size(c,1)+numb+.5],'k')
plot([2*frames+2 2*frames+2],[0 size(c,1)+numb+.5],'k')
xlim([0 14.5]);
ylim([0 300.5]);