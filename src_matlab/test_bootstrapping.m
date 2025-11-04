%% test_bootstrapping.m

clear 
colors = get(0,'Defaultaxescolororder');

Nrealizations = [10 100 500 1000];
colors = colors(2:end,:);

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% processIDs = {'JMM_M2aC_RM5'}; 
% indZ = 17; indT = 1; indB = 1; clim = [-6 -4];

% dataSet = 'AQD_Windermere_bedframe';
% processIDs = {'JMM_M2aC_RM2'};
% indZ = 15; indT = 1; indB = 1; clim = [-10 -8];
% 
% dataSet = 'AQD_NorthSea_bedframe';
% processIDs = {'JMM_M2aC_RM0p3'};
% indZ = 15; indT = 1; indB = 1; clim = [-10 -6];


dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
processIDs = {'JMM_M2aC_RM3'};
indZ = 15; indT = 134; indB = 1; clim = [-6 -3];


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

%% Test bootstrapping
[epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,500);


%% 
epsiBS_value = zeros(length(data.L4.TIME),length(Nrealizations));
epsiBS_ci_low = zeros(length(data.L4.TIME),length(Nrealizations));
epsiBS_ci_hgh = zeros(length(data.L4.TIME),length(Nrealizations));

for tt = 1:length(data.L4.TIME)
    tt
    r = squeeze(data.L4.REGRESSION_R_DEL(tt,indZ,indB,:));
    Dll = squeeze(data.L4.REGRESSION_DLL(tt,indZ,indB,:));
    
%     for nn =1:length(Nrealizations)
%         [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,Nrealizations(nn));
%         epsiBS_value(tt,nn)   = epsiBS;
%         epsiBS_ci_low(tt,nn) = epsiBS_ci(1);
%         epsiBS_ci_hgh(tt,nn) = epsiBS_ci(2);
%     end

    [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,Nrealizations(1));
    epsiBS1all(tt)   = epsiBS;
    epsiBS1_ci_all(tt,:) = epsiBS_ci;
    
    [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,Nrealizations(2));
    epsiBS2all(tt)   = epsiBS;
    epsiBS2_ci_all(tt,:) = epsiBS_ci;
    
    [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,Nrealizations(3));
    epsiBS3all(tt)   = epsiBS;
    epsiBS3_ci_all(tt,:) = epsiBS_ci;
    
    [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll,Nrealizations(4));
    epsiBS4all(tt)   = epsiBS;
    epsiBS4_ci_all(tt,:) = epsiBS_ci;
    
    
%     [epsiBS0500,epsiBS0500_ci,Lin]=bootstrap_structurefunction(r,Dll,10);
%     epsiBS0500all(tt)   = epsiBS0500;
%     epsiBS0500_ci_all(tt,:) = epsiBS0500_ci;
end

%%
figure(2), clf
t = 1:length(data.L4.TIME);
p1 = plot(t,data.L4.EPSI(:,indZ,indB),'k','linewidth',2,'DisplayName','\epsilon');
hold all
plot(t,epsiBS1all,'k.','markersize',10);
p2 = plot(t,data.L4.EPSI_CI_LOW(:,indZ,indB),'--k','DisplayName','regression');
plot(t,data.L4.EPSI_CI_HIGH(:,indZ,indB),'--k');
% for nn = 1:length(Nrealizations)
%     p(nn) = plot(data.L4.TIME,epsiBS_ci_low(:,nn),'color',colors(nn,:),...
%         'DisplayName',['BS (N = ' num2str(Nrealizations(nn)) ')']);
%     plot(data.L4.TIME,epsiBS_ci_hgh(:,nn),'color',colors(nn,:));
% end
p3 = plot(t,epsiBS1_ci_all(:,1),'color',0.6*[0 1 0],'DisplayName',['BS (N=' num2str(Nrealizations(1)) ')']);
plot(t,epsiBS1_ci_all(:,2),'color',0.6*[0 1 0]);
p4 = plot(t,epsiBS2_ci_all(:,1),'color',1*[0 1 1],'DisplayName',['BS (N=' num2str(Nrealizations(2)) ')']);
plot(t,epsiBS2_ci_all(:,2),'color',1*[0 1 1]);
p5 = plot(t,epsiBS3_ci_all(:,1),'color',colors(2,:),'DisplayName',['BS (N=' num2str(Nrealizations(3)) ')']);
plot(t,epsiBS3_ci_all(:,2),'color',colors(2,:));
p6 = plot(t,epsiBS4_ci_all(:,1),'color',colors(3,:),'DisplayName',['BS (N=' num2str(Nrealizations(4)) ')']);
plot(t,epsiBS4_ci_all(:,2),'color',colors(3,:));
% p3 = plot(t,epsiBS_ci_all(:,1),'color',0.6*[0 1 0]);
% plot(t,epsiBS0500_ci_all(:,2),'color',0.6*[0 1 0]);
% p4 = plot(t,epsiBS1000_ci_all(:,1),'--','color',0.6*[0 0 1]);
% plot(t,epsiBS1000_ci_all(:,2),'--','color',0.6*[0 0 1]);
set(gca,'yscale','linear')
% legend([p1,p2,p3,p4],'\epsilon','normal','BS (N = 500)','BS (N = 1000)')
legend([p1 p2 p3 p4 p5 p6])
xlabel('index')
ylabel('\epsilon [W/kg]')
%%
figure(3),clf
ax = subplot(1,1,1)
plotData = struct('x',data.L4.TIME,'y',1:length(data.L4.Z_DIST),'values',log10(data.L4.EPSI(:,:,indB)'),'var','EPSI');
opts = struct('ylabel','z index','clabel',['log10(\epsilon)'],'clim',clim);
plot_pcolor(ax(1),plotData,opts);
hold all
plot(get(gca,'xlim'),[1 1]*indZ,'k')