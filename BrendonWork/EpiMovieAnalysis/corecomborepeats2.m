function [realt,reals,realts]=comborepeats2(sorted,goodperslice);
%outputs are percent of cells shared between two movies that are in
%lockstep (not percent of all activity, just cells in either category)

% goodperslice=2;
tic
warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

% for y=1:size(sorted,2);%for each slice
%     if ~isempty(sorted{y}.tstrain)%j;%if there were tstrain movies for this slice, then...
%         for z=1:size(sorted{y}.tstrain,2)
%             coll=logical(sum(sorted{y}.tstrain(z).ons,1));%collapse data from all frames into a single chunk of data
%             if sum(coll,2)>=10;%if total number of cells on in this movie is greater than 10:
%                 goodt(y,z)=1;%record that this movie was big enough... in this form for easy measuring of size
%             end
%         end
%     end
%     if ~isempty(sorted{y}.spont)%j;%if there were tstrain movies for this slice, then...
%         for z=1:size(sorted{y}.spont,2)
%             coll=logical(sum(sorted{y}.spont(z).ons,1));%collapse data from all frames into a single chunk of data
%             if sum(coll,2)>=10;%if total number of cells on in this movie is greater than 10:
%                 goods(y,z)=1;%record that this movie was big enough... in this form for easy measuring of size
%             end
%         end
%     end
% end
% 
useablet=[];
useables=[];
useabletts=[];
useablests=[];
for a=1:size(sorted,2);%for each slice
    a
    n=size(sorted{a}.ttcore,2);%number of train core movies made
    if ~isempty(sorted{a}.ttcore);%if there is more than one movie with more than 10 cells coming on from slice "a"
%          g=find(goodt(a,:));
%          mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
%          for order=1:mo;%for every good movie
            order=2;
            ind=nchoosek(1:n,order);%generate all possible combos of indices of that number of movies from that dataset
            averagec=[];
            averageo=[];
            p=ind;%%%%making up for commenting out next two lines
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);%for each combo of indices
                    availonsc=[];%will store values of how many cells overlap in each compared pair of movies
                    availonso=[];%will store values of how many cells overlap in each compared pair of movies
%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
%                         movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movienumber=p(u,v);%take the number of the movie to use
                        if v==1;
                            comparec=sorted{a}.ttcore{movienumber};
                            availonsc(end+1)=sum(logical(sum(comparec)));
                            compareo=sorted{a}.ttother{movienumber};
                            availonso(end+1)=sum(logical(sum(compareo)));
                        else
                            availonsc(end+1)=sum(logical(sum(comparec)).*logical(sum(sorted{a}.ttcore{movienumber})));%record overlap for each pair compared
                            [comparec,trash]=findbestrepeats(comparec,sorted{a}.ttcore{movienumber});%find best repeats between those two
                            availonso(end+1)=sum(logical(sum(compareo)).*logical(sum(sorted{a}.ttother{movienumber})));%record overlap for each pair compared
                            [compareo,trash]=findbestrepeats(compareo,sorted{a}.ttother{movienumber});%find best repeats between those two
                        end
                    end
                    numerc=sum(logical(sum(comparec)));%how many cells overlapped between these
                    denomc=min(availonsc);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    numero=sum(logical(sum(compareo)));%how many cells overlapped between these
                    denomo=min(availonso);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    if numerc==1;%lockstep of one cell means no lockstep
                        numerc=0;
                    end
                    if numero==1;%lockstep of one cell means no lockstep
                        numero=0;
                    end
                    averagec(end+1)=numerc/denomc;%running average of percent from each comparison indicated by "ind"
                    averageo(end+1)=numero/denomo;%running average of percent from each comparison indicated by "ind"
                end
%             end
%             avgtc(a,order)=mean(average);
            avgtc(a)=mean(averagec(~isnan(averagec)));
            avgto(a)=mean(averageo(~isnan(averageo)));
            useablet(a)=1;
%          end
    end
    useablet=logical(useablet);
    n=size(sorted{a}.sscore,2);%number of train core movies made
    if ~isempty(sorted{a}.sscore);%if there is more than one movie with more than 10 cells coming on from slice "a"
%          g=find(goods(a,:));
%          mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
%          for order=1:mo;%for every good movie
            order=2;
            ind=nchoosek(1:n,order);%generate all possible combos of indices of that number of movies from that dataset
            averagec=[];
            averageo=[];
            p=ind;%%%%making up for commenting out next two lines
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);%for each combo of indices
                    availonsc=[];%will store values of how many cells overlap in each compared pair of movies
                    availonso=[];%will store values of how many cells overlap in each compared pair of movies
%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
%                         movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movienumber=p(u,v);%take the number of the movie to use
                        if v==1;
                            comparec=sorted{a}.sscore{movienumber};
                            availonsc(end+1)=sum(logical(sum(comparec)));
                            compareo=sorted{a}.ssother{movienumber};
                            availonso(end+1)=sum(logical(sum(compareo)));
                        else
                            availonsc(end+1)=sum(logical(sum(comparec)).*logical(sum(sorted{a}.sscore{movienumber})));%record overlap for each pair compared
                            [comparec,trash]=findbestrepeats(comparec,sorted{a}.sscore{movienumber});%find best repeats between those two
                            availonso(end+1)=sum(logical(sum(compareo)).*logical(sum(sorted{a}.ssother{movienumber})));%record overlap for each pair compared
                            [compareo,trash]=findbestrepeats(compareo,sorted{a}.ssother{movienumber});%find best repeats between those two
                        end
                    end
                    numerc=sum(logical(sum(comparec)));%how many cells overlapped between these
                    denomc=min(availonsc);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    numero=sum(logical(sum(compareo)));%how many cells overlapped between these
                    denomo=min(availonso);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    if numerc==1;%lockstep of one cell means no lockstep
                        numerc=0;
                    end
                    if numero==1;%lockstep of one cell means no lockstep
                        numero=0;
                    end
                    averagec(end+1)=numerc/denomc;%running average of percent from each comparison indicated by "ind"
                    averageo(end+1)=numero/denomo;%running average of percent from each comparison indicated by "ind"
                end
%             end
%             avgtc(a,order)=mean(average);
            avgsc(a)=mean(averagec(~isnan(averagec)));
            avgso(a)=mean(averageo(~isnan(averageo)));
            useables(a)=1;
%          end
    end
    useables=logical(useables);
    n=size(sorted{a}.ttscore,2);%number of train core movies made
    m=size(sorted{a}.stscore,2);%number of train core movies made
    if n>=1 & m>=1;%if both spont and stim in this slice have at least one good movie
            order=2;
            ind=nchoosek(1:n,order);%generate all possible combos of indices of that number of movies from that dataset
            averagec=[];
            averageo=[];
            p=ind;%%%%making up for commenting out next two lines
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);%for each combo of indices
                    availonsc=[];%will store values of how many cells overlap in each compared pair of movies
                    availonso=[];%will store values of how many cells overlap in each compared pair of movies
%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
%                         movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movienumber=p(u,v);%take the number of the movie to use
                        if v==1;
                            comparec=sorted{a}.ttscore{movienumber};
                            availonsc(end+1)=sum(logical(sum(comparec)));
                            compareo=sorted{a}.ttsother{movienumber};
                            availonso(end+1)=sum(logical(sum(compareo)));
                        else
                            availonsc(end+1)=sum(logical(sum(comparec)).*logical(sum(sorted{a}.ttscore{movienumber})));%record overlap for each pair compared
                            [comparec,trash]=findbestrepeats(comparec,sorted{a}.ttscore{movienumber});%find best repeats between those two
                            availonso(end+1)=sum(logical(sum(compareo)).*logical(sum(sorted{a}.ttsother{movienumber})));%record overlap for each pair compared
                            [compareo,trash]=findbestrepeats(compareo,sorted{a}.ttsother{movienumber});%find best repeats between those two
                        end
                    end
                    numerc=sum(logical(sum(comparec)));%how many cells overlapped between these
                    denomc=min(availonsc);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    numero=sum(logical(sum(compareo)));%how many cells overlapped between these
                    denomo=min(availonso);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    if numerc==1;%lockstep of one cell means no lockstep
                        numerc=0;
                    end
                    if numero==1;%lockstep of one cell means no lockstep
                        numero=0;
                    end
                    averagec(end+1)=numerc/denomc;%running average of percent from each comparison indicated by "ind"
                    averageo(end+1)=numero/denomo;%running average of percent from each comparison indicated by "ind"
                end
%             end
%             avgtc(a,order)=mean(average);
            avgstsc(a)=mean(averagec(~isnan(averagec)));
            avgstso(a)=mean(averageo(~isnan(averageo)));
            useablests(a)=1;
        %%%%%%%%%    
            order=2;
            ind=nchoosek(1:m,order);%generate all possible combos of indices of that number of movies from that dataset
            averagec=[];
            averageo=[];
            p=ind;%%%%making up for commenting out next two lines
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);%for each combo of indices
                    availonsc=[];%will store values of how many cells overlap in each compared pair of movies
                    availonso=[];%will store values of how many cells overlap in each compared pair of movies
%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
%                         movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movienumber=p(u,v);%take the number of the movie to use
                        if v==1;
                            comparec=sorted{a}.stscore{movienumber};
                            availonsc(end+1)=sum(logical(sum(comparec)));
                            compareo=sorted{a}.stsother{movienumber};
                            availonso(end+1)=sum(logical(sum(compareo)));
                        else
                            availonsc(end+1)=sum(logical(sum(comparec)).*logical(sum(sorted{a}.stscore{movienumber})));%record overlap for each pair compared
                            [comparec,trash]=findbestrepeats(comparec,sorted{a}.stscore{movienumber});%find best repeats between those two
                            availonso(end+1)=sum(logical(sum(compareo)).*logical(sum(sorted{a}.stsother{movienumber})));%record overlap for each pair compared
                            [compareo,trash]=findbestrepeats(compareo,sorted{a}.stsother{movienumber});%find best repeats between those two
                        end
                    end
                    numerc=sum(logical(sum(comparec)));%how many cells overlapped between these
                    denomc=min(availonsc);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    numero=sum(logical(sum(compareo)));%how many cells overlapped between these
                    denomo=min(availonso);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    if numerc==1;%lockstep of one cell means no lockstep
                        numerc=0;
                    end
                    if numero==1;%lockstep of one cell means no lockstep
                        numero=0;
                    end
                    averagec(end+1)=numerc/denomc;%running average of percent from each comparison indicated by "ind"
                    averageo(end+1)=numero/denomo;%running average of percent from each comparison indicated by "ind"
                end
%             end
%             avgtc(a,order)=mean(average);
            avgttsc(a)=mean(averagec(~isnan(averagec)));
            avgttso(a)=mean(averageo(~isnan(averageo)));
            useabletts(a)=1;
        end
    useabletts=logical(useabletts);        
    useablests=logical(useablests);        
end

tc=avgtc(useablet);%percents for slices for train core cells
to=avgto(useablet);%percents for slices for train non-core (other) cells
sc=avgsc(useables);%percents for slices for spont core cells
so=avgso(useables);%percents for slices for spont non-core (other) cells
tc=tc(~isnan(tc));
to=to(~isnan(to));
sc=sc(~isnan(sc));
so=so(~isnan(so));
errorbargraph([mean(tc) mean(to) mean(sc) mean(so)],[std(tc) std(to) std(sc) std(so)]);

ttsc=avgttsc(useabletts);
ttso=avgttso(useabletts);
stsc=avgstsc(useablests);
stso=avgstso(useablests);
ttsc=ttsc(~isnan(ttsc));
ttso=ttso(~isnan(ttso));
stsc=stsc(~isnan(stsc));
stso=stso(~isnan(stso));
errorbargraph([mean(ttsc) mean(ttso) mean(stsc) mean(stso)],[std(ttsc) std(ttso) std(stsc) std(stso)]);


% for a=1:size(avgt,2);%for each order
%     comp=find(useablet(:,a));%find indices of slices where comparisons were done
%     comp=avgt(comp,a);
%     comp=comp(~isnan(comp));
%     realt(a)=mean(comp);%take the mean of those and store
% end
% for a=1:size(avgs,2);%for each order
%     comp=find(useables(:,a));%find indices of slices where comparisons were done
%     comp=avgs(comp,a);
%     comp=comp(~isnan(comp));
%     reals(a)=mean(comp);%take the mean of those and store
% end
% for a=1:size(avgts,2);%for each order
%     comp=find(useablets(:,a));%find indices of slices where comparisons were done
%     comp=avgts(comp,a);
%     comp=comp(~isnan(comp));
%     realts(a)=mean(comp);%take the mean of those and store
% end

% for a=1:size(t,2);comp=find(t(:,a));realt(a)=mean(t(comp,a));end
% % figure;
% hold on
% plot(mt,'r');
% plot(ms)
% title('Triggered in Red.  Spont in Blue');
figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r')

toc