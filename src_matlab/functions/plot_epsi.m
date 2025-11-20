function p = plot_epsi(ax,lev4,options)
% Plot time series of dissipation rate
%
% Justine McMillan
% Apr 15, 2022
%
% TODO: Add second x axes to plot vs index

indB = options.indB;
indZ = options.indZ;

if ~isfield(options,'lc')
    options.lc = 'k';
end
if ~isfield(options,'varX')
    options.varX = 'yd';
end
if ~isfield(options,'marker')
    options.marker = 'none';
end

switch options.varX
    case 'yd'
        x = get_yd(lev4.TIME);
    case 'index'
        x = 1:length(lev4.TIME);
end

p(1) = plot(ax,x,lev4.EPSI(:,indZ,indB),'color',options.col,'marker',options.marker,... 
    'linewidth',1.5,'MarkerSize',10,'DisplayName','\epsilon');
hold(ax,'on')
p(2) = plot(ax,x,(lev4.EPSI_CI_LOW(:,indZ,indB)'),'--','color',options.col,'DisplayName','CI\_low');
p(3) = plot(ax,x,(lev4.EPSI_CI_HIGH(:,indZ,indB)'),'--','color',options.col,'DisplayName','CI\_high');
set(ax,'yscale','log')

title(ax,['EPSI(:,',num2str(indZ),',',num2str(indB),')'])
legend(ax)

