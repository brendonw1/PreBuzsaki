function showzplots(cutoff,areath)
% draws contours around an image, then allows you go to Image J to run
% "Read Traces" and come back go matlab.  Hit any key after that and you'll
% be shown the traces of brightness vs. time of ALL contours generated in
% the earlier part of the file... along with the contour corresponding to
% that cell drawn onto the original image (with a grid).

global b
global b2
global a
global c
%, b2, a, c

%lst = findcells(fin, cutoff,areath)
%   reads in an image file, detects cells with a given cutoff, and
%   outputs a cell array containing coordinates of all contours

b = imread('lim.tif');
b2=b;

b2(:,2)=0;
b2(:,35)=0;
b2(:,68)=0;
b2(:,101)=0;
b2(:,133)=0;
b2(:,167)=0;
b2(:,200)=0;
b2(:,233)=0;


b2(26,:)=0;
b2(58,:)=0;
b2(92,:)=0;
b2(125,:)=0;
b2(158,:)=0;
b2(191,:)=0;
b2(224,:)=0;
% % b2 is used to render an image... the inserted 0 values displays a matrix
% % that replicates the one in the eyepiece of the microscope under 4X
% % objective

figure(20000);
imagesc(b);
colormap(gray);
set(gcf,'position',[1, 29, 1024, 672]);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[c h] = contour(b,[cutoff cutoff],'-r');%%all contours drawn onto the background of the input image
a = {};
for c = 1:size(h,1);
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:);
      if poly_area(round(coords(1:end-1,:))) > areath; %%contours which are too small are thrown out
         a{size(a,2)+1} = coords(1:end-1,:); %%all contours that are large enough are kept in a cell array (array of matrices)
      else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end
%delete(gcf);

g = input('Do you want to save these traces?  1 for "yes", 0 for "no": '); %%gives a chance to end the program and set new contour parameters
if g==0;
    disp ('you may re-run progam with new parameters')
elseif g==1;
        
	% function cell2file(a,fout)
	% %cell2file(a,fout)
	% %   writes a contour coordinate cell array into a .ccf file
	
	fid = fopen('cont.cnt','w');
	fwrite(fid,size(a,2),'double');
	for c = 1:size(a,2);
       a{c} = round(a{c});
       for m = 1:size(a{c},1)-1;
          for n = m+1:size(a{c},1);
             if a{c}(m,:) == a{c}(n,:);
                a{c}(n,1) = 100000;
             end
          end
       end
       f = find(a{c}(:,1)<100000);
       a{c} = a{c}(f,:);
       fwrite(fid,size(a{c},1),'double');
       fwrite(fid,a{c}','double');
	end
	fclose('all');
	filerev('cont.cnt',8);
	
	disp('run "Read Traces" on movie of interest in ImageJ, then return to this screen and hit any key')
	pause;
	
	% function a = file2trace(fin)
	% %a = file2trace(fin)
	% %   converts a *.trc files into a trace matrix
	
	filerev('traces.trc',8);
	fid = fopen('traces.trc');
	nc = fread(fid,1,'double');
	ns = fread(fid,1,'double');
	v = fread(fid,[ns nc],'double');
	c = v';
	filerev('traces.trc',8);
	
	%function showzplot(image,conts,zvalues)
	
	[n,p]=size(c);
	i=1;
	while i<=n ; %%plotting the brightness vs frame graph of each contour, along with a drawing of 
                    %%that contour onto the original image
        figure(i);
		set(gcf,'position',[1, 29, 1024, 672]);
		%     m=imread('lim.tif'); 
		subplot(2,1,1); imagesc(b2);
		colormap(gray);
		axis equal;
		axis off;
		hold on;
		subplot(2,1,1); plot(a{i}(:,1),a{i}(:,2),'-r') ;
		subplot(2,1,2); plot(1:p,c(i,:));
		i=i+1;
	end
else 
    disp ('enter 1 for "yes" and 0 for "no"')
end