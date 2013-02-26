function shuffons=reshufflewhichcells2(ons)
%only accepts 1d lists of which cells are on in a single "frame"... no 2d
%matrices
%will keep the number of cells that turn on the same, but will change which
%cells are on at which points in the movie.  For use in spatial clusters
%analysis.  
%"ons" is a matrix of data about all cells from 1 movie, with 1 if the
%cell was on in that frame, 0 if it was not.
%"shuffons" is a new version of ons, with the same number of total cells on
%but which cells are the ones on has changed.


if size(ons,1)>1;
    error('reshufflewhichcells2 only accepts single "frame" inputs: 1xnumcells vector)')
end

warning off MATLAB:conversionToLogical
ons=logical(ons);
numon=sum(ons);%number of cells on
randinds = randperm(size(ons,2));
shuffons = zeros(size(ons));
shuffons(randinds(1:numon))=1;