function [cidx,outridx] = determine_cell_clicked(handles,midx,ridx,ox,oy)
%Take contours from multiple regions and find which cell was clicked in
%those regions.  Also reports what region that was in with outridx.  Could
%index across regions too... but seems better to have that be fixed so
%cells aren't mixed up.

theseconts = {};
outridx = [];
for rridx = 1:length(ridx);
    theseconts = handles.exp.regions.contours{ridx(rridx)}{midx};
    for a = 1:length(theseconts);
        cidx(a) = inpolygon(ox,oy,theseconts{a}(:,1),theseconts{a}(:,2));
    end
    cidx = find(cidx);
    if ~isempty(cidx);
        if isempty(outridx);
            outridx = ridx(rridx);
            break
        else
            msgbox('Error, multiple cells selected');
            return
        end
    end
end