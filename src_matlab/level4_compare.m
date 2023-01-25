%% level3_compare
%
% Compare level 3 data from 2 files

clear all
mname = mfilename('fullpath');

set(groot,'DefaultFigurePosition',[0 0 500 500])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')
%% Select dataset and process ID numbers
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
% dataSet = 'Signature5beam_TidalShelf';

processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5'};


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
s1 = data(1).L4;
s2 = data(2).L4;

struct_compare(s1,s2)
