clear 
colors = get(0,'Defaultaxescolororder');

Nrealizations = [10 100 500 1000];

% Good data
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% processIDs = {'JMM_M2aC_RM5'}; 
% indZ = 17; indT = 160; indB = 1; clim = [-6 -4];

% Mediocre Data
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
% processIDs = {'JMM_M2aC_RM3'};
% indZ = 15; indT = 134; indB = 1; clim = [-6 -3];

% Poor data
dataSet = 'AQD_Windermere_bedframe';
processIDs = {'JMM_M2aC_RM2'};
indZ = 15; indT = 10; indB = 1; clim = [-10 -8];

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

%%
sigmaN = sqrt(1.8e-5/2);
[eps0,sigmaN0,Rinfo0] = calc_eps_SF_bkup(r',Dll',struct('order',2,'sigmaN_v',sigmaN))
[eps1,sigmaN1,Rinfo1] = calc_eps_SF(r',Dll',struct('order',2,'sigmaN_v',sigmaN))