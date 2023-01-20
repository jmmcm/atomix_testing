function [ax,ph] = plot_histogram_A0(ax,data,flags,options)
% Plot a histogram of the A0 values showing the thresholds
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
ph(pcount) = histogram(data.REGRESSION_COEFF_A0(:),options.nbins);
lStr{pcount} = 'Data';
hold all

% grey out areas beyond thresholds
thresholdA0Low  = flags.dll_intercept_too_low.threshold;
thresholdA0High = flags.dll_intercept_too_high.threshold;
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
fill_transparent([thresholdA0High xlimits(2)],ylimits,0.6*[1 1 1])
fill_transparent([xlimits(1) thresholdA0Low],ylimits,0.6*[1 1 1])

% Add vertical line for expected value
if isfield(options,'A0expected')
    pcount = pcount+1;
    ph(pcount) = plot(options.A0expected*[1 1],ylimits,'r');
    lStr{pcount} = '2\sigma_N^2';
end

% Formatting
xlim(xlimits)
ylim(ylimits)
xlabel('A0 [m^2 s^{-2}]')
ylabel('count') 
title(options.titleStr)
if options.legend
    legend(ph,lStr)
end
