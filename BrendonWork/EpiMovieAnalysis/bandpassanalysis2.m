function ons=bandpassanalysis2(pixels,contours,lengths);

tic
warning off MATLAB:conversionToLogical
df=-diff(pixels,1,3);%find difference between each frame and each other frame
clear pixels;%memory management
dflengths=lengths-1;%subtract 1 from the length of each movie listed in lengths;
cl=cumsum(lengths);%find total number of frames upto each movie
df(:,:,cl(1:end-1))=[];%eliminating frames corresponding to transitions between movies;
endmovies=cumsum(dflengths);%find ends of movies
beginmovies=endmovies-(dflengths-1);%find beginnings of movies

for z=1:length(contours);%finding the average size (area) of the contours...
    meanarea(z)=poly_area(contours{z});%first, find the area of each contour
end
meanarea=mean(meanarea);%now take the mean size (in area, not radius)
meandiam=2*((meanarea/pi).^.5);%size in diameter ASSUMING CIRCULAR SHAPE (ON AVERAGE)
%%%%%%%%%%%%!!!!!!!!!!!!DON'T USE 256... USE SIZE.... AND USE IMFEATURE,
%%%%%%%%%%%%NOT INPOLYGON
template=zeros(size(df,1),size(df,2));%will determine which pixels are outside all cells
for contournumber = 1:(length(contours));%for each contour
    for ycounter=1:256;%for each line in the image
        yc=ycounter(ones(1,256));
        in=inpolygon(1:256,yc,contours{contournumber}(:,1),contours{contournumber}(:,2));%a 1D line of 
%                                                                             0's and 1's for all x's across 1 y value
        inmatrix(ycounter,:)=in;%a matrix of the pixels inside a given contour... 2D by the time the for-loop is over
	end
    template=inmatrix+template;%create a template w/ 1's wherever inside a cell, 0 outside... for whole-frame background
end
template=~template;
clear in inmatrix

df2={};%will be used in most of analysis
df3={};%will be used only to find average pixel value across the whole movie
rowselim={};
colselim={};
for a=1:size(df,3);%for each frame in the series
    [frame,rowselim{a},colselim{a}]=elimbadedges(df(:,:,a));%get rid of information-less edges created by aligning process
    df3{a}=frame;
    df10{a}=bandpassimage2(frame,3,10*meandiam);%filter image according to the size of the average contour in that image
    df2{a}=bandpassimage2(frame,3,2*meandiam);%filter image according to the size of the average contour in that image
end

if meandiam>4.66;%if a 40X image
	framenum=0;
	for b=1:length(dflengths);%for each movie;
        movie2=[];
        movie10=[];
        movie3=[];
        for c=1:dflengths(b);%for each frame in that movie
            frame2=df2{beginmovies(b)+c-1};%store the frame of interest
            temp=template;
            temp(:,colselim{beginmovies(b)+c-1})=[];
            temp(rowselim{beginmovies(b)+c-1},:)=[];
            template2=find(temp);%extract only the points for this frame that are not in cells 
            frame2=frame2(template2)';%vector of pixel values from non-cell areas
            framenoise2(c)=std(frame2);%find the noise of that frame
            movie2=cat(2,movie2,frame2);%creating a vector of pixel values across the whole movie 
            frame10=df10{beginmovies(b)+c-1};%store the frame of interest
            frame10=frame10(template2)';%vector of pixel values from non-cell areas
            framenoise10(c)=std(frame10);%find the noise of that frame
            movie10=cat(2,movie10,frame10);%creating a vector of pixel values across the whole movie 
            frame3=df3{beginmovies(b)+c-1};%ALL "3" things calculated here refer to original frames (minus edges) instead of filtered images
            frame3=frame3(template2)';%linear version of pixel values for this frame
            movie3=cat(2,movie3,frame3);%creating a linear sequence of pixel values across the whole movie 
        end
            movienoise2=std(movie2);%get noise estimate for the entire filtered non-edges movie
            moviemean2=mean(movie2);%mean of filtered non-edges movie
            movienoise10=std(movie10);%get noise estimate for the entire filtered non-edges movie
            moviemean10=mean(movie10);%mean of filtered non-edges movie
            movienoise3=std(movie3);%get noise estimate for the non-edges entire movie
            moviemean3=mean(movie3);%find mean pixel value for the non-edges movie
        
        for d=1:dflengths(b);%for each frame in input matrix
            frameconts={};
            framenum=framenum+1;
            frame2=df2{framenum};%take the filtered frame
            frame2=restoreedges(frame2,rowselim{framenum},colselim{framenum},moviemean2);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
            frame2=imfilter(frame2,(ones(5)./25));%filter it
            frame2mean=mean(frame2(1:end));%mean of that frame
            fc2=findmatrixnofig(frame2,moviemean2+1.1*movienoise2,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
            frame10=df10{framenum};%take the filtered frame
            frame10=restoreedges(frame10,rowselim{framenum},colselim{framenum},moviemean10);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
            frame10=imfilter(frame10,(ones(5)./25));%filter it
            frame10mean=mean(frame10(1:end));%mean of that frame            frameconts={};%for later use
            fc10=findmatrixnofig(frame10,moviemean10+1.1*movienoise10,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
%             fc=cat(2,fc2,fc10);
            if ~isempty(fc2) | ~isempty(fc10);%if something detected
                if ~isempty(fc2) & ~isempty(fc10);
                    [trash,keepers]=comparecontours2(fc10,fc2);
                    keepers=~keepers;
                    fc=fc10;
                    for g=1:length(keepers);
                        if keepers(g)==1;
                            fc{1,end+1}=fc2{g};
                        end
                    end
                elseif ~isempty(fc2)
                    fc=fc2;
                else
                    fc=fc10;
                end
%                 fc=fc2;
                origvalues=framecontvalues(df(:,:,framenum),fc);%find the mean pixelvalue of the original df frame inside each contour found
                oi=find(origvalues>moviemean3);%find index numbers of contours where brightness was above average in original movie
                for e=1:length(oi);
                    frameconts(e)=fc(oi(e));%only keep areas representing above average brightness (avoid problem of detecting cells turning "off" which can happen with fft
                end
                ons1=zeros(1,length(contours));
                ons2=zeros(1,length(contours));
	            if ~isempty(frameconts);%if any potential on cells are detected (bright spots of between size listed in last two inputs of findfrommatrix above)
			        [ons1,frameons]=mostincontour(contours,frameconts,frame);%see if any of those found bright regions are inside known cells
			        if sum(frameons)>0;%if any bright spots are in cells
			            ind=find(frameons);
                        frameconts2={};
			            for k=1:length(ind);
			                frameconts2{k}=frameconts{ind(k)};%put contours of the spots that are in cell contours into a new array
			            end
			        [throwaway,ons2]=comparecontours2(frameconts2,contours);%find out all cell contours with centers inside the bright spots... ie including if multiple cells in a spot
                    end         
			    end
       	        ons(framenum,:)=logical(ons1+ons2);
%             figure;highlightons(contours,ons(framenum,:));
            end
        end
	end
else% if meandiam<=4.66
		framenum=0;
	for b=1:length(dflengths);%for each movie;
        movie2=[];
        movie10=[];
        movie3=[];
        for c=1:dflengths(b);%for each frame in that movie
            frame2=df2{beginmovies(b)+c-1};%store the frame of interest
            temp=template;
            temp(:,colselim{beginmovies(b)+c-1})=[];
            temp(rowselim{beginmovies(b)+c-1},:)=[];
            template2=find(temp);%extract only the points for this frame that are not in cells 
            frame2=frame2(template2)';%vector of pixel values from non-cell areas
            framenoise2(c)=std(frame2);%find the noise of that frame
            movie2=cat(2,movie2,frame2);%creating a vector of pixel values across the whole movie 
            frame10=df10{beginmovies(b)+c-1};%store the frame of interest
            frame10=frame10(template2)';%vector of pixel values from non-cell areas
            framenoise10(c)=std(frame10);%find the noise of that frame
            movie10=cat(2,movie10,frame10);%creating a vector of pixel values across the whole movie 
            frame3=df3{beginmovies(b)+c-1};%ALL "3" things calculated here refer to original frames (minus edges) instead of filtered images
            frame3=frame3(template2)';%linear version of pixel values for this frame
            movie3=cat(2,movie3,frame3);%creating a linear sequence of pixel values across the whole movie 
        end
            movienoise2=std(movie2);%get noise estimate for the entire filtered non-edges movie
            moviemean2=mean(movie2);%mean of filtered non-edges movie
            movienoise10=std(movie10);%get noise estimate for the entire filtered non-edges movie
            moviemean10=mean(movie10);%mean of filtered non-edges movie
            movienoise3=std(movie3);%get noise estimate for the non-edges entire movie
            moviemean3=mean(movie3);%find mean pixel value for the non-edges movie
        
        for d=1:dflengths(b);%for each frame in input matrix
            frameconts={};
            framenum=framenum+1;
            frame2=df2{framenum};%take the filtered frame
            frame2=restoreedges(frame2,rowselim{framenum},colselim{framenum},moviemean2);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
            frame2=imfilter(frame2,(ones(3)./9));%filter it
            frame2mean=mean(frame2(1:end));%mean of that frame
            fc2=findmatrixnofig(frame2,moviemean2+1.5*movienoise2,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
            frame10=df10{framenum};%take the filtered frame
            frame10=restoreedges(frame10,rowselim{framenum},colselim{framenum},moviemean10);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
            frame10=imfilter(frame10,(ones(5)./25));%filter it
            frame10mean=mean(frame10(1:end));%mean of that frame            frameconts={};%for later use
            fc10=findmatrixnofig(frame10,moviemean10+1.5*movienoise10,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
%             fc=cat(2,fc2,fc10);
            if ~isempty(fc2) | ~isempty(fc10);%if something detected
                if ~isempty(fc2) & ~isempty(fc10);
                    [trash,keepers]=comparecontours2(fc10,fc2);
                    keepers=~keepers;
                    fc=fc10;
                    for g=1:length(keepers);
                        if keepers(g)==1;
                            fc{1,end+1}=fc2{g};
                        end
                    end
                elseif ~isempty(fc2)
                    fc=fc2;
                else
                    fc=fc10;
                end
%                 fc=fc2;
                origvalues=framecontvalues(df(:,:,framenum),fc);%find the mean pixelvalue of the original df frame inside each contour found
                oi=find(origvalues>moviemean3);%find index numbers of contours where brightness was above average in original movie
                for e=1:length(oi);
                    frameconts(e)=fc(oi(e));%only keep areas representing above average brightness (avoid problem of detecting cells turning "off" which can happen with fft
                end
                ons1=zeros(1,length(contours));
                ons2=zeros(1,length(contours));
	            if ~isempty(frameconts);%if any potential on cells are detected (bright spots of between size listed in last two inputs of findfrommatrix above)
			        [ons1,frameons]=mostincontour(contours,frameconts,frame);%see if any of those found bright regions are inside known cells
			        if sum(frameons)>0;%if any bright spots are in cells
			            ind=find(frameons);
                        frameconts2={};
			            for k=1:length(ind);
			                frameconts2{k}=frameconts{ind(k)};%put contours of the spots that are in cell contours into a new array
			            end
			        [throwaway,ons2]=comparecontours2(frameconts2,contours);%find out all cell contours with centers inside the bright spots... ie including if multiple cells in a spot
                    end         
			    end
       	        ons(framenum,:)=logical(ons1+ons2);
%             figure;highlightons(contours,ons(framenum,:));
            end
        end
	end
end
onslength=size(df,3)-(size(lengths,2)-1);
if size(ons,1)<onslength;
    ons(onslength,:)=zeros(1,size(contours,2));
end



toc