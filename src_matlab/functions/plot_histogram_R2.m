function [ax,ph] = plot_histogram_R2(ax,data,flags,options)
% Plot a histogram of the R2 values showing the thresholds
%
% Justine McMillan
% July 5, 2022

if ~isfield(options,'nbins'); options.nbins = 100; end
if ~isfield(options,'titleStr'); options.titleStr = ''; end
if ~isfield(options,'legend'); options.legend = 1; end


set(ax ,'Layer', 'Top')
pcount = 0; 

% Plot histogram
pcount = pcount+1;
ph(pcount) = histogram(data.REGRESSION_R2(:),options.nbins);
lStr{pcount} = 'Data';
hold all

% grey out areas beyond thresholds
thresholdR2  = flags.Rsquared_too_low.threshold;
if isfield(options,'xlimits')
    xlimits = options.xlimits; 
else
    xlimits = get(gca,'xlim');
end
if isfield(options,'ylimits')
    ylimits = options.ylimits; 
else
    ylimits = get(gca,'ylim');
end
fill_transparent([xlimits(1) thresholdR2],ylimits,0.6*[1 1 1])

% Formatting
xlim(xlimits)
ylim(ylimits)
xlabel('R2')
ylabel('count') 
title(options.titleStr)
if options.legend
    legend(ph,lStr)
end
