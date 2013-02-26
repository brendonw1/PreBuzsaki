function df0focus5frames(movienumber,cutoff,areath)

h=input ('is name of background image "focus.tif"?  1 for yes, 0 for no: ');


if h==1;
    figure(1003);
    b = imread('focus.tif');
else
    n = input ('enter name of file, including exptension: ','s');
    figure(1003);
    b = imread (n);
end


basename='positive';
tifsuffix='.tif';
numberofframes=5;
framenumber=1;
moviematrix=zeros(256,256,numberofframes);

while framenumber <=numberofframes; 
    moviestring = num2str(movienumber);
    framestring = num2str(framenumber);
    filename = strcat(moviestring,basename,framestring,tifsuffix); 
    
    moviematrix(:,:,framenumber) = imread(filename);
    
    framenumber = framenumber+1;
end

df0matrix(:,:) = moviematrix(:,:,numberofframes)-moviematrix(:,:,1);
% newfilename = strcat(moviestring,df0,tifsuffix);
% df0matrix = single (df00matrix);
% imwrite(df0matrix,newfilename,'tif','Compression','none');

b(:,2)=33000;
b(:,35)=33000;
b(:,68)=33000;
b(:,101)=33000;
b(:,133)=33000;
b(:,167)=33000;
b(:,200)=33000;
b(:,233)=33000;


b(26,:)=33000;
b(58,:)=33000;
b(92,:)=33000;
b(125,:)=33000;
b(158,:)=33000;
b(191,:)=33000;
b(224,:)=33000;


figure(1003);
imagesc(b);
colormap(gray)
set(gcf,'position',[1, 29, 1024, 672]);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[C h] = contour(df0matrix,[cutoff cutoff],'-r');
a = {};
for c = 1:size(h,1);
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:);
      if poly_area(round(coords(1:end-1,:))) > areath;
         a{size(a,2)+1} = coords(1:end-1,:);
      else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end





% % yb = imread('lim.tif');
% 
% [c h] = contour(yb,[cutoff cutoff],'-r');
% a = {};
% for c = 1:size(h,1);
%    coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
%    if coords(1,:) == coords(end,:);
%       if poly_area(round(coords(1:end-1,:))) > areath;
%          a{size(a,2)+1} = coords(1:end-1,:);
%       else
%          delete(h(c));
%       end
%    else
%       delete(h(c));
%    end
% end
% 
% 
% 
% 
% 
% imagesc(b);
% colormap(gray);
% set(gcf,'position',[1, 29, 1024, 672]);
% set(gca,'ydir','reverse');
% axis equal;
% axis off;
% hold on;
% 
