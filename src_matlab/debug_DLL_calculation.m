%% Detrended velocity (TODO: Needs to be cleaned)
if 1 
    figure_named('DetrendedVel'),clf, clear ax plotData
    indZ = testDetails.plotDLL.indZ+3*[-1,1]; % Needs to be centered an even number of bins apart
	offset = [0 0.1];

    for ii = 1:2
        t = data(1).L2.TIME(testDetails.plotDLL.indT,:)-data(1).L2.TIME(testDetails.plotDLL.indT,1);
        plot(t*24*3600,squeeze(data(1).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(ii),1,:))+offset(ii))
        hold all

        t = data(2).L2.TIME(testDetails.plotDLL.indT,:)-data(2).L2.TIME(testDetails.plotDLL.indT,1);
        plot(t*24*3600,squeeze(data(2).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(ii),1,:))+offset(ii))
        
    end
    legend('bin L - Control','bin L - Test','bin U - Control','bin U - Test')
    
    % Get indR
    [~,indR_C] = min(abs(data(1).L3.R_DEL(1,:)-(data(1).L3.Z_DIST(indZ(2))- data(1).L3.Z_DIST(indZ(1)))/cosd(20)));

    binPairs=[squeeze(data(2).L3.BIN_L(testDetails.plotDLL.indT,mean(indZ),1,:)) squeeze(data(2).L3.BIN_U(testDetails.plotDLL.indT,mean(indZ),1,:))];
    [~,indR_T] = ismember(indZ,binPairs,'rows');
    %indR_T = indR_C;% for averaging method 
    
    % Compare differences
    b.DLL_C_here = nanmean((data(1).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(2),1,:) - data(1).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(1),1,:)).^2);
    b.DLL_C_file = data(1).L3.DLL(testDetails.plotDLL.indT,mean(indZ),1,indR_C);
    b.DLL_T_here = nanmean((data(2).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(2),1,:) - data(2).L2.R_VEL_DETRENDED(testDetails.plotDLL.indT,indZ(1),1,:)).^2);
    b.DLL_T_file = data(2).L3.DLL(testDetails.plotDLL.indT,mean(indZ),1,indR_T);
    b
    
    figure_named('DLLdebugging'),clf,clear ax plotdata
    plotoptions.indT = testDetails.plotDLL.indT;
    plotoptions.indZ = mean(indZ);
    plotoptions.indB = 1;
    plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,plotoptions)
    hold all
    plot(data(1).L3.R_DEL(1,indR_C).^(2/3),data(1).L3.DLL(testDetails.plotDLL.indT,mean(indZ),1,indR_C),'*r')
    plot(data(2).L3.R_DEL(1,indR_T).^(2/3),data(2).L3.DLL(testDetails.plotDLL.indT,mean(indZ),1,indR_T),'dk')
    %legend('Cntl','','Test','','Cntl-Pt','Test-Pt')
end