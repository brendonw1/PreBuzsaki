function graphsingleactives(numberofmovies,numberofframes,cutoff,areath)

movienumber=1;
basename='positive';
tifsuffix='.tif';
df0='df0';

moviematrix=zeros(256,256,numberofframes,numberofmovies);

counter=1;

while movienumber <= numberofmovies;
    framenumber=1;
    while framenumber <=numberofframes; 
        moviestring = num2str(movienumber);
        framestring = num2str(framenumber);
        filename = strcat(moviestring,basename,framestring,tifsuffix); 
    
        moviematrix(:,:,framenumber,movienumber) = imread(filename);
    
        framenumber = framenumber+1;
    end
    movienumber=movienumber+1;
end
df0matrix = moviematrix(:,:,numberofframes,:)-moviematrix(:,:,1,:);
df0matrix = squeeze (df0matrix);

%     newfilename = strcat(moviestring,df0,tifsuffix);
%     imwrite(df0matrix,newfilename,'tif','Compression','none');
%     

movienumber =1;
while movienumber <= numberofmovies;
	figure(movienumber);
	imagesc(df0matrix(:,:,movienumber));
	colormap(gray)
	set(gcf,'position',[1, 29, 1024, 672]);
	set(gca,'ydir','reverse');
	axis equal;
	axis off;
	hold on;
    
 	[c h] = contour(df0matrix(:,:,movienumber),[cutoff cutoff],'-r');
    coords = {}
    coords{INDEX} = [get(h(,'xdata')', get(h,'ydata')'];
    sizearray(i) = polyarea(coords);
    sizearray = sort(sizearray);
    sizearray = (size(sizearray)-2:size(sizearray)); 
    
% 	a = {};
% 
%     
% 	for g = 1:size(h,1);
%        coords = [get(h(g),'xdata')' get(h(g),'ydata')'];
%        if coords(1,:) == coords(end,:);
%           if poly_area(round(coords(1:end-1,:))) > areath;
%              a{size(a,2)+1} = coords(1:end-1,:);
%           else
%              delete(h(g));
%           end
%        else
%           delete(h(g));
%        end
% 	end
	

	if counter==5 
        g=input ('do you want to continue?  1 for yes, 0 for no. :');
        if g==1;
            counter=0;
        else
            movienumber=numberofmovies+5;
        end
	end
	counter=counter+1;
	movienumber=movienumber+1;
end


whos
% z=[get(h(1),'xdata')'] 
% n=[get(h(1),'ydata')']









% (maybe find two contours per movie... then save into a big matrix... then save that matrix, then access certain elements)
    

% movienumber=16;
% while movienumber <= numberofmovies;
% 
% 
%     movienumber=movienumber+1;
% end



% then show figure of last frame with contours... label with movie number
% 
% later... apply same contours found in each movie to all other movies...
% look for repeaters?