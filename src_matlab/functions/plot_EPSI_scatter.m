function [ax,ph] = plot_EPSI_scatter(ax,dataX,dataY,options)
% Plot a scatter plot of EPSI and show ratios
%
% Justine McMillan
% Nov 9, 2022

% options = struct();
% ax = subplot(121);
% dataX = data1.L4data.EPSI(:);
% dataY = data2.L4data.EPSI(:);
% options.limits = [1e-8 1e-4];
% options.ratios = [2 5 10];

if ~isfield(options,'titleStr'); options.titleStr = ''; end
if ~isfield(options,'legend'); options.legend = 1; end
if ~isfield(options,'oneTOone'); options.oneTOone = 1; end
if ~isfield(options,'ratios'); options.ratios = [2 10]; end
if ~isfield(options,'type'); options.type='standard'; end
if ~isfield(options,'nbins'); options.nbins=[200 200]; end % Number of bins for a density plot


colours = get(ax,'ColorOrder');



%% Plot scatter plot
ph = [];
switch options.type
    case 'standard'
        ph(1) = plot(dataX,dataY,'.','DisplayName','Data','markersize',5);
        set(ax,'xscale','log','yscale','log')
        hold all
    case 'density'
       % plot(log10(dataX), log10(dataY),'.','color',0.6*[1 1 1]) % Won't be seen, just to set plot
        hold all
        [values,centers] = hist3([log10(dataX) log10(dataY)],options.nbins);
        imagesc(centers{1},centers{2},(values.'))
        colormap(brewermap([],'Blues'))
        c = colorbar;
        ylabel(c,'number of points')
        caxis([0 max(max(values))/3])
end



% Get limits
if isfield(options,'limits')
    xlimits = options.limits;
    ylimits = options.limits;
else
    xlimits = get(gca,'xlim');
    ylimits = get(gca,'ylim');
end
limits = [min([xlimits,ylimits]) max([xlimits,ylimits])];
if strcmp(options.type, 'density')
    limits = log10(limits);
end
    
% One to one line
if options.oneTOone
   ph(end+1) = loglog(limits,limits,'k','DisplayName','1:1');
end
if options.ratios
    NR = length(options.ratios);
    for rr=1:NR
        col = colours(rr+1,:);
        switch options.type
            case 'standard' % Plotted on log axes
                yMin = 1/options.ratios(rr)*limits;
                yMax = options.ratios(rr)*limits;
            case 'density' % Plotted on linear axes log(AB) = logA + logB, and limits = log10(limits) above
                yMin = log10(1/options.ratios(rr))+limits;
                yMax = log10(options.ratios(rr))+limits;
        end
                
            
                plot(limits,yMin,'--','color',col,'linewidth',2);
                ph(end+1) = plot(limits,yMax,'--','color',col,'linewidth',2,'DisplayName',['factor of ' num2str(options.ratios(rr))]);
%             case 'density' 
%                 plot(log10(limits),rMin*log10(limits),'--','color',col,'linewidth',2);
%                 ph(end+1) = plot(log10(limits),rMax*log10(limits),'--','color',col,'linewidth',2,'DisplayName',['factor of ' num2str(rMax)]);
    
%         end
    end
end



%% Final Formatting
xlim(limits)
ylim(limits)
if isfield(options,'xlabelStr')
    xlabel(options.xlabelStr)
else
    xlabel('\epsilon_C [W/kg]')
end
if isfield(options,'ylabelStr')
    xlabel(options.ylabelStr)
else
    xlabel('\epsilon_T [W/kg]')
end
title(options.titleStr)
if options.legend
    legend(ph,'location','northwest')
end

