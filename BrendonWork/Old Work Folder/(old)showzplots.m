function showzplot(image,conts,zvalues)

[n,p]=size(zvalues);
i=1;
while i<=n 
    figure(i);
    set(gcf,'position',[1, 29, 1024, 672])
    m=imread(image,'tif');
    subplot(2,1,1);imagesc(m);
    colormap(gray);
    axis equal;
    axis off;
    hold on;
    subplot(2,1,1); plot(conts{i}(:,1),conts{i}(:,2),'-p') ;
    subplot(2,1,2); plot(1:p,zvalues(i,:));
    i=i+1;
end