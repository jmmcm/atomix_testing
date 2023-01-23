function [ax,p] = plot_DLL_fit(ax,lev3,lev4,options)
% Plot Dll vs r^2/3 and show fit
%
% Justine McMillan
% Apr 15, 2022

% Get r and D values and apply flags
rAll = lev3.R_DEL;
DAll = lev3.DLL;
DQC = DAll;
DQC(lev3.DLL_FLAGS>0) = NaN;

%
indB = options.indB;
indZ = options.indZ;

rNow = squeeze(rAll(indB,:))';

for tt = 1:length(options.indT)
    indT = options.indT(tt);
    
    indR = find(rNow<lev4.R_MAX(indT,indZ,indB)*1.01);
    rNow = rNow(indR);
    
    
    DNow = squeeze(DAll(indT,indZ,indB,indR));
    DQCNow = squeeze(DQC(indT,indZ,indB,indR));
    
    % info about flags
    epsi = lev4.EPSI(indT,indZ,indB);
    epsi_flag = lev4.EPSI_FLAGS(indT,indZ,indB);
    DLL_flags = lev3.DLL_FLAGS(indT,indZ,indB,:);
    disp('--')
    disp(['indT = ', num2str(indT),', epsi = ',num2str(epsi)])
    %disp_flags(epsi_flag,struct('fileName',options.flagFile,'levelName','L4','varName','EPSI_FLAGS'))
%     for dd = 1:length(DLL_flags)
%         if DLL_flags(dd)~=0
%             disp(num2str(rNow(dd)^(3/2)))
%             disp_flags(DLL_flags(dd),struct('fileName',options.flagFile,'levelName','L3','varName','DLL_FLAGS'))
%         end
%     end
            
    
    legendstr{tt} = ['\epsilon = ', num2str(epsi,'%3.2e'),' W/kg, ',...
                     'N = ',num2str(lev4.REGRESSION_N(indT,indZ,indB)), ', ',...
                     'EPSI\_FLAG = ',num2str(epsi_flag)];
    p(tt) = plot(rNow.^(2/3),DQCNow,'o','LineWidth',2); hold all
    plot(rNow.^(2/3),DNow,'.','markersize',8);
    xval=[1 2.8];

    % Regresstion lines and 95% CI
    beta = [lev4.REGRESSION_COEFF_A0(indT,indZ,indB),lev4.REGRESSION_COEFF_A1(indT,indZ,indB)];
    [yUpp,yLow,xFit,yFit] = plot_CI_regression_line(0.95,beta,rNow.^(2/3),DQCNow,struct('nPts',100,'xRange',[0 1.1*max(rNow(~isnan(DNow)).^(2/3))],'plotLines',0));
    plot(xFit,yFit,'k','linewidth',2)
    plot(xFit,yLow,'--','color',0.4*[1 1 1],'linewidth',1)
    plot(xFit,yUpp,'--','color',0.4*[1 1 1],'linewidth',1)
end    
legend(p,legendstr)
titlestr = ['z = ',num2str(lev4.Z_DIST(indZ)),' m, ',...
            'b = ',num2str(lev4.N_BEAM(indB))];
title(titlestr)
xlabel('r^{2/3} [m^{2/3}]')
ylabel('D_{LL} [m^2 s^{-2}]')