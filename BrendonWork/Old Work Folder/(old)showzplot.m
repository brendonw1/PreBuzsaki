function showzplot(image,conts,zvalues,i)

[n,p]=size(zvalues);
figure(i);
set(gcf,'position',[1, 29, 1024, 672])
m=imread(image,'tif');
subplot(2,1,1);imagesc(m);
colormap(gray);
axis equal;
axis off;
hold on;
subplot(2,1,1); plot(conts{i}(:,1),conts{i}(:,2),'-p');
subplot(2,1,2); plot(1:p,zvalues(i,:));