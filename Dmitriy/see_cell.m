function see_cell(cn,num)
%see_cell(cn,num)
%   shows cell number num

hold on;
for c = 1:size(cn,2)
    plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
%     label=num2str(c);
%     text(cn{c}(1,1),cn{c}(1,2),label);
end

for c = num
    plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-r','linewidth',2);
end

axis equal
axis tight
box on
set(gca,'ydir','reverse');