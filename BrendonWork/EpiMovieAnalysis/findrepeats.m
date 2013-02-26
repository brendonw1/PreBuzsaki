function repeats = findrepeats(ons,window);
% window = number of frames across which to look for repeats
% numcells = minimum number of cells that will qualify as a repeat 
% ons is 1's and 0's in format of frames x movies x cells

% Output is repeats, is a cell array.  Each matrix in cell has info on one
% repeat.  A repeat is a place where the cells on in frames from one movie 
% match the cells on in the frames in another movie.  Within each matrix of 
% the cell array:
% row 1: cell numbers repeated in matched frames
% row 2: frame number in first movie
% row 3: movie number of first movie
% row 4: frame number in second movie
% row 5: movie number of second movie

warning off MATLAB:conversionToLogical

[numcells,signif1]=reshuffleisis(ons,window);

ons2=shiftdim(ons,2);% now in format cells x frames x movies

numwindows=((size(ons,1)-(window-1))*size(ons,2));%(windows per movie) x movies
% numwindows=(size(ons,1)*size(ons,2)-(window-1));%number of total frames, minus spacing at end for sampling window
cellspertemplate=window*size(ons,3);%cells/frame x frames/window

template=zeros(1,cellspertemplate,numwindows);
compareds=zeros(numwindows,cellspertemplate);
counter=0; 
for a = 1:(size(ons,2));%for each movie
    for b = 1:(size(ons,1)-(window-1));%will create templates... for each frame
        begin=((a-1)*size(ons,1)*size(ons,3))+(b-1)*size(ons,3)+1;%first element (cell) to be taken into template
        ending=begin+cellspertemplate-1;% last element to be taken in to template
        counter=counter+1;
        template(1,:,counter)=ons2(begin:ending);
        compareds(counter,:)=ons2(begin:ending);
    end
end
template=repmat(template,[numwindows 1 1]);%3D matrix: compared groups x cells in template x templates
compareds=repmat(compareds,[1 1 numwindows]);%same dim as above, replicate over templates dimension

% linearons2=reshape(ons2, [size(ons2,1) size(ons2,2)*size(ons2,3)]);
% compareds=zeros(numwindows,cellspertemplate);
% for c=1:(size(linearons2,2)-(window-1));
%     begin=(c-1)*(size(ons,3))+1;
%     ending = begin + (cellspertemplate-1);
%     compareds(c,:)=linearons2(begin:ending);
% end
% compareds=repmat(compareds,[1 1 numwindows]);

result=compareds+template;
result(find(result<2))=0;%2 where same cell is on in both frames
result(find(result>=2))=1; % 1's where there was a 2, ie where the frames matched, 0s if not

%!!!!!!!!!!!! FOR GAYA JITTER, ALLOW A VARIABLE # OF CELLS WHICH WERE ON IN
%TEMPLATE TO BE ON IN COMPARED AT A POSITION OF 1 FRAME DIFFERENT... LOOK
%IN "RESULT" I THINK.  MAYBE DO NORMAL COMPARISON.  THEN LOOK FOR JITTER WITH
%BY SEEING 1'S INSTEAD OF 2'S IN RESULT?

result2=sum(result,2);%find number of overlapping cells per pair of frames
result2(find(result2<numcells))=0;
result2=logical(result2); 
result2=shiftdim(result2,2);%2D matrix, DIM1 = template window (of frames), DIM2 = compared window
result3=triu(result2,1);%only keep the upper right corner of matrix:
%discard self-to-self comparisons of the central diagonal, and inverse
%comparisions of what is in the kept half.

[i j]=find(result3);

movie1=floor((i-1)/(size(ons,1)-(window-1)))+1;
frame1=rem(i,(size(ons,1)-(window-1)));
frame1(find(frame1==0))=(size(ons,1)-(window-1));

movie2=floor((j-1)/(size(ons,1)-(window-1)))+1;
frame2=rem(j,(size(ons,1)-(window-1)));
frame2(find(frame2==0))=size(ons,1);

linearons=reshape(ons,[(size(ons,1)*size(ons,2)) 1 size(ons,3)]);%ons in format of linearized frames, not broken into movies
rasterfrommatrix(linearons);%graphs a raster and a histogram of the raster

for d=1:length(i);
    cells=find(result(j(d),:,i(d)));%gives number of cell in window examined
    repeats{d}(1,:)=rem(cells,size(ons,3));%gives cell number of match 
    repeats{d}(2,:)=repmat(movie1(d),[1 size(repeats{d},2)]);%gives number of first movie that matched
    repeats{d}(3,:)=frame1(d)+floor((cells-1)/size(ons,3));%gives number of first frame that matched (within movie specified above)
    repeats{d}(4,:)=(repeats{d}(2,:)-1)*size(ons,1)+repeats{d}(3,:);%gives number where cell is in "linearons"
    repeats{d}(5,:)=repmat(movie2(d),[1 size(repeats{d},2)]);%gives number of second movie that matched
    repeats{d}(6,:)=frame2(d)+floor((cells-1)/size(ons,3));;%gives number of second frame that matched (within movie specified above)
    repeats{d}(7,:)=(repeats{d}(5,:)-1)*size(ons,1)+repeats{d}(6,:);%gives number where cell is in "linearons"
    
    subplot(2,1,1);plot(repeats{d}(4,:),repeats{d}(1,:),'r');%graphing from here on
    subplot(2,1,1);plot(repeats{d}(7,:),repeats{d}(1,:),'g');
    
    for e=1:size(repeats{d},2)
        framemat1=repeats{d}(4,:);
        framemat2=repeats{d}(7,:);
        cellmat=repeats{d}(1,:);
        plot(framemat1(e),cellmat(e),'*');
        plot(framemat2(e),cellmat(e),'*');
%         patch([framemat1(e)-.2 framemat1(e)+.2 framemat1(e)+.4 framemat1(e)-.4],[cellmat(e)-.6 cellmat(e)-.6 cellmat(e)-.4 cellmat(e)-.4],'r','linewidth',1);
%         patch([framemat2(e)-.2 framemat2(e)+.2 framemat2(e)+.4 framemat2(e)-.4],[cellmat(e)-.6 cellmat(e)-.6 cellmat(e)-.4 cellmat(e)-.4],'g','linewidth',1);
    end
end



subplot(2,1,2);hold on;plot(1:size(linearons,1),numcells*ones(size(linearons,1),1))


%%%%%%%%%display?%%%%%%%%%%
%show frames
%show frames with filled-in contours (and non-filled in contours)?