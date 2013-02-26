function keepermatrix=comparecontours(cutoff,areath,numberofmovies)
% Compares contours found by using "contours" by Dmitriy Aronov (using his
% "cutoff" and "areath" parameters) on multiple individual frames (number of frames is equal to
% "numberofmovies" parameter).  Repetitive contours are discarded, so that
% contours of all individual areas that are found in an individual frames
% are put together into a single output matrix.  
%   Comparison is done by asking whether the "centroid" of a given contour
% is within any other contour from any other frame... if it is, it is
% thrown out, if there is not such overlap, the contour is put into the
% large output matrix of contours.


movienumber=1;
% allow to enter basefilename and file type
basename='031203#3';
tifsuffix='SDfft3.tif';

zprojectmatrix=zeros(256,256,numberofmovies);

while movienumber <= numberofmovies;
    moviestring = num2str(movienumber);
    filename = strcat(basename,moviestring,tifsuffix); 
    zprojectmatrix(:,:,movienumber) = imread(filename);
    
    movienumber=movienumber+1;
end
% Bringing in saved frames


% % colormap(gray);
% % set(gcf,'position',[1, 29, 1024, 672]);
% % set(gca,'ydir','reverse');
% % axis equal;
% % axis off;
% % hold on;

for movienumber=1:numberofmovies;
%     figure(movienumber);
    [c h] = contour(zprojectmatrix(:,:,movienumber),[cutoff cutoff],'-r');
    for cellfiller = 1:length(h);
		coords{cellfiller}= [get(h(cellfiller),'xdata')' get(h(cellfiller),'ydata')'];        
        area(cellfiller) = poly_area(round(coords{cellfiller}(1:end-1,:)));
	end
    smalls = find (area<areath);
    bigenoughs=celldelete(coords,smalls);
    
    centroidsmatrix=[];
    for centroidsfiller = 1:length(bigenoughs);
        centroidsmatrix(centroidsfiller,:)=centroid(bigenoughs{centroidsfiller});
    end

    if movienumber==1;
        keepermatrix = bigenoughs;
        figure(10)
        plot (centroidsmatrix (:,1),centroidsmatrix(:,2),'o')
        axis([0 255 0 255])
        
    else 
        for polygonnumb = 1:(length(keepermatrix));
            in=inpolygon(centroidsmatrix(:,1),centroidsmatrix(:,2),keepermatrix{polygonnumb}(:,1),keepermatrix{polygonnumb}(:,2));
            if polygonnumb==1;
                finalin=in;
            else
                finalin=finalin+in;    
            end    
         end
         for n = 1:prod(size(finalin));
            if finalin(n)==0;
                keepermatrix{length(keepermatrix)+1}=bigenoughs{n};
            end
         end    
     end
     
close
end

whos

% % figure(20)
% % plot (keepermatrix{19}(:,1),keepermatrix{19}(:,2))
% % plot (keepermatrix{18}(:,1),keepermatrix{18}(:,2)) 
% % axis([0 255 0 255])
% % 
% % figure(30)
% % plot (centroidsmatrix (:,1),centroidsmatrix(:,2),'o')
% % axis([0 255 0 255])
% % 
% % 
% % for centroidsfiller = 1:length(keepermatrix);
% %     centroids2(centroidsfiller,:)=centroid(keepermatrix{centroidsfiller});
% % end
% % 
% % figure(40)
% % plot (centroids2 (:,1),centroids2(:,2),'o')
% axis([0 255 0 255])

% Finding contours (of areas over a certain threshold 
% brightness (=cutoff) and of a certain minimum area (=areath))
% from inputted frames, putting them into "coordsmatrix".
% Then a matrix of centroids of the contours is created:
% "centroidsmatrix".
