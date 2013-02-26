numups=sum(uptraces(1).guide,2);

uptraces(1).coreguide=zeros(size(uptraces,1),size(uptraces,3));

for a=1:size(uptraces,1);%for each slice
    for c=1:size(uptraces,3);%for each cell
        apeachup=[];
        for b=1:size(uptraces,2);%for each recording
            for d=1:size(uptraces,4);%for each upstate in each recording
                if uptraces(1).guide(a,b,c,d);%if an up in that recording
                    localindex=uptraces(a,b,c,d).ups-uptraces(a,b,c,d).ups(1)+1;
                    apeachup(end+1)=~isempty(findaps2(uptraces(a,b,c,d).traces(localindex(2):localindex(3))));%record 1 if an ap fired during that up, 0 if not.
                end
            end
        end
        if length(apeachup)>1 & sum(apeachup)==length(apeachup);%if an ap in every upstate 
            for b=1:size(uptraces,2);%then go thru each entry for that cell
                for d=1:size(uptraces,4);%for each upstate in each recording
                    uptraces(a,b,c,d).core=1;
                    uptraces(1).coreguide(a,c)=1;
                end
            end
        end
    end
end

