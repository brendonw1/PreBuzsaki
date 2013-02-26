for a=size(uptraces,1);
    for b=1:size(uptraces,2);
        for c=1:size(uptraces,3);
            for d=1:size(uptraces,4);
                if isempty(uptraces(a,b,c,d).stim)
                    if b<=length(abfnotes{a}.stim)
                        uptraces(a,b,c,d).stim=abfnotes{a}.stim{b};
                        uptraces(a,b,c,d).abfname=abfnotes{a}.abfname{b};
	%                     uptraces(a,b,c,d).wddelay=abfnotes{a}.wddelay{b};
                        uptraces(a,b,c,d).moviename=abfnotes{a}.moviename{b};
                        switch c
                            case 1
                                uptraces(a,b,c,d).cellchannel='IN 5';
                                uptraces(a,b,c,d).celltype=abfnotes{a}.in5cell;
							case 2
                                uptraces(a,b,c,d).cellchannel='IN 10';
                                uptraces(a,b,c,d).celltype=abfnotes{a}.in10cell;
					   		case 3
                                uptraces(a,b,c,d).cellchannel='IN 14';
                                uptraces(a,b,c,d).celltype=abfnotes{a}.in14cell;
						end
                        uptraces(a,b,c,d).stimnum=abfnotes{a}.stimnum{b};
                        uptraces(a,b,c,d).stimfreq=abfnotes{a}.stimfreq{b};
                        uptraces(a,b,c,d).stimamp=abfnotes{a}.stimamp{b};
                        uptraces(a,b,c,d).stimprotocol=abfnotes{a}.stimprotocol{b};
                        uptraces(a,b,c,d).timesincelast=abfnotes{a}.timesincelast{b};
                        uptraces(a,b,c,d).observation=abfnotes{a}.observation{b};
                        uptraces(a,b,c,d).otherdescrip=abfnotes{a}.otherdescrip{b};
                    end
                end
            end
        end
    end
end