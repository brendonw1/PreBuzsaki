for a=1:size(output.memb,1);
        for z=1:size(output.memb,2);
        temp=zeros(1,251);
        if ~isempty(output.memb{a,z});
            for b=1:length(output.memb{a,z})
                for c=1:size(output.memb{a,z}{b},1)
                    if isempty(findaps2(output.memb{a,z}{b}(c,:)));
                        temp(end+1,:)=output.memb{a,z}{b}(c,:);
                    end
                end
            end
            sz=size(temp,1);
            temp=mean(temp,1);
            if sum(temp)~=0;
                figure('numbertitle','off','name',[matnotes(a).name,' Cell #',num2str(z),'. ',num2str(sz),' trials']);
                plot(temp)
            end 
        end
    end
end