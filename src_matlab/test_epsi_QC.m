%% Look at different QC metrics

clear
addpath('functions')
mname = mfilename('fullpath');
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')
colors = get(0,'defaultaxescolororder');

%% Load data
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% processIDs = {'JMM_M1aC_RM5','JMM_M2aC_RM5','JMM_M2uC_RM5','JMM_M3uC_RM5'};
% indZ = 10;

dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
processIDs = {'JMM_M1aC_RM7p5','JMM_M2aC_RM7p5','JMM_M2uC_RM7p5'};
indZ = 10;

% dataSet = 'AQD_Windermere_bedframe';
% processIDs = {'JMM_M1aC_RM2','JMM_M2aC_RM2','JMM_M2uC_RM2'}; 
% indZ = 10;

[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Comparison Plot

for ii = 1:length(data)
    
   figure(ii),clf
   
   N = length(data(ii).L4.TIME);
   
   
   ax(1) = subplot(7,1,1);
   plot(data(ii).L4.EPSI(:,indZ,1))
   hold all
   plot(data(ii).L4.EPSI(:,indZ,2))
   plot(data(ii).L4.EPSI(:,indZ,3))
   try 
   plot(data(ii).L4.EPSI(:,indZ,4))
   end
   ylabel('\epsilon')
   title([clean_string(processIDs{ii}),' (indZ = ',num2str(indZ),')'])
   legend('b1','b2','b3','b4')
   
   ax(2) = subplot(7,1,2);
   plot(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,1))
   hold all
   plot(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,2))
   plot(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,3))
   try
   plot(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,4))
   end
   ylabel('A1')
   plot([0 N],[0 0],'--k')
   
   ax(3) = subplot(7,1,3);
   plot(data(ii).L4.REGRESSION_COEFF_A0(:,indZ,1)/2/d(ii).metadataGroups.L4.sigmaN_v^2)
   hold all
   plot(data(ii).L4.REGRESSION_COEFF_A0(:,indZ,2)/2/d(ii).metadataGroups.L4.sigmaN_v^2)
   plot(data(ii).L4.REGRESSION_COEFF_A0(:,indZ,3)/2/d(ii).metadataGroups.L4.sigmaN_v^2)
   try
   plot(data(ii).L4.REGRESSION_COEFF_A0(:,indZ,4)/2/d(ii).metadataGroups.L4.sigmaN_v^2)
   end
   plot([0 N], [1 1],'--k')
   ylabel('A_0/2\sigma_N^2')
   ylim([-0.5 2.5])
   
   
   ax(4) = subplot(7,1,4);
   plot(data(ii).L4.REGRESSION_R2(:,indZ,1))
   hold all
   plot(data(ii).L4.REGRESSION_R2(:,indZ,2))
   plot(data(ii).L4.REGRESSION_R2(:,indZ,3))
   try
   plot(data(ii).L4.REGRESSION_R2(:,indZ,4))
   end
   ylabel('R2')
   
   ax(5) = subplot(7,1,5);
   plot(data(ii).L4.EPSI_DEL_RATIO(:,indZ,1)) 
   hold all
   plot(data(ii).L4.EPSI_DEL_RATIO(:,indZ,2)) 
   plot(data(ii).L4.EPSI_DEL_RATIO(:,indZ,3)) 
   try
   plot(data(ii).L4.EPSI_DEL_RATIO(:,indZ,4)) 
   end
   ylim([0 5])
   ylabel('\Delta \epsilon/\epsilon')
   
   ax(6) = subplot(7,1,6);
   plot(data(ii).L4.MSPE(:,indZ,1))
   hold all
   plot(data(ii).L4.MSPE(:,indZ,2))
   plot(data(ii).L4.MSPE(:,indZ,3))
   try
   plot(data(ii).L4.MSPE(:,indZ,4))
   end
   ylabel('MSPE')
   
   ax(7) = subplot(7,1,7);
   plot(data(ii).L4.MAD(:,indZ,1))
   hold all
   plot(data(ii).L4.MAD(:,indZ,2))
   plot(data(ii).L4.MAD(:,indZ,3))
   try
   plot(data(ii).L4.MAD(:,indZ,4))
   end
   ylabel('MAD')
   
   xlabel('time index')
   
   add_fig_info(mname,[],struct())
end
linkaxes(ax,'x')
%% Plot timeseries comparing methods
indB = 1;

figure(20),clf
N = length(data(1).L4.TIME);
for ii = 1:length(data)
    
   
   
   
   
   
   ax(1) = subplot(7,1,1);
   plot(data(ii).L4.EPSI(:,indZ,1))
   if ii == 1; hold all; end
   ylabel('\epsilon')
   
   ax(2) = subplot(7,1,2);
   p = plot(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,1),'color',colors(ii,:));
   indBad = find(data(ii).L4.REGRESSION_COEFF_A1(:,indZ,1)<0);
   plot(indBad,data(ii).L4.REGRESSION_COEFF_A1(indBad,indZ,1),'o','color',get(p,'color'))
   if ii == 1; hold all; end
  
   ylabel('A1')
   plot([0 N],[0 0],'--k')
   
   ax(3) = subplot(7,1,3);
   plot(data(ii).L4.REGRESSION_COEFF_A0(:,indZ,1)/2/d(1).metadataGroups.L4.sigmaN_v^2)
   if ii == 1; hold all; end
   plot([0 N], [1 1],'--k')
   ylabel('A0/2\sigma_N^2')
   ylim([-0.5 2.5])
   
   
   ax(4) = subplot(7,1,4);
   plot(data(ii).L4.REGRESSION_R2(:,indZ,1))
   if ii == 1; hold all; end
   
   ylabel('R2')
   
   ax(5) = subplot(7,1,5);
   plot(data(ii).L4.EPSI_DEL_RATIO(:,indZ,1)) 
   if ii == 1; hold all; end
   ylim([0 5])
   ylabel('\Delta \epsilon/\epsilon')
   
   ax(6) = subplot(7,1,6);
   plot(data(ii).L4.MSPE(:,indZ,1))
   if ii == 1; hold all; end
   ylabel('MSPE')
   
   ax(7) = subplot(7,1,7);
   plot(data(ii).L4.MAD(:,indZ,1))
   if ii == 1; hold all; end
   ylabel('MAD')
   
   xlabel('time index')
   
   add_fig_info(mname,[],struct())
end
legend(ax(1),clean_string(processIDs))
title(ax(1),['indZ = ',num2str(indZ),', indB = ',num2str(indB)])

%% Pick a time and look at structure functions
