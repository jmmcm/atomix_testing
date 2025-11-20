clear all
addpath('/home/jmm000/code/utilities/subaxis/')
mname = mfilename('fullpath');

%% 



%%
nn = 5;
dataSets = {'RDI4beam_TidalChannel_GP130620BPb',...
            'AQD_NorthSea_bedframe',...
            'AQD_Windermere_bedframe',...
            'RDIWH600_CANDYFLOSS_TOP',...
            'RDIWH600_CANDYFLOSS_bedframe',...
            'NortekSig1000_TidalChannel_2019_Burst'};

dataSet = dataSets{nn};
switch dataSet
    case 'RDI4beam_TidalChannel_GP130620BPb'
        processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5','JMM_M2aC_RM5'};
        indZ = 20;
        indB = 1;
        indTall = [101 110 144];
        limEpsi = [1e-8 3e-4];
    case 'AQD_NorthSea_bedframe'
        processIDs = {'JMM_M1aC_RM0p3','JMM_M2uC_RM0p3','JMM_M2aC_RM0p3'};
        indZ = 19;
        indB = 1;
        indTall = [50 74 110];
        limEpsi = [1e-9 1e-5];
    case 'AQD_Windermere_bedframe' % TODO DIfferent sigmaN for flagging?
        processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2','JMM_M2aC_RM2'};
        indZ = 20;
        indB = 1;
        indTall = [25 63 152];
        limEpsi = [1e-13 1e-8];
    case 'RDIWH600_CANDYFLOSS_TOP'
        processIDs = {'JMM_M1aC_RM0p75','JMM_M2uC_RM0p75','JMM_M2aC_RM0p75'};
        indZ = 20;
        indB = 1;
        indTall = [56 223 278 497];
        limEpsi = [1e-10 2e-5];
    case 'RDIWH600_CANDYFLOSS_bedframe'
        processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5','JMM_M2aC_RM7p5'};
        indZ = 20;
        indB = 1;
        indTall = [56 162 223 278];
        limEpsi = [1e-10 1e-5];
        t1 = 735969;
    case 'NortekSig1000_TidalChannel_2019_Burst'
        processIDs = {'JMM_M1aC_RM3','JMM_M2uC_RM3','JMM_M2aC_RM3'};
        indZ = 15;
        indB = 1;
        indTall = [44 110 140 184];
        limEpsi = [1e-9 1e-3];
end

markers = {'o','.','s'};
colors = {'r','b',[0 0.6 0]};
labels = {'Cen','All','AllAvg'};
%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
metaDir = ['../' metaDir];

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

%%
figure(1),clf,clear ax
set(gcf,'Name','Epsilon')
ax(1) = subaxis(4,1,1);
ax(2) = subaxis(4,1,2);
ax(3) = subaxis(4,1,3);
ax(4) = subaxis(4,1,4);

for dd = 1:3
    t = data(dd).L4.TIME - t1;
    z = data(dd).L4.Z_DIST;
    plotData = struct('x',t,'y',z,'values',log10(data(dd).L4.EPSI(:,:,indB))','var','EPSI');
    opts = struct('ylabel','z index','clabel',['log10(\epsilon_{' labels{dd} '})'],'clim',[-8 -5]);
    plot_pcolor(ax(dd),plotData,opts);
    hold(ax(dd),'on')
    plot(ax(dd),get(ax(dd),'xlim'),z(indZ)*[1 1],'k')
    ylabel(ax(dd),'z [m]')
    
    plot(ax(4),t,data(dd).L4.EPSI(:,indZ,indB),'DisplayName',labels{dd})
    hold(ax(4),'on')
end

set(ax(4),'yscale','log')
ylim(ax(4),limEpsi)
ylabel(ax(4),'\epsilon [W/kg]')
xlabel(ax(4), 't index')

legend(ax(4),'location','southeast')

linkaxes(ax,'x')
xlim(ax(1),[0 2])

title(ax(1),clean_string(dataSet))