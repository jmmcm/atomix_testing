%% plots_comparison_sig500_ADV.m
% Compare Sig500 results to co-located ADV
%
% Justine McMillan
% Mar 28, 2023

clear
close all
mname = mfilename('fullpath');
flg.saveFigs = 1;
figName = '../figures/Signature5beam_TidalShelf/ADV_comparison_diff_rmin.png';

% ADV data
dataFileADV = 'D:/ATOMIX/Data/TidalShelf_HighQuality_ADV/Downloaded/TidalShelf_HighQuality_CEB_20230321.mat';
% zADV = 1.4; % meters above bottom
zADV = 1.3; % distance of ADV above ADCP transducer

% ADCP data
dataSet = 'Signature5beam_TidalShelf';
processIDs = {'JMM_M2uC_RM2','JMM_M2uC_RM2_rmin_3bins'}; % Compare different bin separations


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
    names{ii} = [processIDs{ii}];
end

%% Plot
indZ = get_nearestindex(data(1).L4.Z_DIST,zADV);

figure_named('EPSI_ADV'),clf
set(gcf,'Position',[50 50 1200 500])
plot(get_yd(adv.L4.TIME),adv.L4.EPSI_FINAL,'linewidth',2)
hold all
p = plot(get_yd(data(1).L4.TIME),squeeze(data(1).L4.EPSI(:,indZ,1:5)));
for pp = 1:length(p)
    plot(get_yd(data(1).L4.TIME),squeeze(data(2).L4.EPSI(:,indZ,pp)),'--','color',get(p(pp),'color'))
end
set(gca,'YScale','log')
legend('ADV','ADCP - beam 1','ADCP - beam 2','ADCP - beam 3','ADCP - beam 4','ADCP - beam 5')
title(['ADV Compared to ',clean_string(names{1}),' (solid) and ',clean_string(names{2}),' (dashed), Z\_DIST = ',num2str(data(1).L4.Z_DIST(indZ)),' m'])
xlabel('year day')
ylabel('\epsilon [W/kg]')
add_fig_info(mname,[],struct())
if flg.saveFigs
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end