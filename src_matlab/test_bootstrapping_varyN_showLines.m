clear 
colors = get(0,'Defaultaxescolororder');

Nrealizations = [10 100 500 1000];

% Good data
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% processIDs = {'JMM_M2aC_RM5'}; 
% indZ = 17; indT = 160; indB = 1; clim = [-6 -4];

% Mediocre Data
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
% processIDs = {'JMM_M2aC_RM3'};
% indZ = 15; indT = 134; indB = 1; clim = [-6 -3];

% Poor data
dataSet = 'AQD_Windermere_bedframe';
processIDs = {'JMM_M2aC_RM2'};
indZ = 15; indT = 10; indB = 1; clim = [-10 -8];

%% load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end


%%

r = squeeze(data.L4.REGRESSION_R_DEL(indT,indZ,indB,:));
Dll = squeeze(data.L4.REGRESSION_DLL(indT,indZ,indB,:));
epsi = data.L4.EPSI(indT,indZ,indB);
epsi_ci = [data.L4.EPSI_CI_LOW(indT,indZ,indB) data.L4.EPSI_CI_HIGH(indT,indZ,indB)];

a0 = data.L4.REGRESSION_COEFF_A0(indT,indZ,indB);
a1 = data.L4.REGRESSION_COEFF_A1(indT,indZ,indB);

figure(1),clf
options = struct('indB',indB,'indT',indT,'indZ',indZ,...
    'colorbar',0,...
    'dll_averaging',d.metadataGroups.L4.dll_averaging,...
    'rMin',d.metadataGroups.L4.rMin,...
    'rMax',d.metadataGroups.L4.rMax,...
    'points_select_method',d.metadataGroups.L4.points_select_method);
ax = plot_DLL_fit(gca,data.L3,data.L4,options);
hold all
% Check r and Dll compared to automated plotting (seem to agree)
% plot(ax,r.^(2/3),Dll,'xk')
% plot(ax,r.^(2/3),2.0*epsi^(2/3).*r.^(2/3)+a0,'g')
title(ax,'')
title(['indT = ',num2str(indT),', indB = ', num2str(indB),', indZ = ',num2str(indZ)])



%% Show bootstrapping for different N
figure(2),clf
Nrealizations = [10,100,1000,10000];

for nn = 1:length(Nrealizations)
    ax(nn) = subplot(1,length(Nrealizations),nn);

    [epsiBS,epsiBS_ci(nn,:),Lin, aRange,dRange,stats]=bootstrap_structurefunction(r,Dll,Nrealizations(nn));
    
    xval = r.^(2/3);
    xfit = linspace(0,max(xval)+0.2,100);
    yfit = Lin.a*(xfit)+Lin.d;
    
    p(1) = plot(xval,Dll,'o','markersize',10,'color','k','markerfacecolor','k','DisplayName','Data');
    hold all
    plot(xfit,yfit,'k','linewidth',5,'DisplayName','Fit')
    
    % ax = gca
    % for rr = 1:length(stats)
    %     plot(ax,xval,stats(rr,1)*xval+stats(rr,2),'HandleVisibility','off')
    % end

    % Plot CIs from bootstrapping
    % ylower = aRange(1) .* xval + dRange(1);
    % yupper = aRange(2) .* xval + dRange(2);
    % fill([xval; flipud(xval)], [ylower; flipud(yupper)], ...
    %  'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');


    % Compute confidence interval at each point
    yfitBootstrap = zeros(Nrealizations(nn), length(xfit));
    for rr = 1:Nrealizations(nn)
        yfitBootstrap(rr,:) = stats(rr,1) .* xfit + stats(rr,2);
    end
    ylower = prctile(yfitBootstrap, 2.5, 1);
    yupper = prctile(yfitBootstrap, 97.5, 1);

    colors = colormap(parula(Nrealizations(nn))); 
    for rr = 1:Nrealizations(nn)
        plot(xfit,yfitBootstrap(rr,:),'color',colors(rr,:),'HandleVisibility','off')
    end
    plot(xfit,ylower,'r','LineWidth',3,'DisplayName','Bootstrap CIs')
    plot(xfit,yupper,'r','LineWidth',3,'HandleVisibility','off')

    % Plot standard regression
    beta = [a0,a1];
    [yUpp,yLow,xFit,yFit] = plot_CI_regression_line(0.95,beta,xval,Dll,struct('nPts',100,'xRange',[0 1.1*max(xval)],'plotLines',0));
    p(3) = plot(xFit,yFit,'k','linewidth',2,'HandleVisibility','off');
    p(4) = plot(xFit,yLow,'-','color',0.6*[1 0 1],'linewidth',3,'DisplayName','Regression CIs');
    p(5) = plot(xFit,yUpp,'-','color',0.6*[1 0 1],'linewidth',3,'HandleVisibility','off');

    
    ylabel('\epsilon [W/kg]')
    xlabel('(\delta r)^{2/3}')
    title(['N = ' num2str(Nrealizations(nn))])

    % 
    plot(xval,Dll,'o','markersize',10,'color','k','markerfacecolor','k','HandleVisibility','off')
    plot(xfit,yfit,'k','linewidth',5,'HandleVisibility','off')


    

    legend('location','southeast')

end
linkaxes(ax,'y')
ylim = get(ax(1),'ylim');
text(ax(1),0.05,1.9e-5,...
    {['\epsilon = ',num2str(epsi,'%3.1e'),' W/kg'],...
     ['\epsilon CIs = ',num2str(epsi_ci(1),'%3.1e'),' to ',num2str(epsi_ci(2),'%3.1e'),' W/kg (Regression)'],...
     ['\epsilon CIs = ',num2str(real(epsiBS_ci(1,1)),'%3.1e'),' to ',num2str(real(epsiBS_ci(1,2)),'%3.1e'),' W/kg (N=' num2str(Nrealizations(1)) ')'],...
     ['\epsilon CIs = ',num2str(real(epsiBS_ci(2,1)),'%3.1e'),' to ',num2str(real(epsiBS_ci(2,2)),'%3.1e'),' W/kg (N=' num2str(Nrealizations(2)) ')'],...
     ['\epsilon CIs = ',num2str(real(epsiBS_ci(3,1)),'%3.1e'),' to ',num2str(real(epsiBS_ci(3,2)),'%3.1e'),' W/kg (N=' num2str(Nrealizations(3)) ')'],...
     ['\epsilon CIs = ',num2str(real(epsiBS_ci(4,1)),'%3.1e'),' to ',num2str(real(epsiBS_ci(4,2)),'%3.1e'),' W/kg (N=' num2str(Nrealizations(4)) ')'],...

    })
