clear
addpath('functions')
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

%% L1 to L4 figures
% -------------------

dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
processIDs = {'JMM_M1aC_RM5'};

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

%% Parameters for L1-L4 figure
indZ = 17;
indEns = 132;
indBeams = [1];
hcol = [0.6350 0.0780 0.1840];
%% L1 figure
figure(1),clf

% setup
t1 = (data(1).L1.TIME - data(1).L1.TIME(1))*24;

% plot
for ii = 1:length(indBeams)
    ax1(ii) = subplot(length(indBeams),1,ii);
    plot(t1,data(1).L1.R_VEL(:,indZ,indBeams(ii)),'color',colors(ii,:))
    hold all
    plot((data(1).L2.TIME(indEns,:)- data(1).L1.TIME(1))*24,squeeze(data(1).L2.R_VEL(indEns,indZ,indBeams(ii),:)),'-','color',hcol,'linewidth',2)
    %fill_transparent((data(1).L2.TIME(indEns,1) - data(1).L1.TIME(1))*24+[0 5/60],[-5 5],0.6*[1 1 1])
    ylabel(['V',num2str(ii),' [m/s]'])
end

% format
linkaxes(ax1,'xy')
xlim([0 24])
ylim(ax1,[-1 1]*1.5)
if length(indBeams) == 4
    for ii = 1:3
        set(ax1(ii),'Xticklabels',[])
    end
end
xlabel('time [hours]')
ylim([-1 1]*0.6)
% save
if figSave
    set(gcf,'PaperPosition',[0 0 6 2.5],'PaperUnits','inches')
    saveas(gcf,[figDir,'L1_1beam.png']);
end


%% L2 figure
figure(2), clf
set(gcf,'Position',[488 499 638 262])

% setup
t2 = (data(1).L2.TIME(indEns,:) - data(1).L2.TIME(indEns,1))*24*60;

% plot
for ii = 1:length(indBeams)
    ax2(ii) = subplot(length(indBeams),1,ii);
    if length(indBeams) == 1
        set(gca,'Position',[0.130 0.190 0.7750 0.7850])
    end
    plot(t2,squeeze(data(1).L2.R_VEL(indEns,indZ,indBeams(ii),:)),'color',0.6*[1 1 1])
    hold all
    plot(t2,squeeze(data(1).L2.R_VEL_DETRENDED(indEns,indZ,indBeams(ii),:)),'color',hcol)
    ylabel(['V',num2str(ii),' [m/s]'])
end

linkaxes(ax2,'xy')
xlim([0 5])
ylim([-1 1]*0.5)
legend('raw','detrended')
if length(indBeams) > 1
for ii = 1:3
    set(ax2(ii),'Xticklabels',[])
end
end
xlabel('time [min]')

if figSave
    set(gcf,'PaperPosition',[0 0 6 2.5],'PaperUnits','inches')
    saveas(gcf,[figDir,'L2_1beam.png']);
end

%% L3 figure
figure(3),clf

% setup 
rfit = [1 3];

% plot
for ii = 1:length(indBeams)
    c = colors(ii,:);
	plot(squeeze(data(1).L4.REGRESSION_R_DEL(indEns,indZ,indBeams(ii),:).^(2/3)),squeeze(data(1).L4.REGRESSION_DLL(indEns,indZ,indBeams(ii),:)),...
        '.','markersize',15,'color',hcol);
    hold all
    p3(ii) = plot(rfit, data(1).L4.REGRESSION_COEFF_A0(indEns,indZ,indBeams(ii))+data(1).L4.REGRESSION_COEFF_A1(indEns,indZ,indBeams(ii))*rfit,...
        'color',hcol,'linewidth',1.2);
end
% ylim([0.005 0.02])
set(gca,'YTick',[0.007 0.01 0.013 0.016])
% format
xlabel('(\delta r)^{2/3} [m^{2/3}]')
ylabel('D_{LL} [m^2/s^2]')
% legend(p3,'beam 1','beam 2','beam 3','beam 4','location','northwest')

% save
if figSave
    set(gcf,'PaperPosition',[0 0 3 2.5],'PaperUnits','inches')
    saveas(gcf,[figDir,'L3_1beam.png']);
end
%% L4 figure
figure(4),clf

% setup
t4 = (data(1).L4.TIME - data(1).L4.TIME(1))*24;

% plot
for ii = 1:length(indBeams)
    semilogy(t4,data(1).L4.EPSI(:,indZ,indBeams(ii)))
    hold all
end
if length(indBeams)>1
    semilogy(t4,data(1).L4.EPSI_FINAL(:,indZ),'k','linewidth',1.2)
end
plot((data(1).L2.TIME(indEns,1) - data(1).L1.TIME(1))*24,data(1).L4.EPSI(indEns,indZ,1),...
    'o','color','k','linewidth',0.5,'markerfacecolor',hcol)

% format
xlim([0 24])
ylim([1e-8 5e-4])
if length(indBeams)>1
legend('beam 1','beam 2','beam 3','beam 4','location','southwest')
end
ylabel('\epsilon [W/kg]')
xlabel('time [hours]')

% save
if figSave
    set(gcf,'PaperPosition',[0 0 6,2.5],'PaperUnits','inches')
    saveas(gcf,[figDir,'L4_1beam.png']);
end

