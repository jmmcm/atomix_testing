%% test_DLL_methods_fromL2qc.m
%
% Compare methods starting from L2 data with flags applied
%
% Justine McMillan
% Jan 14, 2021
%
% 2023-01-19: Updated to use any method, changed filename from
%             test_method1.m

clear
mname = mfilename('fullpath');

method = 'M2uC_RM7p5';
matFile = ['D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/RDIWH600_CANDYFLOSS_bedframe_BDS_',method];

load(matFile)

%% Get processing info
dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
processID = ['JMM_',method]; % To get flags and processing info

% Files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
infoFile =  [metaDir,processID,'/',dataSet,'_info.yml'];
flagFile = [metaDir,processID,'/',dataSet,'_flags.yml'];
metaFileGroups = [metaDir,processID,'/',dataSet,'_groups.yml'];
metaFileGlobal = [metaDir,dataSet,'_global.yml'];
matFileOut = [dataDir,dataFileRoot,'_',processID,'_fromL2qc.mat'];

% Metadata (for specific test)
metadataGroups = ReadYaml(metaFileGroups);
metadataGlobal = ReadYaml(metaFileGlobal);
timeRef = datenum(metadataGroups.L1.time_ref);


% Flags
flags = ReadYaml(flagFile); 
flags = get_flag_struct_clean(flags,struct('dispOutput',1));
    
% Processing info
infoProcessing = ReadYaml(infoFile)

%% Options
optionsLev3.order = 2;
optionsLev3.rMax = metadataGroups.L3.rMax; 
optionsLev3.dr = (data.L1.Z_DIST(2) - data.L1.Z_DIST(1))/cosd(data.L1.THETA(1)); % Assumes all bins are the same size and all beam angles are the same
optionsLev3.nbinMax = floor(optionsLev3.rMax./optionsLev3.dr); % Max number of bins to use
optionsLev3.diffMethod = metadataGroups.L3.dll_method;
optionsLev3.dllAvg = str2num(metadataGroups.L3.dll_averaging); 
optionsLev3.flagFile = flagFile;
optionsLev3.figure = 0;

optionsLev4.Const = metadataGroups.L4.C2;
optionsLev4.sigmaN_v = metadataGroups.L4.sigmaN_v; % Only used for plotting expected intercept
optionsLev4.order = optionsLev3.order;
optionsLev4.flagFile = flagFile;
optionsLev4.figure = 0;

%% Apply flags to detrended velocities

flagsL2 = squeeze(data.L2.R_VEL_DETRENDED_FLAGS);
data.L2.R_VEL_DETRENDED(flagsL2>0) = NaN;

%% Level 3
disp('===== LEVEL 3 =====')
data(2).L3 = calc_level3_ATOMIX(data.L2,optionsLev3);
disp('===== LEVEL 3 (end) =====')

%% Level 4
disp('===== LEVEL 4 =====')
data(2).L4 = calc_level4_ATOMIX(data(2).L3,optionsLev4);
disp('===== LEVEL 4 (end) =====')

%%  Plot DLL
options.indB = 1;
options.indZ = 4;
indT = [1,2];

for tt = 1:length(indT)
    options.indT = indT(tt);
    
    figure(tt),clf
    [p]=plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,options);
end


%% Prepare for output files
data(2).L1 = data(1).L1;
data(2).L2 = data(1).L2;

fileInfo.data = matFile;
fileInfo.flagFile = flagFile;
fileInfo.metaFileGroups = metaFileGroups;
fileInfo.metaFileGlobal = metaFileGlobal;

%% Create Mat file
% Is very slow, so save locally, then move
disp('===== CREATE MAT FILE =====')

data = data(2);

history = get_metadata(mname);

[~,oname]=fileparts(matFileOut);
save(oname,'data','flags','metadataGroups','metadataGlobal','fileInfo','infoProcessing','history','-v7.3');
movefile(strcat(oname,'.mat'),matFileOut)

disp(['Matfile created: ' matFileOut])

disp('===== CREATE MAT FILE =====')