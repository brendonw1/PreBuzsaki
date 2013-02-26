function moviecell=makemoviecell
%this function will go thru a directory of similarly name .mat files which
%contain data from slices and extract and save the important elements in a
%new cell array called moviecell.  The output, moviecell will contain four
%columns and will have 1 row for each slice.  The columns will be 
% -ons                (eg from bandpassanalysis2)
% -movienotes         (from reshapenotes)
% -lengths            (manually entered vector of the lengths of movies
% -contours           (from findfrommatrix, or findcells);
%
%this moviecell can then be put into "interpretmovie".
moviecell={};
save zz moviecell
for k=60:116;
    k
    a=k-59;
    di=dir;
    load(di(k).name);
    load('zz');
    base=di(k).name(2:10);%slice name and base portion of variables for this slice
    
    conts=strcat('conts',base);
    len=strcat('lengths',base);
    notes=strcat('notes',base);
    onname=strcat('ons',base);
    
    moviecell{a,1}=eval(onname);
    moviecell{a,2}=eval(notes);
    moviecell{a,3}=eval(len);
    moviecell{a,4}=eval(conts);
    
    save zz moviecell
    clear    
end
    
load zz