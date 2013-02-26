function shuffons=reshufflewhichcells(ons)
%will keep the number of cells that turn on the same, but will change which
%cells are on at which points in the movie.  For use in spatial clusters
%analysis.  
%"ons" is a matrix of data about all cells from 1 movie, with 1 if the
%cell was on in that frame, 0 if it was not.
%"shuffons" is a new version of ons, with the same number of total cells on
%but which cells are the ones on has changed.
warning off MATLAB:conversionToLogical
ons=logical(ons);
numon=sum(sum(sum(ons)));%number of cells on
slots=numel(ons);%frames times cells
if numon>0;
	a=1;%use this with a while loop so I can use the continue function to repeat a value of a
	while a<=numon;%for each cell on
        shuff(a)=ceil(slots*rand);%new "ons"(a) = random non-zero member of all cells in slice
        if a>1;
            match=ismember(shuff(a),shuff(1:a-1));%see if most recently generated cell-to-be on is 
            %replicating one generated before
            if match%if yes
                continue;%go back to generate another number for the same cell
            end%else, go on to next cell
        end
        a=a+1;
    end
	
	shuffons=zeros(size(ons));
	shuffons(shuff)=1;
else
	shuffons=zeros(size(ons));
end    