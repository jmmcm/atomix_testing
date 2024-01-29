function [p,pl]=plot_DLL_compare(lev3Cntl,lev4Cntl,lev3Test,lev4Test,options)
% Plot Dll vs r^2/3 for two different datasets
%
% Justine McMillan
% July 4, 2022
%
% 2023-01-23: Only plot values less than R_MAX
% 2023-04-08: Adapt to new data format (forward DLL only)

for ii = 1:2
    if ii == 1
        lev3 = lev3Cntl;
        lev4 = lev4Cntl;
        pcount = 0;
        marker = 'o';
        markersize = 5;
    elseif ii == 2
        lev3 = lev3Test;
        lev4 = lev4Test;
        marker = 's';
        markersize = 10;
    end
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
        pcount = pcount+1;
        indT = options.indT(tt);
        
        % Get fit values (depends on method and options)
        Dnow = squeeze(DQC(indT,:,indB,:));
        [rFit,dFit,rFitA,dFitA,indDll,binPairs] = get_DLL_fit_data(indZ,rNow,Dnow,lev3.BIN_L,lev3.BIN_U,dr,lev4.procParams);

        
        % info about flags
        epsi = lev4.EPSI(indT,indZ,indB);
        epsi_flag = lev4.EPSI_FLAGS(indT,indZ,indB);
        DLL_flags = lev3.DLL_FLAGS(indT,indZ,indB,:);
        disp('--')
        disp(['indT = ', num2str(indT),', epsi = ',num2str(epsi)])  
        
        legendstr{pcount} = ['\epsilon = ', num2str(epsi,'%3.2e'),' W/kg, ',...
            'N = ',num2str(lev4.REGRESSION_N(indT,indZ,indB)), ', ',...
            'EPSI\_FLAG = ',num2str(epsi_flag)];
        p(pcount) = plot(rFit.^(2/3),dFit,'marker',marker,'markersize',markersize,'LineWidth',2,'Linestyle','none'); hold all
        %plot(rNow.^(2/3),DNow,'.','markersize',8);
        xval=[1 2.8];
        
        % Regresstion lines and 95% CI
        beta = [lev4.REGRESSION_COEFF_A0(indT,indZ,indB),lev4.REGRESSION_COEFF_A1(indT,indZ,indB)];
        [~,~,xFit,yFit] = plot_CI_regression_line(0.95,beta,rFit.^(2/3),dFit,struct('nPts',100,'xRange',[0 1.1*max(rFit).^(2/3)],'plotLines',0));
        pl(pcount) = plot(xFit,yFit,'color',get(p(pcount),'Color'),'linewidth',2);
    end
end
legend(p,legendstr)
titlestr = ['z = ',num2str(lev4.Z_DIST(indZ)),' m, ',...
    'b = ',num2str(lev4.N_BEAM(indB))];
title(titlestr)
xlabel('(\delta r)^{2/3} [m^{2/3}]')
ylabel('D_{LL} [m^2 s^{-2}]')