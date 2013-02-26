% Example Data
% rawdata={[100 200 300],[50 200 300],[100 200 300],[100 200 300],[100 200 300],[50 200 300],[50 200 300],[1],[1],[1]};
% % rawdata={100*rand(1,3),100*rand(1,3),100*rand(1,3),100*rand(1,3),100*rand(1,3),100*rand(1,3),100*rand(1,3)};
% classes=[1,2,1,1,1,2,2,3,3,3];
% distfunc='spkd';
% distfuncparam=1;
% gravity=1;%-1;%a factor determining how much outliars vs center-liars are taken into account during averaging... just set to linear


function h=discriminator(rawdata,classes,distfunc,distfuncparam,gravity);
% function h=discriminator(rawdata,classes,distfunc,distfuncparam,gravity);
% Uses the distance function "distfunc" to find distances between pairs of
% entries in the cell "rawdata".  Each entry is has a category and this
% category is specified by the entry in the vector "classes" (entry number
% X in rawdata is in the class specified by entry X in classes).  Classes
% are specied as integer numbers.
% Using the distances measured, in conjunction with the classes, this
% function will create a confusion matrix by attempting to classify each
% rawdata based only on its distance from all other rawdata from each
% classs.  Based on this confusion matrix, a measure of the information
% tranmitted about class by the rawdata will be generated and output as h.
% h will be between 0 (least information) and 1 (most information).
% 
% rawdata - a linear cell array containing whatever is to be measured against 
%               each other
% classes - a vector specfiying the class number of each rawdata
% distfunc - a string containing the name of a function that will give a
%               distance between two rawdata as a function of parameter
%               distfuncparam.  Must have format
%               distance=distfunc(rawdata{1},rawdata{2},distfuncparam);
%               ie 'spkd'
% distfuncparam - see above (ie Q for spkd)
% gravity - a factor determining how outliers versus centerliers are used
%               to determine the mean position of the clusters used to
%               classify each rawdata (1 is normal mean, -2 is
%               "gravitational" mean, de-emphasizing outliers).
% h - output, giving a measure of information transmitted by the rawdata
%               about the classes they are in

warning off

numclasses=max(classes);
confmat=zeros(numclasses,numclasses);
for a=1:length(rawdata);%for every rawdata
    vals=cell(1,numclasses);
	others=1:length(rawdata);%make a list of all rawdata
	others(a)=[];%except the current one
    means=NaN*ones(1,numclasses);
	for b=1:length(others);%for each of those others
        eval(['d=',distfunc,'(rawdata{a},rawdata{others(b)},distfuncparam);']);
            %get the distance between the rawdata at hand and the current
            %other rawdata
        vals{classes(others(b))}(end+1)=d;%store the distance in a place corresponding
            %to its class    
    end
    for b=1:length(vals);
        if ~isempty(vals{b});
            if gravity==1;
                means(b)=mean(vals{b});
            else
                means(b)=mean(vals{b}.^gravity)^(1/-gravity);%produces Infs from
                    %0 distances.  How to deal with this?  For now just
                    %enter gravity=1 always.  Take out zero vals
                    %somewhere... ie if no spikes compared to no spikes
            end
        end
    end
    cls=find(means==min(means));%find which class(es) this spike train tended
        %to be less distant from
    confmat(classes(a),cls)=confmat(classes(a),cls)+1/length(cls);%fill in that
        %this rawdata had true class (classes(a)) and was guessed to be
        %class cls but adding one to that category of true/guessed classes.
        %(If many classes were equally likely, put in fractional value
        %1/(num of classes equally likely)
end

distrib=1/sum(sum(confmat)).*confmat;
firstterm=distrib.*log2(confmat);
firstterm(find(confmat==0))=0;%where there was 0*log(0), set to 0 (true in limit)
secondterm=distrib.*log2(repmat(sum(confmat,1),[size(confmat,1),1]));
thirdterm=distrib.*log2(repmat(sum(confmat,2),[1,size(confmat,2)]));
fourthterm=distrib.*log2(repmat(sum(sum(confmat)),[size(confmat)]));

h=sum(sum(firstterm-secondterm-thirdterm+fourthterm));