warning off MATLAB:conversionToLogical

for a=97:size(uptraces,1);
    for c=1:size(uptraces,3);%for each cell
        single=0;
        train=0;
        for b=1:size(uptraces,2);%note switch of b and c
            for d=1:size(uptraces,4);
                if strcmp(uptraces(a,b,c,d).stim,'tssingle');
                    single=single+1;
                end
                if strcmp(uptraces(a,b,c,d).stim,'tstrain');
                    train=train+1;
                end
            end
        end
        if single | train
            disp([num2str(a),' ',num2str(c)])
            for b=1:size(uptraces,2);%note switch of b and c
                for d=1:size(uptraces,4);
                    if strcmp(uptraces(a,b,c,d).stim,'tssingle');
                        load(uptraces(a,b,c,d).abfname);
                        match=channelmatch(header,c);
                        figure
                        plot(data(:,match))
                        hold on
						plot(uptraces(a,b,c,d).in6,-70*ones(1,length(uptraces(a,b,c,d).in6)),'*','color','g')
                        pause
                    end
                end
            end
            x=0;
            z=0;
            while z==0;
                an=input('do you need to see the tstrain traces as well? y/n ','s');
                if strcmp(an,'y') 
                    z=1;
                    x=1;
                elseif strcmp(an,'n')
                    z=1;
                else
                    disp('must enter either y or n')
                end
            end
            if x==1;
                for b=1:size(uptraces,2);%note switch of b and c
                    for d=1:size(uptraces,4);
                        if strcmp(uptraces(a,b,c,d).stim,'tstrain');
                            load(uptraces(a,b,c,d).abfname);
                            match=channelmatch(header,c);
                            figure
                            plot(data(:,match))
                            hold on
							plot(uptraces(a,b,c,d).in6,-70*ones(1,length(uptraces(a,b,c,d).in6)),'*','color','g')
                            pause
                        end
                    end
                end
            end
            x=0;
            z=0;
            while z==0;
                an=input('Did this cell receive direct thalamic input? y/n ','s');
                if strcmp(an,'y') 
                    z=1;
                    x=1;
                elseif strcmp(an,'n')
                    z=1;
                else
                    disp('must enter either y or n')
                end
            end
            if x==1;
                uptraces(a,b,c,d).directinput=1;
            else
                uptraces(a,c,c,d).directinput=0;%if no ups detected, uptraces(a,b,c,d).directinput will equal [], not 0
            end
        end
    end
end