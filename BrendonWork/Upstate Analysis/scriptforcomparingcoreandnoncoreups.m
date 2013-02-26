if length(size(uptraces))==4
    uptraces=byfiletobycell(uptraces);
end

coredurations=[];
noncoredurations=[];
coreamps=[];
noncoreamps=[];
corenumaps=[];
noncorenumaps=[];

for a=1:size(uptraces,1);
    for b=1:size(uptraces,2);
        if ~isempty(uptraces(a,b).ups);
            if uptraces(1).coreguide(a)==1;
                localindex=uptraces(a,b).ups-uptraces(a,b).ups(1)+1;
                coredurations(end+1)=localindex(3)-localindex(2);
                coreamps(end+1)=mean(uptraces(a,b).traces(localindex(2):localindex(3)))-uptraces(a,b).traces(localindex(1));
                corenumaps(end+1)=length(findaps2(uptraces(a,b).traces(localindex(2):localindex(3))));
            else
                localindex=uptraces(a,b).ups-uptraces(a,b).ups(1)+1;
                noncoredurations(end+1)=localindex(3)-localindex(2);
                noncoreamps(end+1)=mean(uptraces(a,b).traces(localindex(2):localindex(3)))-uptraces(a,b).traces(localindex(1));
                noncorenumaps(end+1)=length(findaps2(uptraces(a,b).traces(localindex(2):localindex(3))));
            end
        end
    end
end
