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

%% Plot comparing different regression methods
dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5','JMM_M3uC_RM5'};
markers = {'o','s','^'};
labels = {'Centered','All','Anchored'};
for ii = 1:length(processIDs)
    [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
    matFile = [dataDir,dataFileRoot,'_',processIDs{ii},'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];


    % override L4 for smaller range
    d(ii).metadataGroups.L4.rMax = 3.2; % 6 range bins
    d(ii).metadataGroups.L4.Const = d(ii).metadataGroups.L4.C2;
    d(ii).metadataGroups.L4.order = 2;
    d(ii).metadataGroups.L4.figure = 0;
    d(ii).metadataGroups.L4.flagFile = ['../' d(ii).fileInfo.flagFile];
    data(ii).L4 = calc_level4_ATOMIX(data(ii).L3,d(ii).metadataGroups.L4);
end
%%
indT = 50;
indZ = 17;
indB = 1;

fig = figure(20);clf
set(gcf,'Position',[500 400 800 400])
axPos = [0.13 0.14 0.775 0.7];
ax1 = axes(fig,'position',axPos,'color','none');

for ii = 1:3%:length(processIDs)
    rDel = squeeze(data(ii).L4.REGRESSION_R_DEL(indT,indZ,indB,:));
    DLL = squeeze(data(ii).L4.REGRESSION_DLL(indT,indZ,indB,:));
    A0 = squeeze(data(ii).L4.REGRESSION_COEFF_A0(indT,indZ,indB));
    A1 = squeeze(data(ii).L4.REGRESSION_COEFF_A1(indT,indZ,indB));
    epsi = squeeze(data(ii).L4.EPSI(indT,indZ,indB));
    rFit = [0 4.5];
    

    p2(ii) = plot(rDel.^(2/3),DLL,'LineStyle','none','Marker',markers{ii},'MarkerSize',7);
    set(p2(ii),'LineStyle','none','Marker',markers{ii},...
        'color',colors(ii,:),'MarkerFaceColor','none','linewidth',2)
    l{ii} = ['\epsilon = ',num2str(epsi,'%3.1e'),' W/kg (',labels{ii},')'];
    if ii == 1
        hold all
    end
    p3(ii) = plot(rFit.^(2/3), A0+A1*rFit.^(2/3),'Color',get(p2(ii),'Color'),'linewidth',2);
    
    if ii == 1
        set(p2(ii),'MarkerFaceColor',colors(ii,:))
    end
    
    uistack(p3(ii),'bottom')
end


xlimits = [0 2.5];
ylimits = get(gca,'ylim');
ylimits = [2e-3 10e-3]; %For presentation
set(ax1,'xlim',xlimits)
set(ax1,'ylim',ylimits)
set(ax1,'XTick',(0.5/cosd(20)*[1 2 3 4 5 6]).^(2/3))
set(ax1,'XTickLabels',{'1','2','3','4','5','6'})
xlabel(ax1,'\delta')
ylabel(ax1,'D_{LL} [m^2 s^{-2}]')

ax2 = axes(fig,'position',axPos,'color','none');
set(ax2,'xlim',xlimits)
set(ax2,'ylim',ylimits)
set(ax2,'XAxisLocation','top')
% set(ax2,'XTick',(0.5/cosd(20)*[1 2 3 4 5 6]).^(2/3))
xlabel(ax2,'(\delta r)^{2/3} [m^{2/3}]')
set(ax2,'XColor',0.4*[0 1 0])
set(ax2,'YTick',[])



legend(p2,l,'location','southeast')


% save
if figSave
    disp('Saving')
   
    set(gcf,'PaperPosition',[0 0 6 3],'PaperUnits','inches')
    saveas(gcf,[figDir,'RegressMethods3.png']); % Changes for presentation
end