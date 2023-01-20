function [ax,ph] = plot_scatter(ax,dataX,dataY,optionsIn)
% Plot a scatter plot of ATOMIX variables and show thresholds
%
% Justine McMillan
% Nov 9, 2022

% options = struct();
% ax = subplot(121);
% data.x = data1.L4data.EPSI(:);
% data.y = data2.L4data.EPSI(:);
% data.varX = 'EPSI'
% data.varY = 'EPSI';
% optionsIn.scale = 'log';
% optionsIn.ratios = [0.5 1 2];

nData = length(data);

options = optionsIn;
if ~isfield(options,'titleStr'); options.titleStr = ''; end
if ~isfield(options,'legend'); options.legend = 1; end



%% Plot scatter plot
plot(data.x,data.y,'.')
hold all

% Set scale
if isfield(options,'scale')
    set(ax,'xscale',options.scale,'yscale',options.scale)
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



        loglog(limits,limits,'k')
        loglog((limits),(2*limits),'--k','linewidth',1)
        loglog((limits),(0.5*limits),'--k','linewidth',1)



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
ylabel('count')
title(options.titleStr)
if options.legend
    legend(ph)
end
