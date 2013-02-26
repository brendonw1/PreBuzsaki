function ons=bandpassanalysis(pixels,contours,lengths);

tic
warning off MATLAB:conversionToLogical
df=-diff(pixels,1,3);
dflengths=lengths-1;%subtract 1 from the length of each movie listed in lengths;
cl=cumsum(lengths);
df(:,:,cl(1:end-1))=[];%eliminating frames corresponding to transitions between movies;
endmovies=cumsum(dflengths);
beginmovies=endmovies-(dflengths-1);

for z=1:length(contours);%finding the average size (area) of the contours
    meanarea(z)=poly_area(contours{z});
end
meanarea=mean(meanarea);%size in area
meandiam=2*((meanarea/pi).^.5);%size in diameter ASSUMING CIRCULAR SHAPE (ON AVERAGE)


df2={};%will be used in most of analysis
df3={};%will be used only to find average pixel value across the whole movie
rowselim={};
colselim={};
for a=1:size(df,3);%for each frame in the series
    [frame,rowselim{a},colselim{a}]=elimbadedges(df(:,:,a));%get rid of information-less edges created by aligning process
    df3{a}=frame;
    df2{a}=bandpassimage(frame,1.2*meandiam);%filter image according to the size of the average contour in that image
%     !!!replace with bpimage2
end

if meandiam>4.66;
	framenum=0;
	for b=1:length(dflengths);%for each movie;
        movie2=[];
        movie3=[];
        for c=1:dflengths(b);%for each frame in that movie
            frame2=df2{beginmovies(b)+c-1};
            frame2=frame2(1:end);%linear version of pixel values for this frame
            framenoise2(c)=std(frame2);
            movie2=cat(2,movie2,frame2);%creating a linear sequence of pixel values across the whole movie 
            movienoise2=std(movie2);%get noise estimate for the entire movie
            moviemean2=mean(movie2);
            frame3=df3{beginmovies(b)+c-1};%ALL "3" things calculated here refer to original frames (minus edges)
            frame3=frame3(1:end);%linear version of pixel values for this frame
            movie3=cat(2,movie3,frame3);%creating a linear sequence of pixel values across the whole movie 
            movienoise3=std(movie3);%get noise estimate for the entire movie
            moviemean3=mean(movie3);%find mean pixel value for the movie
        end
        for d=1:dflengths(b);%for each frame in input matrix
            framenum=framenum+1;
            frame=df2{framenum};
            frame=restoreedges(frame,rowselim{framenum},colselim{framenum},moviemean2);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
	% 	    if meandiam>2.33;
                frame=imfilter(frame,(ones(5)./25));
	%         else
	%             frame=imfilter(frame,(ones(5)./25));
%             end
            framemean=mean(frame(1:end));
            frameconts={};
            fc=findmatrixnofig(frame,moviemean2+2.5*movienoise2,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
%             figure;colormap gray;imagesc(df3{framenum});
%             nm=num2str(framenoise2(d));
%             title (nm)
            if ~isempty(fc);
%                 linframe=df3{framenum};
%                 linframe=mean(linframe(1:end));
                origvalues=framecontvalues(df(:,:,framenum),fc);%find the mean pixelvalue of the original df frame inside each contour found
                oi=find(origvalues>moviemean3);%find index numbers of contours where brightness was above average in original movie
                for e=1:length(oi);
                    frameconts(e)=fc(oi(e));%only keep areas representing above average brightness (avoid problem of detecting cells turning "off" which can happen with fft
                end
                ons1=zeros(1,length(contours));
                ons2=zeros(1,length(contours));
	%             if ~isempty(frameconts);%if any potential on cells are detected (bright spots of between size listed in last two inputs of findfrommatrix above)
			        [ons1,frameons]=mostincontour(contours,frameconts,frame);%see if any of those found bright regions are inside known cells
			        if sum(frameons)>0;%if any bright spots are in cells
			            ind=find(frameons);
                        frameconts2={};
			            for k=1:length(ind);
			                frameconts2{k}=frameconts{ind(k)};%put contours of the spots that are in cell contours into a new array
			            end
			        [throwaway,ons2]=comparecontours2(frameconts2,contours);%find out all cell contours with centers inside the bright spots... ie including if multiple cells in a spot
                    end         
	% 		    end
       	    ons(framenum,:)=logical(ons1+ons2);
%             figure;highlightons(contours,ons(framenum,:));
            end
        end
	end
end

if meandiam<=4.66;
	framenum=0;
	for b=1:length(dflengths);%for each movie;
        movie2=[];
        movie3=[];
        for c=1:dflengths(b);%for each frame in that movie
            frame2=df2{beginmovies(b)+c-1};
            frame2=frame2(1:end);%linear version of pixel values for this frame
            framenoise2(c)=std(frame2);
            movie2=cat(2,movie2,frame2);%creating a linear sequence of pixel values across the whole movie 
            movienoise2=std(movie2);%get noise estimate for the entire movie
            moviemean2=mean(movie2);
            frame3=df3{beginmovies(b)+c-1};
            frame3=frame3(1:end);%linear version of pixel values for this frame
            movie3=cat(2,movie3,frame3);%creating a linear sequence of pixel values across the whole movie 
            movienoise3=std(movie3);%get noise estimate for the entire movie
            moviemean3=mean(movie3);%find mean pixel value for the movie
        end
        for d=1:dflengths(b);%for each frame in input matrix
            framenum=framenum+1;
            frame=df2{framenum};
            frame=restoreedges(frame,rowselim{framenum},colselim{framenum},moviemean2);%restore the eliminated edges, so each frame is the original size again (256x256 usually)        
	% 	    if meandiam>2.33;
                frame=imfilter(frame,(ones(3)./9));
	%         else
	%             frame=imfilter(frame,(ones(5)./25));
%             end
            framemean=mean(frame(1:end));
            frameconts={};
            fc=findmatrixnofig(frame,moviemean2+2.5*movienoise2,meandiam+1.5,1000);%use contours to detect regions of brightness (calcium change);
%             hold on;plotfromcontours(contours);
%             figure;colormap gray;imagesc(df3{framenum});axis equal;
            if ~isempty(fc);
%                 linframe=df3{framenum};
%                 linframe=mean(linframe(1:end));
                origvalues=framecontvalues(df(:,:,framenum),fc);%find the mean pixelvalue of the original df frame inside each contour found
                oi=find(origvalues>moviemean3);%find index numbers of contours where brightness was above average in original movie
                for e=1:length(oi);
                    frameconts(e)=fc(oi(e));%only keep areas representing above average brightness (avoid problem of detecting cells turning "off" which can happen with fft
                end
                ons1=zeros(1,length(contours));
                ons2=zeros(1,length(contours));
			        [ons1,frameons]=mostincontour(contours,frameconts,frame);%see if any of those found bright regions are inside known cells
			        if sum(frameons)>0;%if any bright spots are in cells
			            ind=find(frameons);
                        frameconts2={};
			            for k=1:length(ind);
			                frameconts2{k}=frameconts{ind(k)};%put contours of the spots that are in cell contours into a new array
			            end
			        [throwaway,ons2]=comparecontours2(frameconts2,contours);%find out all cell contours with centers inside the bright spots... ie including if multiple cells in a spot
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