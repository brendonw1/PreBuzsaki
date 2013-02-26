function [averagenocont, averagepercentts, averageperspont, mincont, maxcont, stdevpercts, stdevpersp, averagenoactivts, averagenoactivspont, maxnoactts, maxnoactspont]=percentmovies(sorted); 
warning off MATLAB:conversionToLogical
for c=1:size(sorted,2);%for each slice
    totcont(c)=size(sorted{c}.contours,2);%number of contours in each movie
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.tstrain,2)
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            lcolltstrain{c}(d,:)=logical(colltstrain{c}(d,:));%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(lcolltstrain{c}(d,:),2)>10;%if total number of cells on in this movie is greater than 10:
                percentts(c,d)=sum(lcolltstrain{c}(d,:),2)/totcont(c);
                noactivts(c,d)=sum(colltstrain{c}(d,:),2)./sum(lcolltstrain{c}(d,:),2);
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.spont,2)
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            lcollspont{c}(d,:)=logical(collspont{c}(d,:));%a cell that is on in a movie=1 (not more if it is on multiple times
            if sum(lcollspont{c}(d,:),2)>5;%if total number of cells on in this movie is greater than 5:
                percentspont(c,d)=sum(lcollspont{c}(d,:),2)/totcont(c);
                noactivspont(c,d)=sum(collspont{c}(d,:),2)./sum(lcollspont{c}(d,:),2);
            end
        end
    end
end

mincont=min(totcont);
maxcont=max(totcont);
averagenocont=mean(totcont);
averagepercentts=mean(percentts(find(percentts)));
stdevpercts=std(percentts(find(percentts)));
averageperspont=mean(percentspont(find(percentspont)));
stdevpersp=std(percentspont(find(percentspont)));
averagenoactivts=mean(noactivts(find(noactivts)));
averagenoactivspont=mean(noactivspont(find(noactivspont)));
maxnoactts=max(max(noactivts));
maxnoactspont=max(max(noactivspont));