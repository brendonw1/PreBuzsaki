function peaksafterhippo(region)

ons=zeros(size(region.traces));
for a=1:size(region.onsets,2);
	ons(a,region.onsets{a})=1;
end

figure;
bar(sum(ons));

% figure;
% highlightonscolor(region.contours,ons(:,311),'r');