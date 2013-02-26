function sr=stretchedrepeats(ons,lengths);
%finds repeated patterns of cell activation, even if the intervals between
%when the cells are on changes.  Just looks for a before b before c (more
%than once).

doubleons=sum(ons,1);%finds how many times each cell was on
doubleons=find(doubleons>=2);%finds cells that were on 2 or more times... others are irrelevant
ons=ons(:,doubleons);%ons now only consists of cells which are on at least twice

for a given cell
find ons(that row)%everytime that cell is on
    for each value above... give list of following cell numbers (can/should have repeats of same cells)
	find overlaps in lists.  keep those cell numbers
	
	1 if overlap, 0 if no
	while loop... while = 1
        repeat above process for those cells at those frames
        keep going until 0
        put while loop just after first for?
        record matches (with frame #s and cell #s)
    end
end
        