function tracenshade(timeline, data, datatype, shadetype, varargin)

%Function to plot a data trace and a shaded patch behind it.
%
%OPTIONAL INPUT ARGUMENTS
%For the type of data summary trace enter one of the possible 3rd input
%arguments:
%'mean': Mean trace (default)
%'median': Median trace
%
%For the shaded patch enter one of the possible 4th input arguments:
%'range': Range of the data (default)
%'iqr': Inter-quartile range
%'std': Standard deviation
%'sem': Standard error of the mean
%
%To determine how the borders of the patch are filtered, enter one of the
%possible 5th input arguments:
%'median': Median filter. Provide the number of samples to use for the
%          filter. The default (no 6th input argument provided) is 10.
%'mean': Moving average filter. Provide the number of samples to use for the
%        filter. The default (no 6th input argument provided) is 10.
%'savitzky-golay': Savitzky-Golay filter. Provide the polynomial order and frame size.
%                  The defaults (no 6th and/or 7th input arguments
%                  provided) are 1 and 11 respectively.
%
%NOTES:
%All operations in the data are row-wise, i.e. mean(data) returns 1 value per column.
%Arrange the data input accordingly, for example, put one trace per row.
%
%by Emiliano Rial Verde
%emiliano@rialverde.com
%May 2007
%Matlab 7.2.0.232 (R2006a)


if nargin<2
    errordlg('Error in the number of input arguments. Type: help tracenshade');
    return
elseif nargin<3
    datatype='mean';
elseif nargin<4
    shadetype='range';
end

if strcmpi(datatype, 'mean')
    datamean=mean(data);
elseif strcmpi(datatype, 'median')
    datamean=median(data);
else
    errordlg('Wrong 3rd input argument. Type: help tracenshade');
    return
end

if strcmpi(shadetype, 'range')
    datamin=min(data);
    datamax=max(data);
elseif strcmpi(shadetype, 'iqr')
    datamin=prctile(data,25);
    datamax=prctile(data,75);
elseif strcmpi(shadetype, 'std')
    datamin=datamean-std(data);
    datamax=datamean+std(data);
elseif strcmpi(shadetype, 'sem')
    datamin=datamean-std(data)/sqrt(size(data,1));
    datamax=datamean+std(data)/sqrt(size(data,1));
else
    errordlg('Wrong 4th input argument. Type: help tracenshade');
    return
end

figure
if nargin>4
    if strcmpi(varargin{1}, 'median')
        if nargin==6
            n=varargin{2};
        else
            n=10;
        end
        filtertext=['median filtered with N=', num2str(n)];
        patch([timeline'; flipud(timeline')], [medfilt1(datamin',n); medfilt1(flipud(datamax'),n)], 'c', 'EdgeColor', 'none');
    elseif strcmpi(varargin{1}, 'mean')
        if nargin==6
            n=varargin{2};
        else
            n=10;
        end
        filtertext=['mean filtered with N=', num2str(n)];
        patch([timeline'; flipud(timeline')], [filter(ones(1,n)/n,1,datamin'); filter(ones(1,n)/n,1,flipud(datamax'))], 'c', 'EdgeColor', 'none');
    elseif strcmpi(varargin{1}, 'savitzky-golay')
        if nargin==7
            n=varargin{2};
            n2=varargin{3};
        else
            n=1;
            n2=11;
        end
        filtertext=['Savitzky-Golay filtered with K=', num2str(n), ' and F=', num2str(n2)];
        patch([timeline'; flipud(timeline')], [sgolayfilt(datamin',n,n2); sgolayfilt(flipud(datamax'),n,n2)], 'c', 'EdgeColor', 'none');
    else
        errordlg('Wrong 5th input argument. Type: help tracenshade');
        return
    end
else
    filtertext='unfiltered';
    patch([timeline'; flipud(timeline')], [datamin'; flipud(datamax')], 'c', 'EdgeColor', 'none');
end
hold on;
plot(timeline, datamean);
title(['Trace: ', datatype, ' - Shade: ', shadetype, ', ', filtertext])