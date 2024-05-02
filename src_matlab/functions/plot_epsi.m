function plot_epsi(ax,lev4,options)
% Plot time series of dissipation rate
%
% Justine McMillan
% Apr 15, 2022
%
% TODO: Add second x axes to plot vs index

indB = options.indB;
indZ = options.indZ;

x = get_yd(lev4.TIME);
% x = 1:length(lev4.TIME);

plot(ax,x,lev4.EPSI(:,indZ,indB),'k','linewidth',2,'DisplayName','\epsilon')
hold all
plot(ax,x,(lev4.EPSI_CI_LOW(:,indZ,indB)'),'--r','DisplayName','CI\_low')
plot(ax,x,(lev4.EPSI_CI_HIGH(:,indZ,indB)'),'--r','DisplayName','CI\_high')
set(ax,'yscale','log')

title(['EPSI(:,',num2str(indZ),',',num2str(indB),')'])
legend show

