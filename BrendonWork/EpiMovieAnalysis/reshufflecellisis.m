function newons=reshufflecellisis(ons);
%ons has frames on dimension1 and contours on d2.  
warning off MATLAB:conversionToLogical;


cellson=sum(ons,1);
cellson=find(cellson);%a list of which cells were on
newons1=zeros(size(ons));%will be different cells, same isis as old array
z=1;
while z<=length(cellson);%for each such cell
    alreadyin=find(sum(newons1,1));%which cells are already assigned into the new matrix
    cellnumb=ceil(size(newons1,2)*rand);
    if ismember(cellnumb,alreadyin);%if this is a new cell
        continue
    end
    newons1(:,cellnumb)=ons(:,cellson(z));
    z=z+1;
end

newons=zeros(size(newons1));%will be reshuffled version of linear ons 
for a=1:size(newons1,2);%for each cell
    if sum(newons1(:,a))==1;%if only 1 event
        reshuff=ceil(size(newons1,1)*rand); %pick a random new frame in which to have that
        newons(reshuff,a)=1;%new row for cell a, newisis   
    elseif sum(newons1(:,a))>1;%if cell comes on more than once
        tempisis=find(newons1(:,a));%find frames where cells on
        tempisis=diff(tempisis);%find inter-spike intervals
        tempisis=tempisis(randperm(length(tempisis)));
        firingwidth=sum(tempisis)+1;%number of frames between first and last firing
        remaining=size(newons1,1)-firingwidth;%number of frames before first firing and after last firing
        if remaining>0;
            s=ceil((remaining)*rand);%random number btw 0 and the number of frames outside of cell firings
            tempisis(2:end+1)=tempisis;%making room at beginning of the array
            tempisis(1)=s;%assigning randomly picked number to be space between begin of movie and 1st firing
        else
            tempisis(2:end+1)=tempisis;%making room at beginning of the array
            tempisis(1)=1;%assigning randomly picked number to be space between begin of movie and 1st firing
        end
        tempisis=cumsum(tempisis);%now have frame numbers of "new" (random) firings
        newons(tempisis,a)=1;%new row for cell a
    end
end
