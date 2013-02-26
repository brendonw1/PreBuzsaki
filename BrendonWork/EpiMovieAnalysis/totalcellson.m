function totals=totalcellson(sorted)
%input comes from "interpretmovie"... is a set of movie data sorted by the
%type of protocol used to generate that movie:XXXXXXXXX


%Output is ("totals") a structure array which contains various pieces of
%calculated results from the input:
%
%FOR EACH SLICE, WILL APPEAR IN ALL ROWS OF "TOTALS" STRUCTURE:
%sumtrainons=vector with number of times each cell was on for all trains movies
%traincellson=vector with 1 if a cell was on in any train movie 0 if never on
%sumspontons=vector with number of times each cell was on for all spont movies
%spontcellson=vector with 1 if a cell was on in any train movie 0 if never on
%spontDtrain=total # of cells on in spont movies/total # of cells on in trains movies (regardless of overlap)
%trainDspont=total # of cells on in train movies/total # of cells on in spont movies (regardless of overlap)
%trspoverlapDtrain=# of cells shared by spont and trains for a slice / cells on in just trains
%trspoverlapDspont=# of cells shared by spont and trains for a slice / cells on in just spont
%
%STATS ON ALL SLICES, WILL APPEAR ONLY IN ROW 1 OF "TOTALS" STRUCTURE:
%avgspontDtrain=average of spontDtrain over all slices
%sdspontDtrain=standard deviation of spontDtrain over all slices
%avgtrainDspont=average of trainDspont over all slices
%sdspontDtrain=standard deviation of trainDspont over all slices
%avgtrspoverlapDtrain=average over all slices of (overlap of spont and train over train total)
%sdtrspoverlapDtrain=standard deviation over all slices of (overlap of spont and train over train total)
%avgtrspoverlapDspont=average over all slices of (overlap of spont and train over spont total)
%sdtrspoverlapDspont=standard deviation over all slices of (overlap of spont and train over spont total)


warning off MATLAB:conversionToLogical
counter1=0;
upto0tstrain={};
upto33tstrain={};
upto66tstrain={};
upto99tstrain={};
above99tstrain={};
upto0spont={};
upto33spont={};
upto66spont={};
upto99spont={};
above99spont={};
for a=1:size(sorted,2);%for each slice
    onpermovietstrain=[];
    onpermoviespont=[];
    if ~(isempty(sorted(a).tstrainons));%if tstrainons is not empty
        numbcells=size(sorted(a).tstrainons{1},2);% number of contours for this slice
        sumtstrainons=zeros(1,numbcells);%zeros 1,(number of contours for that slice)
        goodresp=0;
        for b=1:size(sorted(a).tstrainons,2);%for each movie in tstrainons
            tstrainonsmovie=sorted(a).tstrainons{b};
            sumtstrainons=sumtstrainons+sum(tstrainonsmovie,1);%how many times each cell has come on thus far in the loop
            onpermovietstrain(b,:)=logical(sum(sorted(a).tstrainons{b},1));%vector of all cells for a given movie saying whether each cell was on in that movie (1) or not (0)
            %will have one row for each movie (column for each cell) within a slice
            if sum(onpermovietstrain(b,:),2)>50;
                goodresp=goodresp+1;
            end
        end
        totals(a).sumtstrainons=sumtstrainons;%vector of how much each cell was on in tstrain of each movie
        totals(a).tstraincellson=logical(sumtstrainons);%vector of which cells came in in tstrain stims
  
        howmanymovieststrain=sum(onpermovietstrain,1);%gives total movies each cell came on
        percentofmovieststrain=howmanymovieststrain./b;%gives proportion of total movies each cell came on in
        upto0tstrain{a}=zeros(1,numbcells);
        upto0tstrain{a}(find(percentofmovieststrain==0))=1;
        upto33tstrain{a}=zeros(1,numbcells);
        upto33tstrain{a}(find(percentofmovieststrain>0&percentofmovieststrain<=(1/3)))=1;
        upto66tstrain{a}=zeros(1,numbcells);
        upto66tstrain{a}(find(percentofmovieststrain>(1/3)&percentofmovieststrain<=(2/3)))=1;
        upto99tstrain{a}=zeros(1,numbcells);
        upto99tstrain{a}(find(percentofmovieststrain>(2/3)&percentofmovieststrain<1))=1;
        above99tstrain{a}=zeros(1,numbcells);
        above99tstrain{a}(find(percentofmovieststrain==1))=1;
        
        upto0tstraintotal(a,:)=[sum(upto0tstrain{a},2) numbcells];        
        upto33tstraintotal(a,:)=[sum(upto33tstrain{a},2) numbcells];        
        upto66tstraintotal(a,:)=[sum(upto66tstrain{a},2) numbcells];        
        upto99tstraintotal(a,:)=[sum(upto99tstrain{a},2) numbcells];        
        above99tstraintotal(a,:)=[sum(above99tstrain{a},2) numbcells]; 
            
        if goodresp>=3;
            howmanygoodtstrain=sum(onpermovietstrain,1);%gives total movies each cell came on
            percentgoodtstrain=howmanymovieststrain./b;%gives proportion of total movies each cell came on in
            upto0goodtstrain{a}=zeros(1,numbcells);
            upto0goodtstrain{a}(find(percentgoodtstrain==0))=1;
            upto33goodtstrain{a}=zeros(1,numbcells);
            upto33goodtstrain{a}(find(percentgoodtstrain>0&percentgoodtstrain<=(1/3)))=1;
            upto66goodtstrain{a}=zeros(1,numbcells);
            upto66goodtstrain{a}(find(percentgoodtstrain>(1/3)&percentgoodtstrain<=(2/3)))=1;
            upto99goodtstrain{a}=zeros(1,numbcells);
            upto99goodtstrain{a}(find(percentgoodtstrain>(2/3)&percentgoodtstrain<1))=1;
            above99goodtstrain{a}=zeros(1,numbcells);
            above99goodtstrain{a}(find(percentgoodtstrain==1))=1;
            
            upto0goodtstraintotal(a,:)=[sum(upto0goodtstrain{a},2) numbcells];        
            upto33goodtstraintotal(a,:)=[sum(upto33goodtstrain{a},2) numbcells];        
            upto66goodtstraintotal(a,:)=[sum(upto66goodtstrain{a},2) numbcells];        
            upto99goodtstraintotal(a,:)=[sum(upto99goodtstrain{a},2) numbcells];        
            above99goodtstraintotal(a,:)=[sum(above99goodtstrain{a},2) numbcells];    
        end
        cellsonintstrain=logical(sum(onpermovietstrain,2));%a vector with 1 if a cell was on in during tstrain in a slice, 0 if not 
    end
    if ~isempty(sorted(a).spontons);%if spont is not empty
        numbcells=size(sorted(a).spontons{1},2);
        sumspontons=zeros(1,numbcells);%zeros 1,(number of contours for that slice)
        for b=1:size(sorted(a).spontons,2)%for each movie in tstrainons
            spontonsmovie=sorted(a).spontons{b};
            sumspontons=sumspontons+sum(spontonsmovie,1);%how many times each cell has come on thus far in the loop
            onpermoviespont(b,:)=logical(sum(sorted(a).spontons{b},1));%vector of all cells for a given movie saying whether each cell was on in that movie (1) or not (0)
            %will have one row for each movie (column for each cell) within a slice
            if sum(onpermoviespont(b,:),2)>50;
                goodresp=goodresp+1;
            end
        end
        totals(a).sumspontons=sumspontons;%vector of how much each cell was on in sponts of each movie
        totals(a).spontcellson=logical(sumspontons);;%vector of which cells came on in spontaneous movies
            
        howmanymoviesspont=sum(onpermoviespont,1);%gives total movies each cell came on
        percentofmoviesspont=howmanymoviesspont./b;%gives proportion of total movies each cell came on in
        upto0spont{a}=zeros(1,numbcells);
        upto0spont{a}(find(percentofmoviesspont==0))=1;
        upto33spont{a}=zeros(1,numbcells);
        upto33spont{a}(find(percentofmoviesspont>0&percentofmoviesspont<=(1/3)))=1;
        upto66spont{a}=zeros(1,numbcells);
        upto66spont{a}(find(percentofmoviesspont>(1/3)&percentofmoviesspont<=(2/3)))=1;
        upto99spont{a}=zeros(1,numbcells);
        upto99spont{a}(find(percentofmoviesspont>(2/3)&percentofmoviesspont<1))=1;
        above99spont{a}=zeros(1,numbcells);
        above99spont{a}(find(percentofmoviesspont==1))=1;
        
        upto0sponttotal(a,:)=[sum(upto0spont{a},2) numbcells];        
        upto33sponttotal(a,:)=[sum(upto33spont{a},2) numbcells];        
        upto66sponttotal(a,:)=[sum(upto66spont{a},2) numbcells];        
        upto99sponttotal(a,:)=[sum(upto99spont{a},2) numbcells];        
        above99sponttotal(a,:)=[sum(above99spont{a},2) numbcells];    
            
        if goodresp>=3;
            howmanygoodspont=sum(onpermoviespont,1);%gives total movies each cell came on
            percentgoodspont=howmanymoviesspont./b;%gives proportion of total movies each cell came on in
            upto0goodspont{a}=zeros(1,numbcells);
            upto0goodspont{a}(find(percentgoodspont==0))=1;
            upto33goodspont{a}=zeros(1,numbcells);
            upto33goodspont{a}(find(percentgoodspont>0&percentgoodspont<=(1/3)))=1;
            upto66goodspont{a}=zeros(1,numbcells);
            upto66goodspont{a}(find(percentgoodspont>(1/3)&percentgoodspont<=(2/3)))=1;
            upto99goodspont{a}=zeros(1,numbcells);
            upto99goodspont{a}(find(percentgoodspont>(2/3)&percentgoodspont<1))=1;
            above99goodspont{a}=zeros(1,numbcells);
            above99goodspont{a}(find(percentgoodspont==1))=1;
            
            upto0goodsponttotal(a,:)=[sum(upto0goodspont{a},2) numbcells];        
            upto33goodsponttotal(a,:)=[sum(upto33goodspont{a},2) numbcells];        
            upto66goodsponttotal(a,:)=[sum(upto66goodspont{a},2) numbcells];        
            upto99goodsponttotal(a,:)=[sum(upto99goodspont{a},2) numbcells];        
            above99goodsponttotal(a,:)=[sum(above99goodspont{a},2) numbcells];    
        end
        
        cellsoninspont=logical(sum(onpermoviespont,2));%a vector with 1 if a cell was on in during spont in a slice, 0 if not 
    end 
    
    %%for gloster, look for overlaps between movies in spont category...
    %%how many do each spont share with others... how to show this?  
    %%also... below
    
    %how do those overlap with the ones in spont, or trains?
    
    
    if ~isempty(sorted(a).spontons)&~isempty(sorted(a).tstrainons);%
        counter1=counter1+1;
        totals(a).spontDtrain=sum(totals(a).spontcellson)/sum(totals(a).tstraincellson);%total number in spont/total number in train
        totals(a).trainDspont=sum(totals(a).tstraincellson)/sum(totals(a).spontcellson);%total number in train/total number in spont
        cumspontDtrain(counter1)=totals(a).spontDtrain;%will allow to do stats on above results
        cumtrainDspont(counter1)=totals(a).trainDspont;%will allow to do stats on above results
        
        o=totals(a).spontcellson + totals(a).tstraincellson;
        totals(a).trainpontoverlap=zeros(size(o));
        totals(a).trspoverlap(find(o>=2))=1;
        totals(a).trspoverlapnumb=sum(totals(a).trspoverlap);
        totals(a).trspoverlapDtrain=totals(a).trspoverlapnumb/sum(totals(a).tstraincellson);%percent of cells on after trains that are also on in spont
        totals(a).trspoverlapDspont=totals(a).trspoverlapnumb/sum(totals(a).spontcellson);%percent of cells on in spont that are also on after trains
        cumtrspoverlapDtrain(counter1)=totals(a).trspoverlapDtrain;%will allow to do stats on above results
        cumtrspoverlapDspont(counter1)=totals(a).trspoverlapDspont;%will allow to do stats on above results
    end
end

totals(1).avgspontDtrain=mean(cumspontDtrain);%average of (total number in spont/total number in train)
totals(1).sdspontDtrain=std(cumspontDtrain);%standard deviation of (total number in spont/total number in train)
totals(1).avgtrainDspont=mean(cumtrainDspont);%average of (total number in train/total number in spont)
totals(1).sdtrainDspont=std(cumtrainDspont);%standard deviation of (total number in train/total number in spont)
%%%%%%%%%%make this not average, but total all and then divide
%%%%%%%%%%determine total contours in all, use this for multiple things


totals(1).avgtrspoverlapDtrain=mean(cumtrspoverlapDtrain);%average percent of cells on after trains that are also on in spont
totals(1).sdtrspoverlapDtrain=std(cumtrspoverlapDtrain);%sd of percent of cells on after trains that are also on in spont
totals(1).avgtrspoverlapDspont=mean(cumtrspoverlapDspont);%average percent of cells on in spont that are also on after trains
totals(1).sdtrspoverlapDspont=std(cumtrspoverlapDspont);%sd of percent of cells on in spont that are also on after trains

totals(1).upto0tstraintotal=sum(upto0tstraintotal,1);%gives total number of cells never on and total number of cells in tstrains   
totals(1).upto33tstraintotal=sum(upto33tstraintotal,1);%gives total number of cells upto 33.3% of time on and total number of cells in tstrains
totals(1).upto66tstraintotal=sum(upto66tstraintotal,1);%gives total number of cells upto 66.7% of time on and total number of cells in tstrains
totals(1).upto99tstraintotal=sum(upto99tstraintotal,1);%gives total number of cells upto but not including 100% of time on and total number of cells intstrains
totals(1).above99tstraintotal=sum(above99tstraintotal,1);%gives total number of cells always on and total number of cells in tstrains

totals(1).upto0goodtstraintotal=sum(upto0goodtstraintotal,1);%gives total number of cells never on and total number of cells in tstrains   
totals(1).upto33goodtstraintotal=sum(upto33goodtstraintotal,1);%gives total number of cells upto 33.3% of time on and total number of cells in tstrains
totals(1).upto66goodtstraintotal=sum(upto66goodtstraintotal,1);%gives total number of cells upto 66.7% of time on and total number of cells in tstrains
totals(1).upto99goodtstraintotal=sum(upto99goodtstraintotal,1);%gives total number of cells upto but not including 100% of time on and total number of cells intstrains
totals(1).above99goodtstraintotal=sum(above99goodtstraintotal,1);%gives total number of cells always on and total number of cells in tstrains

totals(1).upto0sponttotal=sum(upto0sponttotal,1);%gives total number of cells never on and total number of cells in sponts   
totals(1).upto33sponttotal=sum(upto33sponttotal,1);%gives total number of cells upto 33.3% of time on and total number of cells in sponts
totals(1).upto66sponttotal=sum(upto66sponttotal,1);%gives total number of cells upto 66.7% of time on and total number of cells in sponts
totals(1).upto99sponttotal=sum(upto99sponttotal,1);%gives total number of cells upto but not including 100% of time on and total number of cells insponts
totals(1).above99sponttotal=sum(above99sponttotal,1);%gives total number of cells always on and total number of cells in sponts

totals(1).upto0goodsponttotal=sum(upto0goodsponttotal,1);%gives total number of cells never on and total number of cells in sponts   
totals(1).upto33goodsponttotal=sum(upto33goodsponttotal,1);%gives total number of cells upto 33.3% of time on and total number of cells in sponts
totals(1).upto66goodsponttotal=sum(upto66goodsponttotal,1);%gives total number of cells upto 66.7% of time on and total number of cells in sponts
totals(1).upto99goodsponttotal=sum(upto99goodsponttotal,1);%gives total number of cells upto but not including 100% of time on and total number of cells insponts
totals(1).above99goodsponttotal=sum(above99goodsponttotal,1);%gives total number of cells always on and total number of cells in sponts

disp (strcat('Proportion cells in good ts movies that never come on = ',num2str(totals(1).upto0goodtstraintotal(1)),' / ',num2str(totals(1).upto0goodtstraintotal(2)),' = ',num2str(totals(1).upto0goodtstraintotal(1)/totals(1).upto0goodtstraintotal(2))))
disp (strcat('Proportion cells in good ts movies that are on in 0-1/3 of movies = ',num2str(totals(1).upto33goodtstraintotal(1)),' / ',num2str(totals(1).upto33goodtstraintotal(2)),' = ',num2str(totals(1).upto33goodtstraintotal(1)/totals(1).upto33goodtstraintotal(2))))
disp (strcat('Proportion cells in good ts movies that are on in 1/3-2/3 of movies = ',num2str(totals(1).upto66goodtstraintotal(1)),' / ',num2str(totals(1).upto66goodtstraintotal(2)),' = ',num2str(totals(1).upto66goodtstraintotal(1)/totals(1).upto66goodtstraintotal(2))))
disp (strcat('Proportion cells in good ts movies that are on in 2/3-99% of movies = ',num2str(totals(1).upto99goodtstraintotal(1)),' / ',num2str(totals(1).upto99goodtstraintotal(2)),' = ',num2str(totals(1).upto99goodtstraintotal(1)/totals(1).upto99goodtstraintotal(2))))
disp (strcat('Proportion cells in good ts movies that come on in all movies = ',num2str(totals(1).above99goodtstraintotal(1)),' / ',num2str(totals(1).above99goodtstraintotal(2)),' = ',num2str(totals(1).above99goodtstraintotal(1)/totals(1).above99goodtstraintotal(2))))
disp (' ')
disp (strcat('Proportion cells in good spont movies that never come on = ',num2str(totals(1).upto0goodsponttotal(1)),' / ',num2str(totals(1).upto0goodsponttotal(2)),' = ',num2str(totals(1).upto0goodsponttotal(1)/totals(1).upto0goodsponttotal(2))))
disp (strcat('Proportion cells in good spont movies that are on in 0-1/3 of movies = ',num2str(totals(1).upto33goodsponttotal(1)),' / ',num2str(totals(1).upto33goodsponttotal(2)),' = ',num2str(totals(1).upto33goodsponttotal(1)/totals(1).upto33goodsponttotal(2))))
disp (strcat('Proportion cells in good spont movies that are on in 1/3-2/3 of movies = ',num2str(totals(1).upto66goodsponttotal(1)),' / ',num2str(totals(1).upto66goodsponttotal(2)),' = ',num2str(totals(1).upto66goodsponttotal(1)/totals(1).upto66goodsponttotal(2))))
disp (strcat('Proportion cells in good spont movies that are on in 2/3-99% of movies = ',num2str(totals(1).upto99goodsponttotal(1)),' / ',num2str(totals(1).upto99goodsponttotal(2)),' = ',num2str(totals(1).upto99goodsponttotal(1)/totals(1).upto99goodsponttotal(2))))
disp (strcat('Proportion cells in good spont movies that come on in all movies = ',num2str(totals(1).above99goodsponttotal(1)),' / ',num2str(totals(1).above99goodsponttotal(2)),' = ',num2str(totals(1).above99goodsponttotal(1)/totals(1).above99goodsponttotal(2))))
