function percentage = getlocksteppercent(ons1,ons2)

%denom is the total ACTIVATIONS in the SHARED CELLS
sharedactivecells = find(logical(sum(ons1,1).*sum(ons2,1)));
nonsharedcells = setdiff(1:size(ons1,2),sharedactivecells);
ons1(:,nonsharedcells) = 0;
ons2(:,nonsharedcells) = 0;
minavail = min([sum(ons1(:)) sum(ons2(:))]);

[lock1,lock2] = findbestrepeats(ons1,ons2);
percentage = sum(lock1(:))/minavail;