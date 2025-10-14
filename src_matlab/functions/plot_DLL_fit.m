function [ax,p,t,cbar] = plot_DLL_fit(ax,lev3,lev4,options)
% Plot Dll vs r^2/3 and show fit
%
% Justine McMillan
% Apr 15, 2022
%
% Apr 8, 2023 - Adapted to work with updated data format using only forward
%               diff DLL

if ~isfield(options,'colorbar')
    options.colorbar = 1;
end
% Get r and D values and apply flags
rAll = lev3.R_DEL;
DAll = lev3.DLL;
DQC = flag_data(DAll,lev3.DLL_FLAGS,0);

%
indB = options.indB;
indZ = options.indZ;

rNow = squeeze(rAll(indB,:))';
dr = lev3.R_DIST(2,indB) - lev3.R_DIST(1,indB);

for tt = 1:length(options.indT)
    indT = options.indT(tt);
    
    % Get fit values (depends on method and options)
    Dnow = squeeze(DQC(indT,:,indB,:));
    [rFit,dFit,rFitA,dFitA,indDll,binPairs] = get_DLL_fit_data(indZ,rNow,Dnow,lev3.BIN_L,lev3.BIN_U,dr,options);
    ind = find(~isnan(dFit));
    rFit = rFit(ind);
    dFit = dFit(ind);
    
    % Check that extracted values agree with saved values
    dFitSaved = squeeze(lev4.REGRESSION_DLL(indT,indZ,indB,:))';
    rFitSaved = squeeze(lev4.REGRESSION_R_DEL(indT,indZ,indB,:));
    ind = find(~isnan(dFitSaved));
    dFitSaved = dFitSaved(ind);
    rFitSaved = rFitSaved(ind);
    
    if (sum(abs(dFitSaved - dFit)) > 1e-6) || (sum(abs(rFitSaved - rFit)) > 1e-6)
        error('Saved values inconsistent with extracted values')
    end
    
    % info about flags
    epsi = lev4.EPSI(indT,indZ,indB);
    epsi_flag = lev4.EPSI_FLAGS(indT,indZ,indB);
    disp('--')
    disp(['indT = ', num2str(indT),', epsi = ',num2str(epsi)])
    
    
    %     p(1) = plot(rFitA.^(2/3),dFitA,'.','markersize',8); hold all
    if length(dFitA)>0
        p(1) = scatter(rFitA.^(2/3),dFitA,50,binPairs(:,1),'filled','Linewidth',3); hold all
        caxis([min(binPairs(:,1))-1 max(binPairs(:,1))+1]) % Make the color range go +/-1 beyond values to avoid saturation
        if options.colorbar
            cbar = colorbar;
            ylabel(cbar,'binL')
        end
    end
    if length(dFit)>0
        p(2) = plot(rFit.^(2/3),dFit,'s','LineWidth',4);
        
        xval=[1 2.8];
        
        % Regresstion lines and 95% CI
        beta = [lev4.REGRESSION_COEFF_A0(indT,indZ,indB),lev4.REGRESSION_COEFF_A1(indT,indZ,indB)];
        [yUpp,yLow,xFit,yFit] = plot_CI_regression_line(0.95,beta,rFit.^(2/3),dFit,struct('nPts',100,'xRange',[0 1.1*max(rFit).^(2/3)],'plotLines',0));
        p(3) = plot(xFit,yFit,'k','linewidth',2);
        p(4) = plot(xFit,yLow,'--','color',0.4*[1 1 1],'linewidth',1);
        p(5) = plot(xFit,yUpp,'--','color',0.4*[1 1 1],'linewidth',1);
        lStr = {'All Points','Regression Points','Fit'};
        xlim = get(gca,'xlim');
        ylim = get(gca,'ylim');
        t = text(xlim(1),.95*ylim(2),...
            {[' \epsilon = ', num2str(epsi,'%3.2e'),' W/kg (flag = ' num2str(epsi_flag) ')'],...
            [' MAD = ',num2str(lev4.MAD(indT,indZ,indB)), ],...
            [' MSPE = ',num2str(lev4.MSPE(indT,indZ,indB))],...
            [' \Delta \epsilon / \epsilon = ',num2str(lev4.EPSI_DEL_RATIO(indT,indZ,indB))],...
            [' R2 = ',num2str(lev4.REGRESSION_R2(indT,indZ,indB))]},...
            'color','r','VerticalAlignment','Top');
        %                      'N = ',num2str(lev4.REGRESSION_N(indT,indZ,indB)), ', ',...
        %                      'EPSI\_FLAG = ',num2str(epsi_flag)]};
    else
        lStr = {};
        t = [];
    end
end

ax = gca;
pos = get(ax,'Position');
set(ax,'position',[pos(1),pos(2),pos(3),pos(4)]);
xlimits = get(ax,'xlim');

% axis for deltaBins
b=axes('Position',[pos(1),pos(2)+pos(4),pos(3), 1e-12]);
set(b,'Units','normalized');
set(b,'Color','none')
set(b,'xlim',xlimits);

nBinMax = floor(xlimits(2)^(3/2)/dr);
xticks = ([0:2:nBinMax]*dr).^(2/3);
for ii = 1:length(xticks)
    xtickLabels{ii} = num2str(2*ii-2);
end
set(b,'tickdir','out')
set(b,'xtick',xticks)
set(b,'xticklabels',xtickLabels)

legend(p,lStr,'location','southeast')
titlestr = ['z = ',num2str(lev4.Z_DIST(indZ)),' m, ',...
    'b = ',num2str(lev4.N_BEAM(indB))];
title(ax,titlestr)
xlabel(ax,'(\delta r)^{2/3} [m^{2/3}]')
xlabel(b,'\delta')
ylabel(ax,'D_{LL} [m^2 s^{-2}]')

box on

%delete(c)