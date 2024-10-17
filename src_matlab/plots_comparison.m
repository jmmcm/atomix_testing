%% Script to compare data from tests
%
% Justine McMillan
% June 29, 2022

clear all
addpath('../../netcdftools_ceb/variables_flags_databases/YAMLMatlab_0/')
addpath('../../utilitieswork/')
addpath('../../utilitieswork/cmocean/')

mname = mfilename('fullpath');

set(groot,'DefaultFigurePosition',[0 0 500 500])
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

%% Select dataset and process IDs
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
%     processIDs = {'dJMM_M2uC_RM5','JMM_M2uC_RM5'}; % COmpare to downloaded data
%     processIDs = {'JMM_M1aC_RM5','JMM_M2aC_RM5','JMM_M2uC_RM5','JMM_M3uC_RM5'};
%     processIDs = {'JMM_M2uC_RM5','JMM_M3uC_RM5'};
%     processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5'};
%     processIDs = {'JMM_M2aC_RM5','JMM_M3uC_RM5'};


% dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
%      processIDs = {'BDS_M1aC_RM7p5','JMM_M1aC_RM7p5'};
%     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5_fromL2qc'};
%     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5'};
%     processIDs = {'JMM_M2uC_RM7p5','BDS_M1aC_RM7p5'};
%      processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5'};
%      processIDs = {'JMM_M1aC_RM7p5','JMM_M2aC_RM7p5','JMM_M2uC_RM7p5','JMM_M3uC_RM7p5'};

% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
%     processIDs = {'BDS_M1aC_RM1p5','JMM_M1aC_RM1p5'};
%     processIDs = {'BDS_M2uC_RM1p5','JMM_M2uC_RM1p5'};
%     processIDs = {'JMM_M1aC_RM1p5','JMM_M2uC_RM1p5'};

% dataSet = 'Signature5beam_TidalShelf';
%     processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u
%    processIDs = {'JMM_M2uC_RM2','JMM_M2uC_RM4'}; % Compare rmax
%     processIDs = {'JMM_M1aC_RM4','JMM_M2uC_RM4'}; % Compare methods 1a and 2u
%     processIDs = {'JMM_M2uC_RM2','JMM_M2uC_RM2_rmin_3bins'}; % Compare method 2u with different rmin

% dataSet = 'AQD_Windermere_bedframe';
%      processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2'}; % Compare methods 1a and 2u
%      processIDs = {'JMM_M1aC_RM2','JMM_M2aC_RM2'}; % Compare methods 1a and 2a
%      processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u

dataSet = 'NortekSig1000_TidalChannel';
    processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5'}; % Compare methods 1a and 2u


%% Flags
flg.matCompare.show = 0;
flg.saveFigs = 1;
flg.plotEpsTS.show = 1;
flg.plotEpsScatter.show = 1;
flg.plotEpsScatterZ.show = 1;
flg.plotEpsHist.show = 1;
flg.plotEpsRatioHistZ.show = 1;
flg.plotEpsRatioStatsZ.show = 1;
flg.plotA0hist.show = 1;
flg.plotR2hist.show = 0;
flg.plotA1vsA0.show = 0;
flg.plotDLL.show = 1;
flg.plotDelEpshist.show = 0;
flg.plotDelEpsVsR2.show = 0;

%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Figure naming
if length(processIDs) == 2
    figDir=[processIDs{1},'_vs_',processIDs{2}];
    figEnd=[names{1},'_vs_',names{2}];
    flg.twoSets = 1;
else
    figDir = 'Multiple';
    figEnd = 'Multiple';
    flg.twoSets = 0;
end
% figPath=['../figures/',dataSet,'/',figDir,'/'];
figPath = ['/home/jmm000/work/ATOMIX/figures/',dataSet,'/',figDir,'/'];
if ~exist(figPath,'dir') & flg.saveFigs
    disp(['Making ',figPath,'. Press a key to continue.']),pause
    mkdir(figPath)
end


%% Load plotting options
filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

%% ===== Plots ======

%% Time series of EPSI and EPSI_FINAL
if flg.plotEpsTS.show && flg.twoSets
    indZ = plotOptions.plotEpsTS.indZ;
    indB = plotOptions.plotEpsTS.indB;
    t = 1:length(data(1).L4.TIME);
    z = 1:length(data(1).L4.Z_DIST);
    
    for ii = 1:3
        if ii == 1
            eA = squeeze(data(1).L4.EPSI(:,:,indB));
            eB = squeeze(data(2).L4.EPSI(:,:,indB));
            varName = 'EPSI';
        elseif ii == 2
            eA = data(1).L4.EPSI_FINAL;
            eB = data(2).L4.EPSI_FINAL;
            varName = 'EPSI_FINAL';
        elseif ii == 3
            eA = mean(data(1).L4.EPSI(:,:,:),3,'omitnan');
            eB = mean(data(2).L4.EPSI(:,:,:),3,'omitnan');
            varName = 'EPSI_MEAN';
        end
        
        figure_named([varName,'_TS']),clf,clear ax, clear plotData
        set(gcf,'Position',[200,100,700,600])
        axL = 0.10;
        axR = 0.87;
        axH = 0.12;
        axW = axR - axL;
        ax(1) = axes('Position',[axL,0.85,axW,axH]);
        plotData = struct('x',t,'y',z,'values',log10(eA'),'var','EPSI');
        opts = struct('ylabel','z index','clabel','log10(\epsilon_A)','clim',plotOptions.plotEpsTS.clim);
        plot_pcolor(ax(1),plotData,opts);
        if ii == 1
            title([clean_string(varName),'(:,:,',num2str(indB),')'])
        else
            title([clean_string(varName)])
        end
        
        ax(2) =  axes('Position',[axL,0.68,axW,axH]);
        plotData = struct('x',t,'y',z,'values',log10(eB'),'var','EPSI');
        opts = struct('ylabel','z index','clabel','log10(\epsilon_B)','clim',plotOptions.plotEpsTS.clim);
        plot_pcolor(ax(2),plotData,opts);
        
        ax(3) =  axes('Position',[axL,0.51,axW,axH]);
        plotData = struct('x',t,'y',z,'values',log10(eB'./eA'),'var','EPSIratio');
        opts = struct('ylabel','z index','clabel','log10(\epsilon_B/\epsilon_A)','clim',log10([0.5 2]));
        plot_pcolor(ax(3),plotData,opts);
        
        
        ax(4) =  axes('Position',[axL,0.30,axW,axH]);
        semilogy(t,eA(:,indZ),'linewidth',2)
        hold all
        semilogy(t,eB(:,indZ))
        legend('\epsilon_A','\epsilon_B')
        ylabel('\epsilon [W/kg]')
        if ii == 1
            title([clean_string(varName),'(:,',num2str(indZ),',',num2str(indB),')'])
        else
            title([clean_string(varName),'(:,',num2str(indZ),')'])
        end
        
        ax(5) =  axes('Position',[axL,0.15,axW,axH]);
        semilogy(t,eB(:,indZ)./eA(:,indZ),'linewidth',2)
        ylim([0.1 10])
        hold all
        plot(get(gca,'xlim'),[1 1],'k')
        plot(get(gca,'xlim'),[0.5 0.5],'--r')
        plot(get(gca,'xlim'),[2 2],'--r')
        ylabel('\epsilon_B/\epsilon_A')
        
        % linkaxes(ax,'x')
        xlabel(' time index ')
        
        add_fig_info(mname,[dataSet,' ( A = ',names{1},'  B = ',names{2},' )'],struct())
        if flg.saveFigs
            figName = [figPath,varName,'_TimeSeries_',figEnd,'.png'];
            disp(['Saving: ',figName])
            saveas(gcf,figName);
        end
    end
end

%% Scatter plot of all epsilon
if flg.plotEpsScatter.show && flg.twoSets
%     opts = plotOptions.plotEpsScatter;
    
    for ii = 1:2
        if ii == 1
            eA = data(1).L4.EPSI(:);
            eB = data(2).L4.EPSI(:);
            varName = 'EPSI';
        elseif ii == 2
            eA = data(1).L4.EPSI_FINAL(:);
            eB = data(2).L4.EPSI_FINAL(:);
            varName = 'EPSI_FINAL';
        end
        
        figure_named([varName,'_Scatter']),clf,clear ax, clear plotData
        set(gcf,'Position',[100 0 1000 500])
        axW = 0.27;
        axH = axW*2;
        ax(1) = subplot('Position',[0.08 0.2 axW axH]);
        opts = plotOptions.plotEpsScatter;
        opts.type = 'standard';
        plot_EPSI_scatter(ax(1),eA,eB,opts);
        xlabel('\epsilon_A [W/kg]')
        ylabel('\epsilon_B [W/kg]')
        title('scatter plot')
        
        ax(2) = subplot('Position',[0.42 0.2 axW axH]);
        opts = plotOptions.plotEpsScatter;
        opts.type = 'density';
        plot_EPSI_scatter(ax(2),eA,eB,opts);
        xlabel('log_{10}(\epsilon_A [W/kg])')
        ylabel('log_{10}(\epsilon_B [W/kg])')
        title('density plot')
        
        
        ax(3) = subplot('Position',[0.78 0.2 0.2,axH]);
        plotData.var = varName;
        plotData.values = log10(data(2).L4.(varName)./data(1).L4.(varName));
        opts = plotOptions.plotEpsRatioHist;
        opts.xlabelStr = ['log_{10}(\epsilon_B/\epsilon_A)'];
        
        %plotData.label = clean_string(names{ii});
        [ax(3),ph]=plot_histogram(ax(3),plotData,opts);
        legend(ax(3),'hide')
        plot(ax(3),log10(0.5)*[1 1],get(gca,'ylim'),'--r')
        plot(ax(3),log10(2.0)*[1 1],get(gca,'ylim'),'--r')
        title('ratio')
        
        
        
        
        
        add_fig_info(mname,[dataSet,' ( A = ',names{1},',  B = ',names{2},' )'],struct())
        if flg.saveFigs
            figName = [figPath,varName,'_Scatter_',figEnd,'.png'];
            disp(['Saving: ',figName])
            saveas(gcf,figName);
        end
    end
    
end

%% Scatter plots and histograms of epsilon at various depth levels
if flg.plotEpsScatterZ.show && flg.twoSets
    varName = 'EPSI';
    NZ = length(plotOptions.plotEpsScatterZ.indZs);
    
    figure_named([varName,'_ScatterZ']),clf,clear ax, clear plotData
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    for zz = 1:NZ
        opts = plotOptions.plotEpsScatterZ;
        indZ = opts.indZs(zz);
        eA = data(1).L4.EPSI(:,indZ,:);
        eA = eA(:);
        eB = data(2).L4.EPSI(:,indZ,:);
        eB = eB(:);
        
        
        
        ax(1) = subplot(NZ,3,3*zz-2);
        opts = plotOptions.plotEpsScatter;
        opts.type = 'standard';
        plot_EPSI_scatter(ax(1),eA,eB,opts);
        if zz == NZ;
            xlabel('\epsilon_A [W/kg]');
        else
            xlabel('')
        end
        ylabel('\epsilon_B [W/kg]')
        if zz == 1; title('scatter plot'); end
        legend off
        
        ax(2) = subplot(NZ,3,3*zz-1);
        opts = plotOptions.plotEpsScatter;
        opts.type = 'density';
        plot_EPSI_scatter(ax(2),eA,eB,opts);
        if zz == NZ;
            xlabel('log_{10}(\epsilon_A [W/kg])');
        else
            xlabel('')
        end
        ylabel('log_{10}(\epsilon_B [W/kg])')
        if zz == 1; title('density plot'); end
        legend off
        
        
        ax(3) = subplot(NZ,3,3*zz);
        plotData.var = varName;
        plotData.values = log10(eB./eA);
        opts = plotOptions.plotEpsRatioHist;
        opts.xlabelStr = ['log_{10}(\epsilon_B/\epsilon_A)'];
        
        %plotData.label = clean_string(names{ii});
        [ax(3),ph]=plot_histogram(ax(3),plotData,opts);
        legend(ax(3),'hide')
        plot(ax(3),log10(0.5)*[1 1],get(gca,'ylim'),'--r')
        plot(ax(3),log10(2.0)*[1 1],get(gca,'ylim'),'--r')
        if zz == 1; title('ratio'); end
        legend off
        xlim([-0.75 0.75])
        
        pos = get(ax(1),'Position');
        text_rel_figure(0.01,pos(2)+pos(4)/2,...
            {['z = ',num2str(data(1).L1.Z_DIST(indZ)),' m'],
             ['indZ = ',num2str(indZ)]})
    end
    
    add_fig_info(mname,[dataSet,' ( A = ',names{1},',  B = ',names{2},' )'],struct())
    if flg.saveFigs
        figName = [figPath,varName,'_ScatterZ_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot DLL
if flg.plotDLL.show && flg.twoSets
%     try
    opts = plotOptions.plotDLL;
    opts.indT = opts.indTs(1);
    
    data(1).L4.procParams = d(1).metadataGroups.L4;
    data(2).L4.procParams = d(2).metadataGroups.L4;
    
    figure_named('DLL'),clf,clear ax
    set(gcf,'Position',[285,100,1200,600])
    axW = 1/length(processIDs)/2;
    axH = 0.7;
    axY = 0.2;
    
    ax(1) = subplot('Position',[0.10 axY axW axH]);
    opts.dll_averaging = d(1).metadataGroups.L4.dll_averaging;
    opts.rMin = d(1).metadataGroups.L4.rMin;
    opts.rMax = d(1).metadataGroups.L4.rMax;
    opts.points_select_method = d(1).metadataGroups.L4.points_select_method;
    [~,p1] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
    title(ax(1),clean_string(names{1}))
    
    ax(2) = subplot('Position',[0.4 axY axW axH]);
    opts.dll_averaging = d(2).metadataGroups.L4.dll_averaging;
    opts.rMin = d(2).metadataGroups.L4.rMin;
    opts.rMax = d(2).metadataGroups.L4.rMax;
    opts.points_select_method = d(2).metadataGroups.L4.points_select_method;
    [~,p2]= plot_DLL_fit(ax(2),data(2).L3,data(2).L4,opts);
    set(p2(2),'Marker','s','markersize',10,'color',[0.9290 0.6940 0.1250])
    title(ax(2),clean_string(names{2}))
    ax(3) = subplot('Position',[0.7 axY axW axH]);
    [p,pl]=plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,opts);
    set(p(1),'color',get(p1(2),'color'))
    set(pl(1),'color',get(p1(2),'color'))
    set(p(2),'color',get(p2(2),'color'))
    set(pl(2),'color',get(p2(2),'color'))
    title(ax(3),'Comparison')
    
    ylabel(ax(2),'')
    ylabel(ax(3),'')
    linkaxes(ax,'xy')
    
    add_fig_info(mname,[dataSet,...
        ' ( indT = ',num2str(opts.indT),', ',...
        ' indZ = ',num2str(opts.indZ),...
        ',  indB = ',num2str(opts.indB),' )'],struct())
    if flg.saveFigs
        figName = [figPath,'DLLcompare_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
%     catch
%         disp('Cant plot SF')
%     end
end

%% A1 vs A0
if flg.plotA1vsA0.show && flg.twoSets
    figure_named('A1vsA0'),clf, clear ax
    opts = plotOptions.plotA1vsA0;
    for ii = 1:2
        L4data = data(ii).L4;
        L4flags = flags(ii).L4.EPSI_FLAGS;
        
        ax(ii) = subplot('Position',[0.45*(ii-1)+0.1 0.2 0.4 0.7]);
        opts.titleStr = clean_string(names{ii});
        plot_A1_vs_A0(ax(ii),L4data,L4flags,opts);
    end
    linkaxes(ax,'y')
    ylabel(ax(2),'')
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,'A1_vs_A0_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% EPSI histograms
if flg.plotEpsHist.show
    for ii = 1:3
        if ii == 1
            varName = 'EPSI';
        elseif ii == 2
            varName = 'EPSI_FINAL';
        elseif ii == 3
            for dd = 1:length(data)
                eBmp = data(dd).L4.EPSI(:);
                eBmp(data(dd).L4.EPSI_FLAGS>6) = NaN;
                
                data(dd).L4.EPSI_FINAL_MOD = squeeze(nanmean(eBmp,3));
            end
            varName = 'EPSI_FINAL_MOD';
        end
        
        figure_named([varName,'_Hist']), clf, clear ax plotData
        plotData.var = varName ;
        opts = plotOptions.plotEpsHist;
        opts.xlabelStr = ['log_{10}(',clean_string(varName),')'];
        
        opts.displayStyle = 'stairs';
        opts.lineWidth = 1;
        ph = []; lstr = [];
        ax = subplot('Position',[0.12 0.2 0.8,0.7]);
        for dd = 1:length(processIDs)
            plotData(dd).values = log10(data(dd).L4.(varName));
            plotData(dd).label = clean_string(names{dd});
        end
        [ax,ph]=plot_histogram(ax,plotData,opts);
        if ii == 3
            text(opts.xlimits(1)+0.1,0.9*max(get(gca,'ylim')),'EPSI\_FLAGS<=6')
        end
        add_fig_info(mname,[dataSet,' ( A = ',names{1},',  B = ',names{2},' )'],struct())
        if flg.saveFigs
            figName = [figPath,varName,'_hist_',figEnd,'.png'];
            disp(['Saving: ',figName])
            saveas(gcf,figName);
        end
    end
end

%% EPSI histograms (as a function of Z)
if flg.plotEpsRatioHistZ.show && flg.twoSets
    varName = 'EPSI';
    opts = plotOptions.plotEpsRatioHistZ;
    
    
    figure_named([varName,'_Hist']), clf, clear ax plotData
    plotData.var = varName ;
    opts = plotOptions.plotEpsRatioHistZ;
    opts.xlabelStr = ['log_{10}(\epsilon_B/\epsilon_A)'];
    
    opts.displayStyle = 'stairs';
    opts.lineWidth = 1;
    ph = []; lstr = [];
    ax = subplot('Position',[0.12 0.2 0.8,0.7]);
    for zz = 1:length(opts.indZs)
        indZ = opts.indZs(zz);
        eA = data(1).L4.(varName)(:,indZ,:);
        eA = eA(:);
        eB = data(2).L4.(varName)(:,indZ,:);
        eB = eB(:);
        plotData(zz).values = log10(eB./eA);
        plotData(zz).label = ['z = ',num2str(data(1).L4.Z_DIST(indZ)),' m'];
    end
    [ax,ph]=plot_histogram(ax,plotData,opts);
    if ii == 3
        text(opts.xlimits(1)+0.1,0.9*max(get(gca,'ylim')),'EPSI\_FLAGS<=6')
    end
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,varName,'_histZ_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Statisics of the ratio as a function of z

if flg.plotEpsRatioStatsZ.show && flg.twoSets
    opts = plotOptions.plotEpsRatioStatsZ;
    z = 1:length(z);%data(1).L4.Z_DIST;
    NZ = length(z);

    varName = 'EPSI';
    for zz = 1:NZ
        eA = data(1).L4.(varName)(:,zz,:);
        eA = eA(:);
        eB = data(2).L4.(varName)(:,zz,:);
        eB = eB(:);
        ratios = log10(eB./eA);

        indGood = find(~isnan(ratios));
        ratiosMedian(zz) = prctile(ratios,50);
        ratiosUpperP(zz) = prctile(ratios,opts.upperPercentile);
        ratiosLowerP(zz) = prctile(ratios,opts.lowerPercentile);
        ratiosUpperPf(zz) = prctile(ratios,97.5);
        ratiosLowerPf(zz) = prctile(ratios,2.5);

    end

    figure_named('EpsRatioStatistics'),clf, clear ax plotData ph
    set(gcf,'Position',[15 100 750 450])
    pos = get(gca,'Position'); set(gca,'Position',[pos(1) pos(2)+0.05 pos(3:4)])
    ph(1) = plot(ratiosMedian,z,'DisplayName','Median','linewidth',2);
    hold all
    %TODO USE FILL HERE
    %ph(2) = plot(ratiosUpperP,z,'k','DisplayName',[num2str(opts.upperPercentile),' %'])
    %ph(3) = plot(ratiosLowerP,z,'k','DisplayName',[num2str(opts.lowerPercentile),' %'])
    indGood = find(~isnan(ratiosLowerP) & ~isnan(ratiosUpperP));
     ph(2) = fill_between([ratiosLowerP(indGood); ratiosUpperP(indGood)],[z(indGood); z(indGood)],[0 0 0.6]);
    set(ph(2),'DisplayName',[num2str(opts.upperPercentile-opts.lowerPercentile),'% CI'])
    indGood = find(~isnan(ratiosLowerPf) & ~isnan(ratiosUpperPf));
     ph(3) = fill_between([ratiosLowerPf(indGood); ratiosUpperPf(indGood)],[z(indGood); z(indGood)],[0.4 0.4 0.4]);
     set(ph(3),'DisplayName',['95% CI'])
    ph(4) = plot(log10(0.5)*[1 1],get(gca,'ylim'),'--r','DisplayName','factor of 2');
    plot(log10(2.0)*[1 1],get(gca,'ylim'),'--r')
    ph(5) = plot(log10(0.1)*[1 1],get(gca,'ylim'),'--','color',[0.929,0.694,0.125],'DisplayName','factor of 10');
    plot(log10(10)*[1 1],get(gca,'ylim'),'--','color',[0.929,0.694,0.125])
    xlabel('log10(\epsilon_B/\epsilon_A)')
    ylabel('z index')
    legend(ph)

    add_fig_info(mname,[dataSet,' ( A = ',names{1},',  B = ',names{2},' )'],struct())
    if flg.saveFigs
        figName = [figPath,'EPSI_ratio_statistics',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end
%% A0 histograms
if flg.plotA0hist.show
    var = 'REGRESSION_COEFF_A0';
    
    figure_named('A0hist'), clf, clear ax plotData ph
    set(gcf,'Position',[0 0 800,500])
    plotData.var = var ;
    opts.titleStr = clean_string(dataSet);
    opts = plotOptions.plotA0hist;
    opts.displayStyle = 'stairs';
    opts.xlabelStr = 'A0 [m^2 s^{-2}]';
    opts.lineWidth = 1;
    ph = []; lstr = [];
    ax = subplot('Position',[0.12 0.2 0.8,0.7]);
    for ii = 1:length(processIDs)
        plotData(ii).values = data(ii).L4.(var);
        plotData(ii).thresLow = flags(ii).L4.EPSI_FLAGS.dll_intercept_too_low.threshold;
        plotData(ii).thresHigh =  flags(ii).L4.EPSI_FLAGS.dll_intercept_too_high.threshold;
        plotData(ii).label = clean_string(names{ii});
    end
    [ax,ph]=plot_histogram(ax,plotData,opts);
    if ~isfield(opts,'A0expected')
        opts.A0expected = plotData(1).thresHigh/2;
    end
    ph(end+1) = plot(opts.A0expected*[1 1],get(ax,'ylim'),'color',[0 0.6 0],'DisplayName','2\sigma_N^2');
    legend(ph,'location','eastoutside')
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,'A0_hist_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% R2 histograms
if flg.plotR2hist.show
    var = 'REGRESSION_R2';
    
    figure_named('R2hist',1), clear ax, clear plotData
    plotData.var = var;
    opts.titleStr = clean_string(dataSet);
    opts = plotOptions.plotR2hist;
    %opts.displayStyle = 'stairs';
    opts.xlabelStr = clean_string(var);
    ph = []; lstr = {};
    ax = subplot('Position',[0.12 0.2 0.8,0.7]);
    for ii = 1:length(processIDs)
        plotData(ii).values = data(ii).L4.(var);
        plotData(ii).thresLow = flags(ii).L4.EPSI_FLAGS.Rsquared_too_low.threshold;
        plotData(ii).label = clean_string(names{ii});
    end
    [ax,h]=plot_histogram(ax,plotData,opts);
    
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,'R2_hist_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end


%% EPSI_DEL_RATIO histograms
if flg.plotDelEpshist.show
    var = 'EPSI_DEL_RATIO';
    figure_named('DelEspiHist'),clf, clear ax plotData
    
    opts = plotOptions.plotDelEpshist;
    opts.titleStr = clean_string(dataSet);
    opts.xlabelStr = clean_string(var);
    ph = []; lstr = {};
    ax = subplot('Position',[0.12 0.2 0.8,0.7]);
    for ii = 1:length(processIDs)
        plotData(ii).var = var;
        plotData(ii).values = data(ii).L4.(var);
        plotData(ii).thresHigh = flags(ii).L4.EPSI_FLAGS.delta_epsi_too_large.threshold;
        plotData(ii).label = clean_string(names{ii});
    end
    [ax,h] = plot_histogram(ax,plotData,opts);
    
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,'EPSI_DEL_RATIO_hist_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot EPSI_DEL_RATIO vs R2
if flg.plotDelEpsVsR2.show && flg.twoSets
    figure_named('DelEspiVsR2'),clf, clear ax, clear plotData
    for ii = 1:2
        ax(ii) = subplot('Position',[0.1+(ii-1)*0.48 0.22 0.35 0.7]);
        
        L4data = data(ii).L4;
        L4flags = flags(ii).L4.EPSI_FLAGS;
        if ~isfield(L4data,'EPSI_DEL_RATIO')
            L4data.EPSI_DEL_RATIO = L4data.delta_a1_ratio; %TODO: CONFIRM THAT THESE ARE THE SAME THING
        end
        opts.titleStr = clean_string(names{ii});
        plot(L4data.REGRESSION_R2(:),log10(L4data.EPSI_DEL_RATIO(:)),'.')
        xlabel('REGRESSION\_R2')
        ylabel('log_{10}(EPSI\_DEL\_RATIO)')
        title(opts.titleStr)
    end
    linkaxes(ax,'y')
    add_fig_info(mname,dataSet,struct())
    if flg.saveFigs
        figName = [figPath,'EPSI_DEL_RATIO_vs_R2_',figEnd,'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end
