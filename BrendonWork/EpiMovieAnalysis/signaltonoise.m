function signaltonoise(sorted,conttemplates);
%this program opens up old "uptoons" files and uses info in them to more
%easily take signal to noise.  It also uses sorted and conttemps.

warning off MATLAB:conversionToLogical

di=dir;
di=di(60:end);%info for slices 1:57

for a=1:size(sorted,2);
    a
    base=di(a).name(2:10);
    eval(['load ',(di(a).name)]);
    eval(['pixels=pixels',base,';']);
    eval(['on=ons',base,';']);
%     pixels=normalizemovie(pixels);
    eval(['clear pixels',base,';']);
    eval(['clear ons',base,';']);
    eval(['clear image',base,';']);
    eval(['clear conts',base,';']);
    eval(['notes=notes',base,';']);
    eval(['clear notes',base,';']);
    eval(['lengths=lengths',base,';']);
    eval(['clear lengths',base,';']);
    traincells=[];
    for c=1:size(sorted{a}.tstrain);%for each train movie
        traincells=cat(2,traincells,find(logical(sum(sorted{a}.tstrain(c).ons))));%record which cells were active
    end
    traincells=unique(traincells);%eliminate repetitions
    spontcells=[];
    for c=1:size(sorted{a}.spont);%for each spont movie
        spontcells=cat(2,spontcells,find(logical(sum(sorted{a}.spont(c).ons))));%record which cells were active
    end
    spontcells=unique(spontcells);%eliminate repetitions
    activecells=union(traincells,spontcells);
    inactivecells=setdiff(1:length(sorted{a}.contours),activecells);
    
    
    cs=cumsum(lengths);
    cs(end+1)=0;
    cs=sort(cs);
    for bb=1:size(notes.stimprotocol,1);
        movie=pixels(:,:,(cs(bb)+1):cs(bb+1));
        df=-diff(movie,1,3);
        clear movie;
%         movie=normalizemovie(movie);
%         for b=1:size(movie,3);%for each frame
%             frame=movie(:,:,b);
%             for c=1:length(inactivecells);%for each contour of an inactive cell
%                 ip(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{inactivecells(c)}))/mean(frame(conttemplates{a}.outconts{inactivecells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(activecells);%for each contour of an inactive cell
%                 ap(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{activecells(c)}))/mean(frame(conttemplates{a}.outconts{activecells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(traincells);%for each contour of an inactive cell
%                 tp(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{traincells(c)}))/mean(frame(conttemplates{a}.outconts{traincells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(spontcells);%for each contour of an inactive cell
%                 sp(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{spontcells(c)}))/mean(frame(conttemplates{a}.outconts{spontcells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%         end
        cs=cumsum(lengths-1);
        cs(end+1)=0;
        cs=sort(cs);
        df=normalizemovie(df);
%         for b=1:size(df,3);%for each frame
%             frame=df(:,:,b);
%             for c=1:length(inactivecells);%for each contour of an inactive cell
%                 id(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{inactivecells(c)}))/mean(frame(conttemplates{a}.outconts{inactivecells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(activecells);%for each contour of an inactive cell
%                 ad(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{activecells(c)}))/mean(frame(conttemplates{a}.outconts{activecells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(traincells);%for each contour of an inactive cell
%                 td(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{traincells(c)}))/mean(frame(conttemplates{a}.outconts{traincells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%             for c=1:length(spontcells);%for each contour of an inactive cell
%                 sd(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{spontcells(c)}))/mean(frame(conttemplates{a}.outconts{spontcells(c)}));%find the signal to noise ratio for that cell in that frame
%             end
%         end
        if strcmp(notes.stimprotocol{bb},'TS') | strcmp(notes.stimprotocol{bb},'TC');%if a ts or tc movie
            framenum=(cs(bb)+1):cs(bb+1);
            for b=1:size(df,3);%for each frame
                frame=df(:,:,b);%extract it
                for c=1:length(traincells);%for each cell found to be on in any train movie
                    if on(framenum(b),traincells(c))==1;%if the cell was on in that frame
                        otd(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{traincells(c)}))/mean(frame(conttemplates{a}.outconts{traincells(c)}));
                    end
                end
%                 for c=1:size(sorted{a}.contours,2);%for all cells
%                     alltd(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{c}))/mean(frame(conttemplates{a}.outconts{c}));
%                 end
            end
        end
        spontornot=0;
        if strcmp(notes.stimprotocol{bb},'WD');%if window discriminator triggered movie
            if isempty(notes.stimnum{bb}) | isempty(str2num(notes.stimnum{bb})) | str2num(notes.stimnum{bb})<=1;
                % if no stimulation number listed, or if the text entry is
                % not of a number, or if the number is 1 or less
                spontornot=1;
            end
        elseif strcmp(notes.stimprotocol{bb},'LOOK') | strcmp(notes.stimprotocol{bb},'SCOPE') | strcmp(notes.stimprotocol{bb},'scope');
            spontornot=1;
        end
        spontornot
        if spontornot==1;
            framenum=(cs(bb)+1):cs(bb+1);
            for b=1:size(df,3);
                frame=df(:,:,b);
                for c=1:length(spontcells);
                    if on(framenum(b),spontcells(c))==1;
                        osd(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{spontcells(c)}))/mean(frame(conttemplates{a}.outconts{spontcells(c)}));
                    end
                end
%                 for c=1:size(sorted{a}.contours,2);%for all cells
%                     allsd(a,bb,b,c)=mean(frame(conttemplates{a}.inconts{c}))/mean(frame(conttemplates{a}.outconts{c}));
%                 end
            end
        end
	end    
    clear df
    clear pixels
    clear ons
    clear notes
end

% disp(['Raw image S:N for inactive cells: ',num2str(mean(ip(1:end)))]);
% disp(['Raw image S:N for active cells: ',num2str(mean(ap(1:end)))]);
% disp(['Raw image S:N for train cells: ',num2str(mean(tp(1:end)))]);
% disp(['Raw image S:N for spont cells: ',num2str(mean(sp(1:end)))]);
% 
% disp(['Df image S:N for inactive cells: ',num2str(mean(id(1:end)))]);
% disp(['Df image S:N for active cells: ',num2str(mean(ad(1:end)))]);
% disp(['Df image S:N for train cells: ',num2str(mean(td(1:end)))]);
% disp(['Df image S:N for spont cells: ',num2str(mean(sd(1:end)))]);

% disp(['Train movie df image S:N for all cells: ',num2str(mean(alltd(find(alltd))))]);
% disp(['Spont movie df image S:N for all cells: ',num2str(mean(allsd(find(allsd))))]);

disp(['Train movie df image S:N for on cells',num2str(mean(otd(find(otd))))]);
disp(['Spont movie df image S:N for on cells',num2str(mean(osd(find(osd))))]);