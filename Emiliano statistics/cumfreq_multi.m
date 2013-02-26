function cumfreq_multi(varargin)

%Function to plot cumulative frequency of data
%
%Inputs: any number of datasets
%
%Outputs: ctrldist and trtdist are the cumulative frequency distributions for
% the ctrl and trt data sets.
%
%by Emiliano M. Rial Verde
%March 2004

close(figure(1))


for j=1:nargin
    a=varargin{j};
    amin=floor(min(a));
    amax=ceil(max(a));
    intervalnum=size(a,1)*2;
    interval=[];
    interval=([amin : (abs(amax)-amin)/intervalnum : amax])';
    c=[];
    for i=1:size(interval,1)
        c=[c; sum(a<=interval(i,1))/size(a,1)];
    end
    
    ksxaxis=interval;
    ctrldist=c;
    
    line_color=[round(rand) round(rand) round(rand)];
    while sum(line_color)==3
        line_color=[round(rand) round(rand) round(rand)];
    end
    
    h0=figure(1);
    set(h0, 'numbertitle', 'off', ...
        'name', 'Cumulative frequency plot', ...
        'units', 'normalized', ...
        'position', [.005 .35 .5469 .5469]);
    orient landscape;
    plot(ksxaxis, ctrldist, 'linewidth', [2], 'color', line_color);
    set(gca, 'ylim', [0 1]);
    hold on;
end