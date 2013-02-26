centr{num} = [];
areas{num} = [];
for c = 1:length(cn{num})
    centr{num}(c,:) = HippoCentroid(cn{num}{c});
    areas{num}(c) = polyarea(cn{num}{c}(:,1),cn{num}{c}(:,2));
end
delete(handl{num});
handl{num} = [];
subplot('position',[0.02 0.02 0.82 0.96])
for c = 1:length(cn{num})
    h = plot(cn{num}{c}([1:end 1],1),cn{num}{c}([1:end 1],2),'color',cl(num,:),'LineWidth',1);
    handl{num} = [handl{num} h];
end
set(handl{num}(find(areas{num} < lowar(num) | areas{num} > highar(num))),'visible','off');
zoom on