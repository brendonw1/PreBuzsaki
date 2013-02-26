for a=1:size(uptraces,1);
    for b=1:size(uptraces,2);
        in=[];
        for c=1:size(uptraces,3);
            for d=1:size(uptraces,4);
                if strcmp(uptraces(a,b,c,d).stim,'tssingle') | strcmp(uptraces(a,b,c,d).stim,'tstrain') | strcmp(uptraces(a,b,c,d).stim,'wdsingle') | strcmp(uptraces(a,b,c,d).stim,'wdtrain')
                    if isempty(uptraces(a,b,c,d).in6);
                         if isempty(in)
                            load(uptraces(a,b,c,d).abfname);
                            disp([num2str(a),' ',num2str(b),' ',num2str(c),' ',num2str(d)])
                            f=channelnames(header);
							ic=[];
							for h=1:length(f);%go thru each channel name
                                if strcmp(f(h),'IN 6');%find if it is "IN 6"
                                    ic=h;%if it is, store the number in ic
                                end
							end
                            if ~isempty(ic)
                                in=findin6(header,data);
                            else
                                figure
                                plot(data)
                                title([uptraces(a,b,c,d).stimfreq,'Hz ',uptraces(a,b,c,d).stimnum,' Stimuli.  File ',uptraces(a,b,c,d).abfname]);
                                in=input('enter where in6 is: ');
                            end
                        end
                        uptraces(a,b,c,d).in6=in;
                    end
                end
            end
        end
    end
end

uptraces(a,b,c,d).in6=findin6(header,data);