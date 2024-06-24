%% Test despiking.
%
% Quick example to add several to the data and see the effect. 
%
% We have not really considered despiking because we assumed it was done to
% L1 data. 
%
% Justine McMillan
% 2024-02-19

clear

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

%% 
indT = 1;
indZ = 17;
indB = 1;

t = d(1).data.L2.TIME(indT,:);
v = squeeze(d(1).data.L2.R_VEL_DETRENDED(indT,indZ,indB,:));
r = squeeze(d(1).data.L4.REGRESSION_R_DEL(indT,indZ,indB,:));
D = squeeze(d(1).data.L4.REGRESSION_DLL(indT,indZ,indB,:));
A0 = squeeze(d(1).data.L4.REGRESSION_COEFF_A0(indT,indZ,indB));
A1 = squeeze(d(1).data.L4.REGRESSION_COEFF_A1(indT,indZ,indB));
epsi = squeeze(d(1).data.L4.EPSI(indT,indZ,indB));

%% copy data and add spike
dataSpike.L1 = d.data.L1;
dataSpike.L2 = d.data.L2;

% Add spike(s)
dataSpike.L2.R_VEL_DETRENDED(indT,indZ,indB,150) = 0.5;
dataSpike.L2.R_VEL_DETRENDED(indT,indZ,indB,400) = -1;
dataSpike.L2.R_VEL_DETRENDED(indT,indZ-2,indB,300) = -0.7;
dataSpike.L2.R_VEL_DETRENDED(indT,indZ+4,indB,250) = 1;

% Calc L3
optionsLev3.order = 2;
optionsLev3.diffMethod = d.metadataGroups.L3.dll_method;
optionsLev3.flagFile = d.fileInfo.flagFile;
optionsLev3.figure = 0;
dataSpike.L3 = calc_level3_ATOMIX(dataSpike.L2,optionsLev3);

% Calc L4
optionsLev4.Const = d.metadataGroups.L4.C2;
optionsLev4.sigmaN_v = d.metadataGroups.L4.sigmaN_v; % Only used for plotting expected intercept 
optionsLev4.order = optionsLev3.order;
optionsLev4.rMin = d.metadataGroups.L4.rMin;
optionsLev4.rMax = d.metadataGroups.L4.rMax;
optionsLev4.points_select_method = d.metadataGroups.L4.points_select_method;
optionsLev4.dll_averaging = str2num(d.metadataGroups.L4.dll_averaging);
optionsLev4.flagFile = optionsLev3.flagFile;
optionsLev4.figure = 0;
dataSpike.L4 = calc_level4_ATOMIX(dataSpike.L3,optionsLev4);

% Simple variables
vS = squeeze(dataSpike.L2.R_VEL_DETRENDED(indT,indZ,indB,:));
rS = squeeze(dataSpike.L4.REGRESSION_R_DEL(indT,indZ,indB,:));
DS = squeeze(dataSpike.L4.REGRESSION_DLL(indT,indZ,indB,:));
A0S = squeeze(dataSpike.L4.REGRESSION_COEFF_A0(indT,indZ,indB));
A1S = squeeze(dataSpike.L4.REGRESSION_COEFF_A1(indT,indZ,indB));
epsiS = squeeze(dataSpike.L4.EPSI(indT,indZ,indB));

%% Plot comparison 
rfit = [0 5];

figure(1),clf
subplot(1,3,1:2)
plot((t-t(1))*24*60,vS)
hold all
plot((t-t(1))*24*60,v)
subplot(1,3,3)
plot(rS.^(2/3),DS,'.')
hold all
plot(r.^(2/3),D,'.')
plot(rfit.^(2/3),A0S+A1S*rfit.^(2/3),'--k')
plot(rfit.^(2/3),A0+A1*rfit.^(2/3),'k')
legend('Spike','No spike',...
    ['Spike Fit \epsilon = ',num2str(epsi),' W/kg'],...
    ['No Spike Fit \epsilon = ',num2str(epsiS),' W/kg'])
