%% test_bootstrapping.m

clear 


% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% processIDs = {'JMM_M2uC_RM5'};

dataSet = 'AQD_Windermere_bedframe';
processIDs = {'JMM_M2aC_RM2'};

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

indZ = 17;
indB = 1;
indT = 1;
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


%% Test bootstrapping
[epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll);

%% 
for tt = 1:length(data.L4.TIME)
    tt
    r = squeeze(data.L4.REGRESSION_R_DEL(tt,indZ,indB,:));
    Dll = squeeze(data.L4.REGRESSION_DLL(tt,indZ,indB,:));
    [epsiBS,epsiBS_ci,Lin]=bootstrap_structurefunction(r,Dll);

    epsiBSall(tt)   = epsiBS;
    epsiBS_ci_all(tt,:) = epsiBS_ci;
end

%%
figure(2), clf
p1 = plot(data.L4.TIME,data.L4.EPSI(:,indZ,indT),'k','linewidth',2);
hold all
plot(data.L4.TIME,epsiBSall,'k.');
p2 = plot(data.L4.TIME,data.L4.EPSI_CI_LOW(:,indZ,indT),'r');
plot(data.L4.TIME,data.L4.EPSI_CI_HIGH(:,indZ,indT),'r');
p3 = plot(data.L4.TIME,epsiBS_ci_all(:,1),'color',0.6*[0 1 0]);
plot(data.L4.TIME,epsiBS_ci_all(:,2),'color',0.6*[0 1 0]);
set(gca,'yscale','log')
legend([p1,p2,p3],'\epsilon','normal','bootstrap')