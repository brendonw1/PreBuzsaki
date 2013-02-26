function PiaDirection = PiaDirection(cn)
%PiaDirection = PiaDirection(cn)
%   determines the direcion of the pia

for c = 1:size(cn,2)
    [or(c,1) or(c,2)] = orientation(cn{c},[]);
end

or = sortrows(or,1);
cr = [or(:,2).*cos(or(:,1)) -or(:,2).*sin(or(:,1))];

PiaDirection = orientation(cr,[0 0]);