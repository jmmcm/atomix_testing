function [ax,ph] = plot_histogram(ax,data,optionsIn)
% Plot a histogram of an ATOMIX variable and show thresholds
%
% Justine McMillan
% July 5, 2022
% JMM, Oct 10, 2022 - Updated to allow data to have more than one data set

% options = struct();
% ax = subplot(121);
% data.values = L4data.REGRESSION_COEFF_A0;
% data.label = 'A0';
% data.var = 'REGRESSION_COEFF_A0';
% data.thresLow = 0;
% data.thresHigh = 0.015;

nData = length(data);

options = optionsIn;
if ~isfield(options,'nbins'); options.nbins = 100; end
if ~isfield(options,'normalization'); options.normalization = 'count'; end
if ~isfield(options,'titleStr'); options.titleStr = ''; end
if ~isfield(options,'legend'); options.legend = 1; end
if ~isfield(options,'faceAlpha'); options.faceAlpha = 0.4; end
if ~isfield(options,'lineWidth'); options.lineWidth = 0.5; end
if ~isfield(options,'displayStyle'); options.displayStyle = 'bar'; end

colours = get(ax,'ColorOrder');

pcount = 0;

%% Plot histograms
for dd = 1:nData
    set(ax ,'Layer', 'Top')
    pcount = pcount+1;
    
    if ~isfield(optionsIn,'edgeColour'); options.edgeColour = colours(dd,:); end
    if ~isfield(options,'binLimits'); options.binLimits = [min(data(dd).values(:)) max(data(dd).values(:))]; end

    % legend label
    if isfield(data(dd),'label')
        dName = data(dd).label;
    else
        dName = clean_string(data(dd).var);
    end
    
    % plot
    ph(pcount) = histogram(data(dd).values(:),options.nbins,...
        'BinLimits',options.binLimits,...
        'Normalization',options.normalization,...
        'LineWidth',options.lineWidth,...
        'FaceAlpha',options.faceAlpha,...
        'EdgeColor',options.edgeColour,...
        'DisplayStyle',options.displayStyle,'DisplayName',dName);
    
    if dd == 1; hold all; end
end

% Get limits
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

% Shade regions beyond threshold
for dd = 1:nData
    if ~isfield(optionsIn,'edgeColour'); options.edgeColour = colours(dd,:); end
    if isfield(data(dd),'thresLow')
        fill_transparent([xlimits(1) data(dd).thresLow],ylimits,0.6*[1 1 1])
        pcount = pcount + 1;
        ph(pcount) = plot(data(dd).thresLow*[1 1],ylimits,'--','color',options.edgeColour,'linewidth',1.2,...
            'DisplayName',['Lower threshold (',num2str(data(dd).thresLow),')']);
    end
    if isfield(data(dd),'thresHigh')
        fill_transparent([data(dd).thresHigh xlimits(2)],ylimits,0.6*[1 1 1])
        pcount = pcount + 1;
        ph(pcount) = plot(data(dd).thresHigh*[1 1],ylimits,'--','color',options.edgeColour,'linewidth',1.2,...
            'DisplayName',['Upper threshold (',num2str(data(dd).thresHigh),')']);
    end

    % Add vertical line for expected value
    if isfield(data(dd),'expValue')
        pcount = pcount+1;
        ph(pcount) = plot(data(dd).expValue*[1 1],ylimits,'r','DisplayName',expValueStr);
    end
end



%% Final Formatting
xlim(xlimits)
ylim(ylimits)
if isfield(options,'xlabelStr')
    xlabel(options.xlabelStr)
end
ylabel(options.normalization)
title(options.titleStr)
if options.legend
    legend(ph)
end
