ma1=max(max(max(df(:,:,1:19))));
mi1=min(min(min(df(:,:,1:19))));
for a=1:8;
    ma(a)=max(max(df2{a}));
    mi(a)=min(min(df2{a}));
end
ma2=ma;
mi2=mi;
mi2=min(mi2);
ma2=max(ma2);

for a=5:-1:1;
figure('position',[4 502 1275 420],'numbertitle','off','name',['Frame ',num2str(a)]);
subplot(1,3,1);
imagesc(df(:,:,a),[mi1 ma1])
axis equal
colormap gray
subplot(1,3,2);
imagesc(df2{a},[mi2 ma2])
axis equal
colormap gray
subplot(1,3,3);
highlightons(contours,ons(a,:))
axis equal
end