function sorted=coresorted(sorted,goodperslice,corethresh);


% goodperslice=2;
warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        slicecolltstrain{c}=zeros(1,length(sorted{c}.contours));%establish matrix
        for d=1:size(sorted{c}.tstrain,2)
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(colltstrain{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
                goodtstrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        slicecollspont{c}=zeros(1,length(sorted{c}.contours));
        for d=1:size(sorted{c}.spont,2)
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(collspont{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end
% for a=1:size(sorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
%     m=min([sum(goodtstrain(a,:)) sum(goodspont(a,:))]);%figure out whether less spont or less stim movies
%     t=find(goodtstrain(a,:));
%     s=find(goodspont(a,:));
%     t=t(1:m);
%     s=s(1:m);
%     goodtstrain(a,:)=zeros(1,size(goodtstrain,2));
%     goodtstrain(a,t)=1;
%     goodspont(a,:)=zeros(1,size(goodspont,2));
%     goodspont(a,s)=1;
% end

for a=1:size(sorted,2);%for each slice
    sorted{a}.ttcore=[];
    sorted{a}.ttother=[];
    sorted{a}.stcore=[];
    sorted{a}.stother=[];
    sorted{a}.goodtrain=[];
    sorted{a}.sscore=[];
    sorted{a}.ssother=[];
    sorted{a}.tscore=[];
    sorted{a}.tsother=[];
    sorted{a}.goodspont=[];
    tgoodthisslice=[];
    sgoodthisslice=[];
    if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        tgoodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(tgoodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(tgoodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(tgoodthisslice,2);%for each cell, what percent of movies is it on
    end
    if sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        sgoodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(sgoodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(sgoodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcollspont{a}=sumcollspont{a}/size(sgoodthisslice,2);%for each cell, what percent of movies is it on
    end
    if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        corecells=zeros(1,size(sorted{a}.contours,2));
        corecells(find(sumcolltstrain{a}>=corethresh))=1;
        nonzeros=zeros(1,size(sorted{a}.contours,2));
        nonzeros(find(sumcolltstrain{a}))=1;
        othercells=nonzeros.*~corecells;
        for b=1:size(tgoodthisslice,2)%for each good tstrain movie
            ttcore=[];
            ttother=[];
            for c=1:size(sorted{a}.tstrain(tgoodthisslice(b)).ons,1);%for each frame
                ttc=zeros(1,size(sorted{a}.contours,2));
                ttc(find(corecells))=sorted{a}.tstrain(tgoodthisslice(b)).ons(c,(find(corecells)));
                ttcore(c,:)=ttc;
                tto=zeros(1,size(sorted{a}.contours,2));
                tto(find(othercells))=sorted{a}.tstrain(tgoodthisslice(b)).ons(c,(find(othercells)));
                ttother(c,:)=tto;
            end
            sorted{a}.ttcore{b}=ttcore;
            sorted{a}.ttother{b}=ttother;
        end   
%         if sum(goodspont(a,:),2)>0;
            sgoodthisslice=find(goodspont(a,:));
            for b=1:size(sgoodthisslice,2)%for each good spont movie
                stcore=[];
                stother=[];
                for c=1:size(sorted{a}.spont(sgoodthisslice(b)).ons,1);%for each frame
                    stc=zeros(1,size(sorted{a}.contours,2));
                    stc(find(corecells))=sorted{a}.spont(sgoodthisslice(b)).ons(c,(find(corecells)));
                    stcore(c,:)=stc;
                    sto=zeros(1,size(sorted{a}.contours,2));
                    sto(find(corecells))=sorted{a}.spont(sgoodthisslice(b)).ons(c,(find(corecells)));
                    stother(c,:)=sto;
                end
                sorted{a}.stcore{b}=stcore;
                sorted{a}.stother{b}=stother;
                sorted{a}.goodtstrain=tgoodthisslice;
            end
%         end
    end
    if sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        corecells=zeros(1,size(sorted{a}.contours,2));
        corecells(find(sumcollspont{a}>=corethresh))=1;
        nonzeros=zeros(1,size(sorted{a}.contours,2));
        nonzeros(find(sumcollspont{a}))=1;
        othercells=nonzeros.*~corecells;
        for b=1:size(sgoodthisslice,2)%for each good spont movie
            sscore=[];
            ssother=[];
            for c=1:size(sorted{a}.spont(sgoodthisslice(b)).ons,1);%for each frame
                ssc=zeros(1,size(sorted{a}.contours,2));
                ssc(find(corecells))=sorted{a}.spont(sgoodthisslice(b)).ons(c,(find(corecells)));
                sscore(c,:)=ssc;
                sso=zeros(1,size(sorted{a}.contours,2));
                sso(find(othercells))=sorted{a}.spont(sgoodthisslice(b)).ons(c,(find(othercells)));
                ssother(c,:)=sso;
            end
            sorted{a}.sscore{b}=sscore;
            sorted{a}.ssother{b}=ssother;
        end
%         if sum(goodtstrain(a,:),2)>0;
            tgoodthisslice=find(goodtstrain(a,:));
            for b=1:size(tgoodthisslice,2)%for each good tstrain movie
                tscore=[];
                tsother=[];
                for c=1:size(sorted{a}.tstrain(tgoodthisslice(b)).ons,1);%for each frame
                    tsc=zeros(1,size(sorted{a}.contours,2));
                    tsc(find(corecells))=sorted{a}.tstrain(tgoodthisslice(b)).ons(c,(find(corecells)));
                    tscore(c,:)=tsc;
                    tso=zeros(1,size(sorted{a}.contours,2));
                    tso(find(corecells))=sorted{a}.tstrain(tgoodthisslice(b)).ons(c,(find(corecells)));
                    tsother(c,:)=tso;    
                end
                sorted{a}.tscore{b}=tscore;
                sorted{a}.tsother{b}=tsother;
                sorted{a}.goodspont=sgoodthisslice;
%             end   
        end
    end 
end