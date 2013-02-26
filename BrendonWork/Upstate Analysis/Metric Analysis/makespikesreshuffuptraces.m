function spikesreshuffuptraces=makespikesreshuffuptraces(uptraces,numreshuff);

tic
for a=1:size(uptraces,1);
    disp (a)
	for b=1:size(uptraces,2);
		for c=1:size(uptraces,3);
			for d=1:size(uptraces,4);
				if uptraces(1).guide(a,b,c,d);
					start=uptraces(a,b,c,d).ups(2)-uptraces(a,b,c,d).ups(1)+1;
					stop=uptraces(a,b,c,d).ups(3)-uptraces(a,b,c,d).ups(1)+1;
					aps=findaps2(uptraces(a,b,c,d).traces(start:stop));
					if ~isempty(aps)
						spikesreshuffuptraces(1).spikeguide(a,b,c,d)=1;
						spikesreshuffuptraces(a,b,c,d).spikes=zeros(numreshuff,length(aps));
						spikesreshuffuptraces(a,b,c,d).original=aps;
						for z=1:numreshuff;
							spikesreshuffuptraces(a,b,c,d).spikes(z,:)=reshufflespikeisis(aps,start,stop);
						end
					end
				end
			end
        end
    end
end
toc