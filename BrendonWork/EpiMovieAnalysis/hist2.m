function hist2(vect1,vect2,binnumber);

binnumber=10;
for q=1:binnumber;%for each bin
    if q<binnumber;
        qbinmin=1-(q/binnumber);%find bin minimum
        qbinmax=1-(q/binnumber)+1/binnumber;%and max
        qt1=find(vect1>qbinmin);%find elements of first vector that are over the min value
        qt2=find(vect1<=qbinmax);%find elements of second vector that are under the max value
        qt=intersect(qt1,qt2);%find the intersection of the above two
        for r=1:binnumber;
            if r<binnumber;
                rbinmin=1-(r/binnumber);
                rbinmax=1-(r/binnumber)+1/binnumber;
                rs1=find(vect2>rbinmin);
                rs2=find(vect2<=rbinmax);
                rs=intersect(rs1,rs2);
                bins(binnumber-(q-1),binnumber-(r-1))=length(intersect(qt,rs));
            elseif r==binnumber;
                rbinmin=1-(r/binnumber);
                rbinmax=1-(r/binnumber)+1/binnumber;
                rs1=find(vect2>=rbinmin);
                rs2=find(vect2<=rbinmax);
                rs=intersect(rs1,rs2);
                bins(binnumber-(q-1),binnumber-(r-1))=length(intersect(qt,rs));
            end
        end
    elseif q==binnumber;
        qbinmin=1-(q/binnumber);
        qbinmax=1-(q/binnumber)+1/binnumber;
        qt1=find(vect1>=qbinmin);
        qt2=find(vect1<=qbinmax);
        qt=intersect(qt1,qt2);
        for r=1:binnumber;
            if r<binnumber;
                rbinmin=1-(r/binnumber);
                rbinmax=1-(r/binnumber)+1/binnumber;
                rs1=find(vect2>rbinmin);
                rs2=find(vect2<=rbinmax);
                rs=intersect(rs1,rs2);
                bins(binnumber-(q-1),binnumber-(r-1))=length(intersect(qt,rs));
            elseif r==binnumber;
                rbinmin=1-(r/binnumber);
                rbinmax=1-(r/binnumber)+1/binnumber;
                rs1=find(vect2>=rbinmin);
                rs2=find(vect2<=rbinmax);
                rs=intersect(rs1,rs2);
                bins(binnumber-(q-1),binnumber-(r-1))=length(intersect(qt,rs));
            end
        end
    end
end
figure;
bar3(bins);