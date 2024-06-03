function [ax,p] = plot_DLL_fit(ax,lev3,lev4,options)
% Plot Dll vs r^2/3 and show fit
%
% Justine McMillan
% Apr 15, 2022
%
% Apr 8, 2023 - Adapted to work with updated data format using only forward
%               diff DLL

% Get r and D values and apply flags
rAll = lev3.R_DEL;
DAll = lev3.DLL;
DQC = flag_data(DAll,lev3.DLL_FLAGS,0);

%
indB = options.indB;
indZ = options.indZ;

rNow = squeeze(rAll(indB,:))';
dr = lev3.R_DIST(2) - lev3.R_DIST(1);

for tt = 1:length(options.indT)
    indT = options.indT(tt);
    
    % Get fit values (depends on method and options)
    Dnow = squeeze(DQC(indT,:,indB,:));
    [rFit,dFit,rFitA,dFitA,indDll,binPairs] = get_DLL_fit_data(indZ,rNow,Dnow,lev3.BIN_L,lev3.BIN_U,dr,options);

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
          
    
    p(1) = plot(rFitA.^(2/3),dFitA,'.','markersize',8); hold all
    p(2) = plot(rFit.^(2/3),dFit,'o','LineWidth',2); 
    xval=[1 2.8];

    % Regresstion lines and 95% CI
    beta = [lev4.REGRESSION_COEFF_A0(indT,indZ,indB),lev4.REGRESSION_COEFF_A1(indT,indZ,indB)];
    [yUpp,yLow,xFit,yFit] = plot_CI_regression_line(0.95,beta,rFit.^(2/3),dFit,struct('nPts',100,'xRange',[0 1.1*max(rFit).^(2/3)],'plotLines',0));
    p(3) = plot(xFit,yFit,'k','linewidth',2);
    plot(xFit,yLow,'--','color',0.4*[1 1 1],'linewidth',1)
    plot(xFit,yUpp,'--','color',0.4*[1 1 1],'linewidth',1)
    lStr = {'All Points','Regression Points',...
            ['\epsilon = ', num2str(epsi,'%3.2e'),' W/kg, ',...
                     'N = ',num2str(lev4.REGRESSION_N(indT,indZ,indB)), ', ',...
                     'EPSI\_FLAG = ',num2str(epsi_flag)]};
end    
legend(p,lStr,'location','southeast')
titlestr = ['z = ',num2str(lev4.Z_DIST(indZ)),' m, ',...
            'b = ',num2str(lev4.N_BEAM(indB))];
title(titlestr)
xlabel('r^{2/3} [m^{2/3}]')
ylabel('D_{LL} [m^2 s^{-2}]')