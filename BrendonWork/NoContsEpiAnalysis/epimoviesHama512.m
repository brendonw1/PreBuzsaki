function ons=epimovies(pixels,zgroupsize,contours,threshvalue,varargin);
% varargin will determine lengths
% Finds calcium events from cells in epifluorescent movies that are concatenated
% together, output is a matrix of 1's and 0's, ones representing which frame a neuron turned on. 
% Takes 3D pixels file (grayscale) from a series of movies (x by y by frames), contours of
% known cells (as in from findcells), an arbitrary brightness threshold
% value which will dictate a number of standard deviations above the mean
% for event detection (usually 1.7) and possibly a list of the lengths (in frames) of
% the concatenated movies.  If no lengths are specified, it is assumed that
% the whole pixels input variable is a single movie.
% Output, ons, is in the format frame# x cell# and is a logical array of
% 1's and 0's.

tic
warning off 

pixels = double(pixels);

pixels = groupedzprojector(pixels,zgroupsize,'mean');%project multiple frames into 1
%take from 512x512 to 256x256... but slow now
sz = size(pixels);
pixels = reshape(pixels,[sz(1) sz(2)*sz(3)]);
pixels = im2col(pixels,[2 2],'distinct');
pixels = mean(pixels);
pixels = reshape(pixels,[256 256 sz(3)]);
%note, will now need to shrink contours to 1/2 their original size... see
%first contours loop.

if isempty(varargin);%may or may not have entered lengths, if not...
    lengths=size(pixels,3);%assume only one movie is being analyzed and make lengths=the length of the input pixels matrix
else%if something was entered as lengths
    lengths=varargin{1};%name it appropriately
end

ons=zeros(size(pixels,3)-1,length(contours));
img=pixels(:,:,1);
df=-diff(pixels,1,3)./pixels(:,:,1:(end-1));
dflengths=lengths-1;%subtract 1 from the length of each movie listed in lengths;
df(isnan(df))=0;
clear pixels%memory management
cl=cumsum(lengths);%find total number of frames upto each movie
df(:,:,cl(1:end-1))=[];%eliminating frames corresponding to transitions between movies;
endmovies=cumsum(dflengths);%find ends of movies
beginmovies=endmovies-(dflengths-1);%find beginnings of movies

for z=1:length(contours);%finding the average size (area) of the contours...
    contours{z} = contours{z}/2;%shinking here because we shrunk the image by 1/2;
    meanarea(z)=poly_area(contours{z});%first, find the area of each contour
end
small=2*((min(meanarea)/pi).^.5);%find the area of the smallest contour
big=2*((max(meanarea)/pi).^.5);%find the area of the biggest contour
meanarea=mean(meanarea);%now take the mean size (in area, not radius)
meandiam=2*((meanarea/pi).^.5);%size in diameter ASSUMING CIRCULAR SHAPE (ON AVERAGE)
clear meanarea

knowncells=contourstomasks(contours,size(img));%take contours, turn them into masks for each cell
template=zeros(size(img));
for a=1:length(knowncells);
    template(knowncells{a})=1;%generate a template of where cells are
end
template=~template;%invert to generate a template of where cells aren't (for background noise measurement).

% df2={};%will be used in most of analysis... storing filtered images
% ?df3={};%will be used only to find average pixel value across the whole movie
% rowselim={};
% colselim={};
% for a=1:size(df,3);%for each frame in the series
%     [frame,rowselim{a},colselim{a}]=elimbadedges(df(:,:,a));%get rid of information-less edges created by aligning process
% %     ?df3{a}=frame;%store bad edges-less part of the raw df frame in a cell
%     frame=bwbpimage2(frame,small,big);%filter image according to the size of the average contour in that image
%     df2{a}=imfilter(frame,(ones(5)./25));%run a 5x5 filter over the image, to clean up artifacts of filtering... then store as an element of a cell
% end
% df2 = df;
% clear df%memory management

% if meandiam>4.66;%if a 40X image
%     %what changes: streltype? strelsize? minobj, maxobj
    minobj=32;%defines the smallest acceptable size (in pixels) of a bright object in a df image, which might represent a cellular calcium transient
    maxobj=1000;%defines the largest
	streltype='disk';
    strelsize=1;
    framenum=0;
    for c = 1:size(df,3);%filter each frame... can do faster
%         df(:,:,c) = imfilter(df(:,:,c),(ones(3)./9));%run a 3x3 filter
        df(:,:,c) = bwbpimage2(df(:,:,c),small,big*2);%filter image according
    end
	for b=1:length(dflengths);%for each movie;
        movie = df(:,:,beginmovies(b):endmovies(b));
        movietemplate = logical(repmat(template,[1 1 dflengths(b)]));%find all non-cell background pixels in movie

        backmovie = movie(movietemplate);%extract those values
        framebckgds = reshape(backmovie,[sum(sum(template)) size(movie,3)]);%reshape to take mean
        framebckgds = mean(framebckgds,1);%get mean background of each frame
        framebckgds = reshape(framebckgds,[1 1 size(framebckgds,2)]);%reshape to put frame num in 3rd dim (For repmat)
        framebckgds = repmat(framebckgds,[256 256 1]);%make size/shape of movie
        movie = movie-framebckgds;%subtract background brightness from each frame
        clear backmovie framebckgds
                
        tempmovie = df(movietemplate);%get all background values for new "normalized" movie
        movienoise=std(tempmovie);%get noise estimate for the entire filtered non-edges movie
        moviemean=mean(tempmovie);%mean of filtered non-edges movie
        clear tempmovie movietemplate
        thresh=threshvalue*movienoise+moviemean;% brightness threshold, user input

%         movie=[];%establish blank matrix for a movie
%         for c=1:dflengths(b);%for each frame in that movie
%             thisframe=beginmovies(b)+c-1;
%             frame=df(:,:,thisframe);%store the frame of interest
% %             temp=template;%take template of non-cell pixels for manipulations in next few lines
% %             temp(:,colselim{thisframe})=[];%eliminate parts of template that are not relevant for this frame (according to which lines were eliminated)
% %             temp(rowselim{thisframe},:)=[];%same but other dimension
%             frame = imfilter(frame
%             frame=frame(logical(template))';%vector of pixel values from non-cell areas
%             movie=cat(2,movie,frame);%creating a vector of pixel values across the whole movie
%         end

        for d=1:dflengths(b);%for each frame in current movie
            framenum=framenum+1;%count to next frame... was 0 before start
            disp(['Frame ',num2str(framenum)])
            frame=df(:,:,framenum);%take the filtered frame
%             frame=bwbpimage2(frame,small,big*2);%filter image according
            %     to the size of the average contour in that image
%             frame=imfilter(frame,(ones(3)./9));%run a 5x5 filter
            %     over the image, to clean up artifacts of filtering... then store as an element of a cell
%             frame=restoreedges(frame,rowselim{framenum},colselim{framenum},moviemean);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
%             df3(:,:,framenum)=frame;
            fm=objectdetector(frame,thresh,streltype,strelsize,minobj,maxobj);%find objects in img, that are at least Xsd above the mean in brightness and are between 6 and 250 pixels large
            if ~isempty(fm);%if some objects found
                [trash,frameons]=centroidoverlapmasks(fm,knowncells,img);%if a bright spot in this df image overlaps with the centroid of a known cell, record that cell as on
                ons(framenum,:)=frameons;
            end
        end
    end
% end
ons=keepfirstonframe(ons);%keep only beginning of each signal in each cell... don't allow to say a cell was on more than one frame in a row.

toc