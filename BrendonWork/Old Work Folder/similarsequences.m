function similarsequences(on,window,threshold)

% window is the number of frames at a time to compare (ie size of
% template)

% input matrix is broken into movies... can linearize it to only a 2d series of frames,
% to compare all frames of all movies... can then show breaks in display where a new movie
% is starting (ending)

on2=shiftdim(on,2);
on2=reshape(on2,[size(on2,1),(size(on2,2)*size(on2,3))]); %now is a series of frames, not separated into movies
                                                          %is cells x total frames
% on3=on2';%flipped in prep for circshift loop

for a=1:size(on2,1)
    [i j]=find(on2(a,:));
    for b=1:length(j);
         template = on2(:,(j(b):j(b)+window-1));%sets up a template of frames to compare to  
        for c=(b+1):length(j);%compares to remaining instances of when cell fired
            compared = on2(:,(j(c):j(c)+window-1));
            overlap=template+compared; %gives 2 wherever cells were on at the same place in the compared sequences frames
            overlap=(overlap>=2); %gives 1 wherever cells were on at the same place in the compared sequences frames...0 where not
            total=sum(overlap);
            total=sum(total); %gives total number of overlapped cells in the frames compared
            if total>=threshold
                matches(a,1)=a;
                matches(a,2)=b;
                matches(a,3)=c;%stores in the variable "matches" all values of cell number (a) and which instances of that cell firing 
                                %(b and c)had an above-threshold overlap of cells firing... can be used for later display of data
            end
        end
    end
end




%     
% for a=1:(size(on3,1));
%     shiftsmatrix(:,:,a)=circshift(on3,a);
% end
% 
% on4=repmat(on3,[1 1 size(on3,1)]);
% comparisions=on4+shiftsmatrix;%adding the original frames to each shifted set of frames... 
%                                %will get a value of 2 whenever a cell is on in the same place in a shift
%                                %as in 
% overlaps=find(comparisons>=2);
% 
% for b=1:(
%     result(b)=sum(overlaps)