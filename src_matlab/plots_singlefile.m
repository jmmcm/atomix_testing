%% Create simple plots of the data
% Plots are of a single data file and hence this script isn't used for
% comparing two files.
%
% Justine McMillan

% TODO:
% - epsilon vs speed
% - epsilon vs depth



clear all
mname = mfilename('fullpath');
%close all
colors = get(0,'defaultaxescolororder');

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'JMM_M2uC_RM5';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'JMM_M1aC_RM7p5';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'JMM_M2uC_RM1p5';
% dataSet = 'Signature5beam_TidalShelf';
dataSet = 'AQD_Windermere_bedframe'; processID = 'JMM_M2uC_RM2';
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; processID = 'JMM_M1aC_RM5';


%% Flags
flg.saveFigs = 1; % Not supported yet for all figures
flg.plotVelTS.show = 0;
flg.plotVelAvgTS.show = 1;
flg.plotVelENUTS.show = 1;
flg.plotEpsTS.show = 1;
flg.plotDLL.show = 0;
flg.plotAmp.show = 0;

figPath=['/home/jmm000/work/ATOMIX/figures/',dataSet,'/',processID,'/'];

%% Load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
matFile =  [dataDir,dataFileRoot,'_',processID,'.mat'];
load(matFile);
L1 = data.L1;
L2 = data.L2;
L3 = data.L3;
L4 = data.L4;
try
    Anc = data.Ancillary;
end

specFile = [dataDir,dataFileRoot,'_spectra','.mat'];


%% Load plotting options
filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

%% Useful variables
dateVec0 = datevec(L1.TIME(1));
yearStr = num2str(dateVec0(1));
[NT,NZ,NB] = size(L1.R_VEL);

%% Plot velocities (SLOW)
if flg.plotVelTS.show
    figure_named(['BeamVel_TS']),clf,clear ax, clear plotData
    set(gcf,'Position',[200,100,700,600])
    axL = 0.10;
    axR = 0.87;
    axH = 0.14;
    axW = axR - axL;
    if NB == 4
        axB = [0.8:-.22:0];
    elseif NB == 5
        axB = [0.83:-0.19:0];
    end
    
    opts = plotOptions.plotVelTS;
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(L1.TIME);
    plotData.y = L1.Z_DIST;
    plotData.var = 'R_VEL';
    for bb = 1:NB
        ax(bb) = axes('Position',[axL,axB(bb),axW,axH]);
        plotData.values = L1.R_VEL(:,:,bb);
        opts.clabel= ['R\_VEL(:,:,',num2str(bb),') [m/s]'];
        plot_pcolor(ax(bb),plotData,opts);
        hold all
        try
            plot(plotData.x,L1.PRES,'w')
        end
    end
    xlabel(ax(NB),['year day ',yearStr])
    title(ax(1),['Beam Velocities'])
end

%% Plot averaged velocities 
if flg.plotVelAvgTS.show
    figure_named(['BeamVelAvg_TS']),clf,clear ax, clear plotData
    set(gcf,'Position',[200,100,700,600])
    axL = 0.10;
    axR = 0.87;
    
    axW = axR - axL;
    if NB == 3
        axH = 0.22;
        axB = [0.7:-0.27:0];
    elseif NB == 4
        axH = 0.14;
        axB = [0.8:-.22:0];
    elseif NB == 5
        axH = 0.14;
        axB = [0.83:-0.19:0];
    end
    
    R_VEL_AVG = nanmean(L2.R_VEL,4);
    
    opts = plotOptions.plotVelTS;
    opts.ylabel = 'z [m]';
    plotData.x = 1:length(L3.TIME);
    plotData.y = 1:length(L2.Z_DIST);
    plotData.var = 'R_VEL';
    for bb = 1:NB
        ax(bb) = axes('Position',[axL,axB(bb),axW,axH]);
        plotData.values = R_VEL_AVG(:,:,bb);
        opts.clabel= ['R\_VEL(:,:,',num2str(bb),') [m/s]'];
        plot_pcolor(ax(bb),plotData,opts);
        hold all
        try
            plot(plotData.x,L1.PRES,'w')
        end
        ylabel('ind_Z')
    end
    xlabel(ax(NB),['ind_T'])
    title(ax(1),['Beam Velocities'])
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'VelBeamAvg.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot ENU velocities
if flg.plotVelENUTS.show
    figure_named(['ENUVel_TS']),clf,clear ax, clear plotData
    NP = 4;
    
    opts = plotOptions.plotVelENUTS;
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(Anc.TIME);
    plotData.y = Anc.Z_DIST;
    plotData.var = 'ENU';
    for bb = 1:3
        ax(bb) = subplot(NP,1,bb);
        plotData.values = Anc.ENU(:,:,bb)';
        switch bb
            case 1; opts.clabel= ['E [m/s]'];
            case 2; opts.clabel= ['N [m/s]'];
            case 3; opts.clabel= ['U [m/s]'];
        end
        plot_pcolor(ax(bb),plotData,opts);
        hold all
        try
            plot(plotData.x,L1.PRES,'k')
        end
    end
    ax(4) = subplot(NP,1,4);
    plotData.var = 'SPD';
%     plotData.values = abs(Anc.SIGNED_SPEED');
    plotData.values = sqrt(Anc.ENU(:,:,1).^2+Anc.ENU(:,:,2).^2);
    opts.clim = [0 max(plotData.values(:))];
    opts.clabel = 'SPEED [m/s]'
    plot_pcolor(ax(4),plotData,opts);
    xlabel(ax(NP),['year day ',yearStr])
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'VelENU.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot dissipation
if flg.plotEpsTS.show
    
    figure_named(['EPSI_TS']),clf
    clear ax plotData opts
    set(gcf,'Position',[200,100,700,600])
    axL = 0.10;
    axR = 0.87;
    axW = axR - axL;
    if NB == 3
        axH = 0.22;
        axB = [0.7:-0.27:0];
    elseif NB == 4
        axH = 0.14;
        axB = [0.8:-.22:0];
    elseif NB == 5
        axH = 0.14;
        axB = [0.83:-0.19:0];
    end
    
    opts = plotOptions.plotEpsTS;opts.clim
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(L4.TIME);
    plotData.y = L4.Z_DIST;
    plotData.var = 'EPSI';
    for bb = 1:NB
        ax(bb) = axes('Position',[axL,axB(bb),axW,axH]);
        plotData.values = log10(L4.EPSI(:,:,bb));
        opts.clabel= ['log10(\epsilon_',num2str(bb),' [W/kg])'];
        plot_pcolor(ax(bb),plotData,opts);
        hold all
        plot(get(gca,'xlim'),[1 1]*L4.Z_DIST(floor(opts.indZ/2)),'--w')
        plot(get(gca,'xlim'),[1 1]*L4.Z_DIST(opts.indZ),'--w')
    end
    xlabel(ax(NB),['year day ',yearStr])
    title(ax(1),['\epsilon (beams)'])
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'epsilon.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
    figure_named(['EPSI_TS_bins']),clf, clear ax
    ax(1) = subplot(311);
    if ~isfield(Anc,'SPD') || ~isfield(Anc,'SIGNED_SPEED')
        Anc.SPD = sqrt(Anc.ENU(:,:,1).^2+ Anc.ENU(:,:,2).^2);
    end
    try
        pcolor(plotData.x,plotData.y,Anc.SPD'); shading flat; colorbar
        colormap(cmocean('speed'))
    catch
        pcolor(plotData.x,plotData.y,Anc.SIGNED_SPEED'); shading flat; colorbar
        colormap(cmocean('balance'))
    end
    
    title('speed')
    ax(2) = subplot(312);
    indZ = floor(opts.indZ/2);
    for bb = 1:NB
        semilogy(plotData.x,L4.EPSI(:,indZ,bb),'DisplayName',['beam ',num2str(bb)])
        if bb == 1; hold all; end
    end
    title(['z = ' num2str(L4.Z_DIST(indZ)) ' m'])
    ylim(10.^opts.clim)
    colorbar
    ylabel('\epsilon [W/kg]')
    ax(3) = subplot(313);
    indZ = opts.indZ;
    for bb = 1:NB
        semilogy(plotData.x,L4.EPSI(:,indZ,bb),'DisplayName',['beam ',num2str(bb)])
        if bb == 1; hold all; end
    end
    title(['z = ' num2str(L4.Z_DIST(indZ)) ' m'])
    legend
    colorbar
    xlabel('year day')
    ylabel('\epsilon [W/kg]')
    ylim(10.^opts.clim)
    linkaxes(ax,'x')
    xlim([min(plotData.x) max(plotData.x)])
    
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'epsilon_selectBins.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
    figure_named(['EPSI_TS_onebeam']),clf
    clear ax plotData opts
    
    opts = plotOptions.plotEpsTS;
    ax(1) = subplot(211);
    opts.clim = [-1 1]*0.5;
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(L1.TIME);
    plotData.y = L1.Z_DIST;
    plotData.var = 'R_VEL';
    nanMask = ones(size(L1.R_VEL));
    nanMask(find(L1.R_VEL_FLAGS>0)) = NaN;
    plotData.values = L1.R_VEL(:,:,opts.indB).*nanMask(:,:,opts.indB);
    opts.clabel= ['R\_VEL(:,:,',num2str(opts.indB),') [m/s])'];
    plot_pcolor(ax(1),plotData,opts);
    
    ax(2) = subplot(212);
    opts.clim = plotOptions.plotEpsTS.clim;
    plotData.x = get_yd(L4.TIME);
    plotData.y = L4.Z_DIST;
    plotData.var = 'EPSI';
    plotData.values = log10(L4.EPSI(:,:,opts.indB));
    opts.clabel= ['log10(\epsilon_',num2str(opts.indB),' [W/kg])'];
    plot_pcolor(ax(2),plotData,opts);
    linkaxes(ax,'xy')
    xlabel(ax(2),['year day ',yearStr])
    add_fig_info(mname,[dataSet ' (Method: ' processID ')'],struct())
    if flg.saveFigs
        figName = [figPath,'epsilon_beam',num2str(opts.indB) '.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot DLL for several time indices

if flg.plotDLL.show
    
    
    figure_named(['DLL']),clf
    clear ax plotData opts
    set(gcf,'Position',[0 50 1800 600])
    
    opts = struct('clim',[0 1]);
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(Anc.TIME);
    plotData.y = Anc.Z_DIST;
    plotData.values = Anc.SPD;
    plotData.var = 'SPD';
    ax0 = subplot(311);
    plot_pcolor(ax0,plotData,opts)
    
%     opts = plotOptions.plotDLL;
    %     plot_epsi(ax1,L4,opts)

    opts = plotOptions.plotEpsTS;
    opts.ylabel = 'z [m]';
    plotData.x = get_yd(L4.TIME);
    plotData.y = L4.Z_DIST;
    plotData.var = 'EPSI';
    plotData.values = log10(L4.EPSI(:,:,plotOptions.plotDLL.indB));
    
    ax1 = subplot(312);
    plot_pcolor(ax1,plotData,opts)
    hold all
%     legend(ax1,'autoupdate','off')
    
    opts = plotOptions.plotDLL;
    for tt = 1:length(opts.indTs)
        opts.indT = opts.indTs(tt);
        opts.dll_averaging = metadataGroups.L4.dll_averaging;
        opts.rMin = metadataGroups.L4.rMin;
        opts.rMax = metadataGroups.L4.rMax;
        opts.points_select_method = metadataGroups.L4.points_select_method;
        axh = subplot(3,length(opts.indTs),length(opts.indTs)+4+tt);
        
        [axh,p] = plot_DLL_fit(axh,L3,L4,opts);
        set(p(2),'color',colors(tt+2,:))
        title(axh,[axh.Title.String,', indT = ',num2str(opts.indT)])
        
        p1(tt) = plot(ax1,get_yd(get_yd(L4.TIME(opts.indT)))*[1 1],get(ax1,'ylim'),'-',...
            'color',get(p(2),'color'),'linewidth',2,...
            'DisplayName',['indT = ',num2str(opts.indT)]);
        plot(ax1,get(ax1,'xlim'),L4.Z_DIST(opts.indZ*[1 1]),'w')
        
        
    end
    legend(ax1,p1)
    
    
end

