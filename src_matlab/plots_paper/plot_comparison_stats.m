clear
addpath('../functions')
addpath('../../../adcp_toolbox/matlab/')
addpath('../../../utilitieswork')
addpath('../../../netcdftools_ceb/variables_flags_databases/YAMLMatlab_0/')
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

colors = get(0,'defaultaxescolororder');
%%
figDir = '/home/jmm000/work/ATOMIX/figures/paper/';
figSave = 1;

%%
dd = 1;
dataPlotOptions(dd).dataSet = 'AQD_Windermere_bedframe';
dataPlotOptions(dd).dataSetSN = 'Lake Windermere';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM2';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM2';

dd = 2;
dataPlotOptions(dd).dataSet = 'AQD_NorthSea_bedframe';
dataPlotOptions(dd).dataSetSN = 'North Sea';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM0p3';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM0p3';


dd = 3;
dataPlotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
dataPlotOptions(dd).dataSetSN = 'Celtic Sea Bedframe';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM7p5';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM7p5';

dd = 4;
dataPlotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_TOP';
dataPlotOptions(dd).dataSetSN = 'Celtic Sea Mooring';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM0p75';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM0p75';

dd = 5;
dataPlotOptions(dd).dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
dataPlotOptions(dd).dataSetSN = 'Menai Strait';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM5';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM5';

dd = 6;
dataPlotOptions(dd).dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
dataPlotOptions(dd).dataSetSN = 'Grand Passage';
dataPlotOptions(dd).processIDcen = 'JMM_M1aC_RM5';
dataPlotOptions(dd).processIDall = 'JMM_M2uC_RM5';


%% Load data
dataSets = {dataPlotOptions.dataSet};
dataSetsSN = {dataPlotOptions.dataSetSN};
processIDcen = {dataPlotOptions.processIDcen};
processIDall = {dataPlotOptions.processIDall};

for ii = 1:length(dataSets)
    ii
    [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSets{ii});
    
    matFile = [dataDir,dataFileRoot,'_',processIDcen{ii},'.mat'];
    dCen(ii) = load(matFile);
    dataCen(ii) = dCen(ii).data;
    
    matFile = [dataDir,dataFileRoot,'_',processIDall{ii},'.mat'];
    dAll(ii) = load(matFile);
    dataAll(ii) = dAll(ii).data;

end

%% Plot

figure(30),clf
set(gcf,'Position',[10 10 800 1200])
for ii = 1:length(dataSets)
    eCen = dataCen(ii).L4.EPSI(:);
    eAll = dataAll(ii).L4.EPSI(:);
    varName = 'EPSI';
    
    axNum = 3*ii-2;        
    ax(axNum) = subplot(6,3,axNum);
    optsScatter.type = 'density';
    optsScatter.legend = 0;
    optsScatter.limits = [1e-10 1e-3];
    [ax(axNum),ph] = plot_EPSI_scatter(ax(axNum),eCen,eAll,optsScatter);
    xlabel(ax(axNum),'')
    set(ph(2:5),'linewidth',1)
    box on
        ylabel(ax(axNum),dataPlotOptions(ii).dataSetSN)


    
    
    axNum = 3*ii-1;
    ax(axNum) = subplot(6,3,axNum);
    plotData.values = log10(eAll./eCen);
    plotData.var = 'EPSI';
    optsHist = struct();
    optsHist.nbins = 100
    optsHist.xlimits = [-1,1];  
    optsHist.binLimits = [-1,1];  
    optsHist.xlabelStr = ['log_{10}(\epsilon_{All}/\epsilon_{Cen})'];
    
    [ax(axNum),ph]=plot_histogram(ax(axNum),plotData,optsHist);
    legend(ax(axNum),'hide')
    plot(ax(axNum),log10(0.5)*[1 1],get(gca,'ylim'),'--r')
    plot(ax(axNum),log10(2.0)*[1 1],get(gca,'ylim'),'--r')
    xlabel(ax(axNum),'')
    
    % Statistics as a function of z
    axNum = 3*ii;
    ax(axNum) = subplot(6,3,3*ii);
    opts.lowerPercentile= 2.5;
    opts.upperPercentile= 97.5;
    z = dataCen(ii).L4.Z_DIST';
    
    ratiosMedian = 0*z;
    ratiosUpperP = 0*z;
    ratiosLowerP = 0*z;
    for zz = 1:length(z)
        
        eCen = dataCen(ii).L4.EPSI(:,zz,:);
        eAll = dataAll(ii).L4.EPSI(:,zz,:);
        eCen = eCen(:);
        eAll = eAll(:);
        ratios = log10(eAll./eCen);

        indGood = find(~isnan(ratios));
        ratiosMedian(zz) = prctile(ratios,50);
        ratiosUpperP(zz) = prctile(ratios,opts.upperPercentile);
        ratiosLowerP(zz) = prctile(ratios,opts.lowerPercentile);

    end
    ph(1) = plot(ratiosMedian,z,'DisplayName','Median','linewidth',2);
    hold all
    indGood = find(~isnan(ratiosLowerP) & ~isnan(ratiosUpperP));
     ph(2) = fill_between([ratiosLowerP(indGood); ratiosUpperP(indGood)],[z(indGood); z(indGood)],[0 0 0.6]);
    set(ph(2),'DisplayName',[num2str(opts.upperPercentile-opts.lowerPercentile),'% CI'])

    ph(3) = plot(log10(0.5)*[1 1],get(gca,'ylim'),'--r','DisplayName','factor of 2');
    plot(log10(2.0)*[1 1],get(gca,'ylim'),'--r')
    ph(4) = plot(log10(0.1)*[1 1],get(gca,'ylim'),'--','color',[0.929,0.694,0.125],'DisplayName','factor of 10');
    plot(log10(10)*[1 1],get(gca,'ylim'),'--','color',[0.929,0.694,0.125])
    ylabel('z [m]')
    xlim([-2 2])
   % legend(ph)
    
end
xlabel(ax(16),'\epsilon_{Cen} [W/kg]')
xlabel(ax(17),'\epsilon_{All}/\epsilon_{Cen}')
xlabel(ax(18),'\epsilon_{All}/\epsilon_{Cen}')