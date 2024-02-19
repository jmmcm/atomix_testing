clear
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

colors = get(0,'defaultaxescolororder');
%%
figDir = '../figures/paper/';
figSave = 1;

%% L1 to L4 figures
% -------------------

dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
processIDs = {'JMM_M2uC_RM5'};

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

%% L1 figure
figure(1),clf

% setup
t1 = (data(1).L1.TIME - data(1).L1.TIME(1))*24;

% plot
for ii = 1:length(indBeams)
    ax1(ii) = subplot(length(indBeams),1,ii);
    plot(t1,data(1).L1.R_VEL(:,indZ,indBeams(ii)),'color',colors(ii,:))
    hold all
    fill_transparent((data(1).L2.TIME(indEns,1) - data(1).L1.TIME(1))*24+[0 5/60],[-5 5],0.6*[1 1 1])
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
    plot(t2,squeeze(data(1).L2.R_VEL_DETRENDED(indEns,indZ,indBeams(ii),:)),'color',colors(ii,:))
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
        '.','markersize',15,'color',c);
    hold all
    p3(ii) = plot(rfit, data(1).L4.REGRESSION_COEFF_A0(indEns,indZ,indBeams(ii))+data(1).L4.REGRESSION_COEFF_A1(indEns,indZ,indBeams(ii))*rfit,...
        'color',c,'linewidth',1.2);
end

% format
xlabel('r^{2/3} [m^{2/3}]')
ylabel('D_{LL} [m^2/s^2]')
legend(p3,'beam 1','beam 2','beam 3','beam 4','location','northwest')

% save
if figSave
    set(gcf,'PaperPosition',[0 0 6 2.5],'PaperUnits','inches')
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
fill_transparent((data(1).L2.TIME(indEns,1) - data(1).L1.TIME(1))*24+[0 5/60],[1e-12 1e-3],0.6*[1 1 1])

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

%% Structure functions from different data sets
% -------------------------------------------------
clear data flags names
dataSets = {'RDIWH600_CANDYFLOSS_bedframe','RDI4beam_TidalChannel_GP130620BPb','RDI4beam_TidalChannel_GP130620BPb'};
dataSetsSN = {'Candyfloss Bedframe','Tidal Channel (Slack)','Tidal Channel (Max Flow)'};
processIDs = {'JMM_M2uC_RM7p5','JMM_M2uC_RM5','JMM_M2uC_RM5'};

for ii = 1:length(dataSets)
    [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSets{ii});
    matFile = [dataDir,dataFileRoot,'_',processIDs{ii},'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Plot different dissipation estimates
figure(11),clf

% setup 
rfit = linspace(0,8,10);
indB = 1;
indEnsS = [26, 100, 150]; % [Low, Medium, High]
indZ = 10;

% Theory
epsiT = [1e-9, 1e-8,1e-7,1e-6,1e-5,1e-4,1e-3,1e-2];
nu = 1e-6;
Lk = (nu.^3./epsiT).^(1/4);
DLLT = zeros(length(epsiT),length(rfit));

cols = colormap('gray');

for ii = 1:length(epsiT)-1
    DLLT(ii,:) = 2.0*epsiT(ii)^(2/3)*rfit.^(2/3);
    indC = floor(length(cols)/(length(epsiT)))*ii
    c = cols(indC,:);
    
    ax(1) = subplot(121);
    plot(rfit.^(2/3),DLLT(ii,:), 'color',c,'linewidth',2)
    hold all
    
    ax(2) = subplot(122);
    loglog(rfit.^(2/3),DLLT(ii,:),'color',c,'linewidth',2)
    hold all
    scatter(rfit.^(2/3),DLLT(ii,:),10,c)
    
end
caxis([min(log10(epsiT)),max(log10(epsiT))])
colormap('gray')
cbar = colorbar;
set(ax(2),'xscale','log','yscale','log')
ylabel(cbar,'log10(\epsilon)')

% plot
for ii = 1:length(data)
    indEns = indEnsS(ii);
    c = colors(ii,:);
    r = squeeze(data(ii).L4.REGRESSION_R_DEL(indEns,indZ,indB,:));
    DLL = squeeze(data(ii).L4.REGRESSION_DLL(indEns,indZ,indB,:));
    epsi = squeeze(data(ii).L4.EPSI(indEns,indZ,indB));
    A0 = data(ii).L4.REGRESSION_COEFF_A0(indEns,indZ,indB);
    A1 = data(ii).L4.REGRESSION_COEFF_A1(indEns,indZ,indB);
   % rfit =[min(r) max(r)];
    
   subplot(121)
	plot(r.^(2/3),DLL-A0,'.','markersize',15,'color',c);
    hold all
    p11(ii) = plot(rfit.^(2/3),A1*rfit.^(2/3),'color',c,'linewidth',1.2);
    lstr{ii} = ['\epsilon = ',num2str(epsi,'%3.1e'),' W kg^{-1} [',dataSetsSN{ii},']'];
    
    subplot(122)
	loglog(r.^(2/3),DLL-A0,'.','markersize',15,'color',c);
    hold all
    p11(ii) = loglog(rfit.^(2/3),A1*rfit.^(2/3),'color',c,'linewidth',1.2);
    lstr{ii} = ['\epsilon = ',num2str(epsi,'%3.1e'),' W kg^{-1} [',dataSetsSN{ii},']'];
end

% format
legend(ax(1),p11,lstr,'location','best')
ylim(ax(1), [-0.005,0.025])
for ii = 1:2
    xlabel(ax(ii),'r^{2/3} [m^{2/3}]')
    ylabel(ax(ii),'D_{LL} - A_0 [m^2/s^2]')
    xlim([0 4])
end

% save
if figSave
    disp('Saving')
   
    set(gcf,'PaperPosition',[0 0 10 5],'PaperUnits','inches')
    saveas(gcf,[figDir,'Dll_range.png']);
end