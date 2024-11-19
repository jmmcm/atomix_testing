%% Create simple plots of the data
% Plots are of a single data file and hence this script isn't used for
% comparing two files.
%
% Justine McMillan

% TODO:
% - epsilon vs speed
% - epsilon vs depth



clear all
%close all
colors = get(0,'defaultaxescolororder');

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'JMM_M2uC_RM5';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
% dataSet = 'Signature5beam_TidalShelf';
% dataSet = 'AQD_Windermere_bedframe'; processID = 'JMM_M2uC_RM2';
dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; processID = 'JMM_M1aC_RM5';


%% Flags
flg.saveFigs = 0; % Not supported yet
flg.plotVelTS.show = 0;
flg.plotEpsTS.show = 0;
flg.plotDLL.show = 0;
flg.plotAmp.show = 0;


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

%% Plot dissipation
if flg.plotEpsTS.show
    
    figure_named(['EPSI_TS']),clf
    clear ax plotData opts
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
    
    opts = plotOptions.plotEpsTS;
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
    end
    xlabel(ax(NB),['year day ',yearStr])
    title(ax(1),['\epsilon (beams)'])
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

