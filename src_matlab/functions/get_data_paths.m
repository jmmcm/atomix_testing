function [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet)
% Output the data file root and directory
%
% Justine McMillan
% Oct 20, 2022

% dataDir = ['D:/ATOMIX/Data/', dataSet,'/'];
% metaDir = ['C:/Users/mcmil/Documents/ATOMIX/Work/Testing/metadata/', dataSet,'/'];
dataDir = ['/home/jmm000/DATA/atomix/', dataSet,'/'];
metaDir = ['../metadata/',dataSet,'/'];

switch dataSet
    case 'RDI4beam_TidalChannel_GP130620BPb'
        dataFileRoot = 'RDI4beam_TidalChannel_GP130620BPb_JMM_20231229';
    case 'RDIWH600_CANDYFLOSS_bedframe'
        dataFileRoot = 'RDIWH600_CANDYFLOSS_bedframe'; 
    case 'RDIWH600_CANDYFLOSS_TOP'
        dataFileRoot = 'RDIWH600_CANDYFLOSS_TOP';
    case 'AQD_Windermere_bedframe'
        dataFileRoot = 'AQD_Windermere_bedframe';
    case 'Signature5beam_TidalShelf'
       dataFileRoot = 'Signature5beam_TidalShelf';
    case 'NortekSig1000_TidalChannel'
       dataFileRoot = 'NortekSig1000_TidalChannel';
    otherwise
        error('No datafile specified')        
end