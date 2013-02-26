function percentoverlap = getoverlap(ons1,ons2)

% ons1 = sum(ons1,2);
% ons2 = sum(ons2,2);

minavail = min([sum(ons1(:)) sum(ons2(:))]);
sharedons = ons1.*ons2;
percentoverlap = sum(sharedons)/minavail;