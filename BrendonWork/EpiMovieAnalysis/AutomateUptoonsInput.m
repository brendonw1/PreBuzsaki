function AutomateUptoonsInput(slices)
%must be in correct directory: one which contains notes, enhanced images
%and aligned movies.  This will one of each and store them together, all
%according to names read out previously and saved in the cell "slices",
%which contains a number of strings, each specifying a slice name.

for a=1:length(slices);
    a
    base=slices{a}
    
    n=['notes',base,'=readnotebook(base);'];
    eval(n);
    
    alignedname=strcat([base,'ConcatAligned.tif']);
    p=['pixels',base,'=inputmovie(alignedname);'];    
    eval(p);
   
%     d=['df=-diff(pixels',base,',1,3);'];
%     eval(d);
    
    enhancedname=strcat([base,'ConcatAligned.tif']);
    e=['image',base,'=imread(enhancedname);'];
    eval(e);
    
    s = ['save upt',base];
    clear n alignedname p enhancedname e
    eval(s);
    
    c=['clear pixels',base,' notes',base,' image',base,' s base'];
    eval(c);
end