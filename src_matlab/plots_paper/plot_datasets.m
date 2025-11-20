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

%% Structure functions from different data sets
% -------------------------------------------------
dd = 1;
dataPlotOptions(dd).dataSet = 'AQD_Windermere_bedframe';
dataPlotOptions(dd).dataSetSN = 'Lake Windermere';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM2';
dataPlotOptions(dd).indT = 25;
dataPlotOptions(dd).indZ = 10;
dataPlotOptions(dd).indB = 1;

dd = 2;
dataPlotOptions(dd).dataSet = 'AQD_NorthSea_bedframe';
dataPlotOptions(dd).dataSetSN = 'North Sea';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM0p3';
dataPlotOptions(dd).indT = 20;
dataPlotOptions(dd).indZ = 7;
dataPlotOptions(dd).indB = 1;

dd = 3;
dataPlotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
dataPlotOptions(dd).dataSetSN = 'Celtic Sea Bedframe';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM7p5';
dataPlotOptions(dd).indT = 29;
dataPlotOptions(dd).indZ = 20;
dataPlotOptions(dd).indB = 1;

dd = 4;
dataPlotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_TOP';
dataPlotOptions(dd).dataSetSN = 'Celtic Sea Mooring';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM0p75';
dataPlotOptions(dd).indT = 31;
dataPlotOptions(dd).indZ = 20;
dataPlotOptions(dd).indB = 1;

dd = 5;
dataPlotOptions(dd).dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
dataPlotOptions(dd).dataSetSN = 'Menai Strait';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM3';
dataPlotOptions(dd).indT = 39;
dataPlotOptions(dd).indZ = 10;
dataPlotOptions(dd).indB = 1;

dd = 6;
dataPlotOptions(dd).dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
dataPlotOptions(dd).dataSetSN = 'Grand Passage';
dataPlotOptions(dd).processID = 'JMM_M1aC_RM5';
dataPlotOptions(dd).indT = 150;
dataPlotOptions(dd).indZ = 10;
dataPlotOptions(dd).indB = 1;

%% Load data
dataSets = {dataPlotOptions.dataSet};
dataSetsSN = {dataPlotOptions.dataSetSN};
processIDs = {dataPlotOptions.processID};

for ii = 1:length(dataSets)
    [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSets{ii});
    matFile = [dataDir,dataFileRoot,'_',processIDs{ii},'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Plot different dissipation estimates
figure(11),clf, clear p lStr
set(0,'DefaultFigureWindowStyle','normal')
set(gcf,'Position',[5    49   1200   500])

% setup 
rfit = [0:0.0001:8];

% Theory
epsiT = [1e-11, 1e-10,1e-9, 1e-8,1e-7,1e-6,1e-5,1e-4,1e-3,1e-2];
nu = 1.2e-6;
Lk = (nu.^3./epsiT).^(1/4);
DLLT = zeros(length(epsiT),length(rfit));

cols = colormap('gray');

for ii = 1:length(epsiT)-1
    
    DLLT(ii,:) = 2.0*epsiT(ii)^(2/3)*rfit.^(2/3);
    indC = floor(length(cols)/(length(epsiT)))*ii;
    c = cols(indC,:);
    
    ax(1) = subplot(121);
    plot(rfit.^(2/3),DLLT(ii,:), 'color',c,'linewidth',2)
    hold all
    
    ax(2) = subplot(122);
    p(ii) = loglog(rfit.^(2/3),DLLT(ii,:),'color',c,'linewidth',2);
    hold all
    scatter(rfit.^(2/3),DLLT(ii,:),1,c)
    lstr{ii} = ['\epsilon = ',num2str(epsiT(ii),'%3.1e'),' W/kg'];
    
    % Plot Kolmogorov scales (off the chart)
    indR = get_nearestindex(rfit,Lk(ii));
    scatter(Lk(ii).^(2/3),DLLT(ii,indR),20,'ok')
    
    
    lk = Lk(ii);
    Lk23 = lk^(2/3);
    DLLval = DLLT(ii,indR);
    DLLTLk(ii) = DLLval;
    disp(table(epsiT(ii),indR,lk,Lk23,DLLval))
    
end
plot(Lk(1:end-1).^(2/3),DLLTLk,'--k')
% legend(p,lstr,'location','northwest','AutoUpdate','off')
caxis([min(log10(epsiT)),max(log10(epsiT))])
colormap('gray')
cbar = colorbar;
set(ax(2),'xscale','log','yscale','log')
ylabel(cbar,'log10(\epsilon)')

% plot ata
for ii = 1:length(data)
    indT = dataPlotOptions(ii).indT;
    indZ = dataPlotOptions(ii).indZ;
    indB = dataPlotOptions(ii).indB;

    c = colors(ii,:);
    r = squeeze(data(ii).L4.REGRESSION_R_DEL(indT,indZ,indB,:));
    DLL = squeeze(data(ii).L4.REGRESSION_DLL(indT,indZ,indB,:));
    epsi = squeeze(data(ii).L4.EPSI(indT,indZ,indB));
    A0 = data(ii).L4.REGRESSION_COEFF_A0(indT,indZ,indB);
    A1 = data(ii).L4.REGRESSION_COEFF_A1(indT,indZ,indB);
   % rfit =[min(r) max(r)];
    
    plot(ax(1),r.^(2/3),DLL-A0,'.','markersize',15,'color',c);
    hold all
    p11(ii) = plot(ax(1),rfit.^(2/3),A1*rfit.^(2/3),'color',c,'linewidth',1.2);
    lstr{ii} = ['\epsilon = ',num2str(epsi,'%3.1e'),' W kg^{-1} [',dataSetsSN{ii},']'];
    
	loglog(ax(2),r.^(2/3),DLL-A0,'.','markersize',15,'color',c);
    hold all
    loglog(ax(2),rfit.^(2/3),A1*rfit.^(2/3),'color',c,'linewidth',1.2);
end

% format


% legend(ax(1),p11,lstr,'location','best','AutoUpdate','off')
ylim(ax(1), [-0.005,0.025])
for ii = 1:2
    xlabel(ax(ii),'(\delta r)^{2/3} [m^{2/3}]')
    ylabel(ax(ii),'D_{LL} - A_0 [m^2/s^2]')
end
xlim(ax(1),[0 4])
xlim(ax(2),[1e-2 4])
ylim(ax(2),[1e-8 1e-1])

set(ax(1),'Position',[0.08 0.12 0.38 0.8])
get(ax(2),'Position')
set(ax(2),'Position',[0.54 0.12 0.38 0.8]) % Doesn't seem to work
% save
if figSave
    disp('Saving')
   
    set(gcf,'PaperPosition',[0 0 12 5],'PaperUnits','inches')
    saveas(gcf,[figDir,'Dll_range.png']);
end


%%
figure(12),clf
semilogx(epsiT,Lk,'-o')
ylabel('Lk [m]')
xlabel('\epsilon_T [W/kg]')