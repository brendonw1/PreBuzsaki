function AutomateResavePixels(slices2)
%must be in correct directory: one which contains notes, enhanced images
%and aligned movies.  This will one of each and store them together, all
%according to names read out previously and saved in the cell "slices",
%which contains a number of strings, each specifying a slice name.

for a=1:length(slices2);
    a
    base=slices2{a}
    
    lo = ['load upt',base];
    eval(lo);
    
    alignedname=strcat([base,'ConcatAligned.tif']);
    p=['pixels',base,'=inputmovie(alignedname);'];    
    eval(p);
   
    s = ['save newupt',base];
    clear n lo alignedname p
    eval(s);
    
    c=['clear pixels',base,' notes',base,' image',base,' s base'];
    eval(c);
end