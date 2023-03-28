%% plots_comparison_sig500_ADV.m
% Compare Sig500 results to co-located ADV
%
% Justine McMillan
% Mar 28, 2023

clear
close all

% ADV data
dataFileADV = 'D:/ATOMIX/Data/TidalShelf_HighQuality_ADV/Downloaded/TidalShelf_HighQuality_CEB_20230321.mat';
% zADV = 1.4; % meters above bottom
zADV = 1.3; % distance above ADCP transducer

% ADCP data
dataSet = 'Signature5beam_TidalShelf';
processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u


%% Load data

% ADV
adv = load(dataFileADV);
indBad = find(adv.L4.EPSI_FLAGS>0);
adv.L4.EPSI(indBad) = NaN;
adv.L4.EPSI_FINAL = nanmean(adv.L4.EPSI,2);
%%
% ADCP
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Plot
indZ = get_nearestindex(data(1).L4.Z_DIST,zADV);

figure_named('EPSI_ADV'),clf
plot(adv.L4.TIME,adv.L4.EPSI_FINAL,'linewidth',2)
hold all
plot(data(1).L4.TIME,squeeze(data(1).L4.EPSI(:,indZ,1:5)))
set(gca,'YScale','log')