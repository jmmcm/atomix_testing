clear

%% datasets
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
dNow = d(1);
options = struct('indB',1,'indZ',10,'indT',1);
options.dll_averaging = dNow.metadataGroups.L4.dll_averaging;
options.rMin = dNow.metadataGroups.L4.rMin;
options.rMax = dNow.metadataGroups.L4.rMax;
options.points_select_method = dNow.metadataGroups.L4.points_select_method;

figure(1),clf
ax = subplot(1,1,1);
[ax,p] = plot_DLL_fit(ax,dNow.data.L3,dNow.data.L4,options);
% scatter(dNow.data.L4.REGRESSION_R_DEL(options.indT,options.indZ,options.indB,:).^(2/3),...
%         dNow.data.L4.REGRESSION_DLL(options.indT,options.indZ,options.indB,:),...
%         200, ...
%         dNow)
