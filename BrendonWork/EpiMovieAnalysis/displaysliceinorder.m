function displaysliceinorder(sorted,slice)

fields=fieldnames(sorted{slice});
for a=1:length(fields)
    eval(['tf=isstruct(sorted{slice}.',fields{a},');'])
    if tf
        eval(['tf=isfield(sorted{slice}.',fields{a},',''index'');'])
        if tf
            eval(['b=1:length(sorted{slice}.',fields{a},');'])
            for c=b
                eval(['index=sorted{slice}.',fields{a},'(c).index;']);
                order{index,1}=index;
                eval(['order{index,2}=''',fields{a},''';'])
                order{index,3}=c;
            end
        end
    end
end
for a=1:size(order,1);
	if isempty(order{a,1});
		order(a,:)=[];
	end
end
ax2=ceil(size(order,1)^.5);
ax1=ceil(size(order,1)/ax2);
figure
for a=1:size(order,1);
    subplot(ax1,ax2,a)
    eval(['highlightons(sorted{slice}.contours,sum(sorted{slice}.',order{a,2},'(',num2str(order{a,3}),').ons,1));']);
    eval(['title(''',num2str(a),' ',order{a,2},''');'])
end