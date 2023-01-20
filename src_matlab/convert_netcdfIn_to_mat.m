%% 
% Convert ATOMIX netcdf data to mat file to facilitate easier comparisons. 
% Necessary if .mat file is not supplied by PI for dataset
%
% Justine McMillan
% May 31, 2022

clear all
close all
mname = mfilename('fullpath');

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
dataSet = 'Signature5beam_TidalShelf'; 
metadataID = 'CEB01'

%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

ncFileCntl  = [dataDir,dataFileRoot,'.nc'];
matFileCntl = [dataDir,dataFileRoot,'_converted.mat'];

flagFile = [metaDir,metadataID,'/',dataSet,'_flags.yml'];
metaFileGroups = [metaDir,metadataID,'/',dataSet,'_groups.yml'];
metaFileGlobal = [metaDir,dataSet,'_global.yml'];

%% Load data
dataCntl = load_netcdf_data(ncFileCntl);

%% Load metadata
metadataGroups = ReadYaml(metaFileGroups);
[metadataGlobal, attributes] = load_netcdf_attributes(ncFileCntl);

%% Load flags
flagsIn = ReadYaml(flagFile);
flagsIn = get_flag_struct_clean(flagsIn,struct('dispOutput',0));

%% Modify time to be on the same reference (i.e. matlab time)
dateStr = attributes.L1.TIME.units(end-20:end-10);
timeStr = attributes.L1.TIME.units(end-8:end-1);
dateRef = datenum([dateStr ' ' timeStr],'yyyy-mm-dd HH:MM:SS');

levels = fieldnames(dataCntl);
for ll = 1:length(levels)
    dataCntl.(levels{ll}).TIME = dataCntl.(levels{ll}).TIME + dateRef;
    
    if isfield(dataCntl.(levels{ll}),'TIME_BNDS')
        dataCntl.(levels{ll}).TIME_BNDS = dataCntl.(levels{ll}).TIME_BNDS + dateRef;
    end
        
end

%% Get data for method used as 'Control'
switch dataSet
    case 'RDIWH600_CANDYFLOSS_TOP'
        
        % Method 2.1
        data.Ancillary = dataCntl.Ancillary;
        data.L1 = dataCntl.L1;
        data.L2 = dataCntl.L2_A; %Mean deducted
        data.L3 = dataCntl.L3_A2; % Method 2
        data.L4 = dataCntl.L4_A2S; % Standard regression
        % HACK: TO correct EPSI_FINAL
        epsitmp = data.L4.EPSI;
        epsitmp(data.L4.EPSI_FLAGS>0) = NaN;
        data.L4.EPSI_FINAL = squeeze(nanmean(epsitmp,3));
        
        flags.L1 = flagsIn.L1;
        flags.L2 = flagsIn.L2_A; %Mean deducted
        flags.L3 = flagsIn.L3_A2; % Method 2
        flags.L4 = flagsIn.L4_A2S; % Standard regression
        
    otherwise
        data = dataCntl;
        flags = flagsIn;
end 

return
%% Save data
disp('===== CREATE MAT FILE =====')

fileInfo.data = ncFileCntl;
fileInfo.flagFile = flagFile;
fileInfo.metaFileGroups = metaFileGroups;
fileInfo.metaFileGlobal = metaFileGlobal;

history = get_metadata(mname);
[~,oname]=fileparts(matFileCntl);
save(oname,'data','flags','metadataGroups','metadataGlobal','fileInfo','history');
movefile(strcat(oname,'.mat'),matFileCntl)

disp(['Matfile created: ' matFileCntl])

disp('===== CREATE MAT FILE =====')

