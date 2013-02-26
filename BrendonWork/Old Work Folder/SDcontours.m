function lst=SDcontours(moviematrix,cutoff,areath)
% uses "labelcells" ("findcells" but also labels each contour with it's number
% to find traces of cells with large standard deviations
% in brightness.  Standard deviations are determined over each movie within
% the matrix... ie each pixel is analyzed over all the frames of a given
% movie to find it's sd... an image of sd's is made from each movie.  The
% resulting sd images from each movie are then averaged, to make a master
% image for each group of movies.  Then "labelcells" is called upon to find
% contours of areas with high standard devs.

%moviematrix must be in the following form: (x-coord) x (y-coord) x (frame
%number) x (movie number)

devs(:,:,1:size(moviematrix,4))=std(moviematrix(:,:,:,1:size(moviematrix,4)),1,3);
devs=mean(devs,3);
% 
% devs2=devs(1:(size(devs,1)*size(devs,2)));
% cutoff=mean(devs2)+std(devs2);

imagesc(devs);
colormap(gray);
set(gca,'ydir','reverse');
axis equal;
axis off;
hold on;
[c h] = contour(devs,[cutoff cutoff],'-r');
lst = {};
for c = 1:size(h,1)
   coords = [get(h(c),'xdata')' get(h(c),'ydata')'];
   if coords(1,:) == coords(end,:);
      if poly_area(round(coords(1:end-1,:))) > areath
         lst{size(lst,2)+1} = coords(1:end-1,:);
         label=num2str(size(lst,2));
         text(coords(1,1),coords(1,2),label);
      else
         delete(h(c));
      end
   else
      delete(h(c));
   end
end
