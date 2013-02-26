function cnnew = celldelete(cn,f)
%cnnew = celldelete(cn,f)
%   deletes elements in f from cn

el = 1:prod(size(cn));
el = setdiff(el,f);

cnnew = cell(1,size(el,2));
for c = 1:size(el,2)
    cnnew{c} = cn{el(c)};
end