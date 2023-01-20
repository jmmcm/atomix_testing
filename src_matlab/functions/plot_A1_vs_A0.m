function [ax,ph] = plot_A1_vs_A0(ax,data,flags,options)
% Plot A1 vs A0 showing the thresholds
%
% Justine McMillan
% July 5, 2022

if ~isfield(options,'nbins'); options.nbins = 100; end
if ~isfield(options,'titleStr'); options.titleStr = ''; end
if ~isfield(options,'legend'); options.legend = 1; end

set(ax ,'Layer', 'Top')
pcount = 0; 

% Scatter plot
pcount = pcount + 1;
ph(pcount) = plot(data.REGRESSION_COEFF_A0(:),data.REGRESSION_COEFF_A1(:),'.');
hold all

% Colour regions beyond thresholds
thresholdA0Low  = flags.dll_intercept_too_low.threshold;
thresholdA0High = flags.dll_intercept_too_high.threshold;
thresholdA1Low  = flags.dll_slope_out_of_range.threshold;
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
fill_transparent([thresholdA0High xlimits(2)],ylimits,'y')
fill_transparent([xlimits(1) thresholdA0Low],ylimits,'y')
fill_transparent(xlimits,[ylimits(1) thresholdA1Low],0.6*[1 1 1])

% Formatting
title(options.titleStr)
ylim(ylimits)
xlabel('A0 [m^2 s^{-2}]')
ylabel('A1 [m^{4/3} s^{-2}]')
