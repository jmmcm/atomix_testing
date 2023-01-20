%% level2_compare
%
% Compare level 2 data from 2 files

clear all
mname = mfilename('fullpath');

set(groot,'DefaultFigurePosition',[0 0 500 500])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')
%% Select dataset and process ID numbers
dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
% dataSet = 'Signature5beam_TidalShelf';

processIDs = {'JMM00','JMM_M2uC_RM5'};


%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

%% Compare structures
s1 = data(1).L2;
s2 = data(2).L2;

struct_compare(s1,s2)

%% Compare R_VEL_DETRENDED
indT = 1;
indZ = 10;
indB = 1;

try
    v1 = squeeze(s1.R_VEL(indT,indZ,indB,:));
catch
    v1 = 0;
end
v1dt = squeeze(s1.R_VEL_DETRENDED(indT,indZ,indB,:));
v2dt = squeeze(s2.R_VEL_DETRENDED(indT,indZ,indB,:));

figure(1),clf
plot(v1)
hold all
plot(v1dt)
plot(v2dt)
legend('v','vdt1','vdt2')

%% 