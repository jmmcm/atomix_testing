%% 
% Script to process the data from level 1 to level 4 and ultimately computes 
% EPSI. Generates a matfile and/or netcdf file that can be used for comparison
%
% Justine McMillan 
% Apr 8, 2022
% 2022-06-29, JMM: Generalized to be used for any data file

clear all
mname = mfilename('fullpath');
addpath('functions')
addpath(genpath('../../netcdftools_ceb/'))
addpath(genpath('../../adcp_toolbox/'))
addpath(genpath('../../utilitieswork/'))

tic
%% Select dataset and processing ID
% Select one or more files to process
caseIDs = {'3F','3G'};
% caseIDs = {'1A','1C','2A','2C','3F','3G','5A','5B','6A','6B','7A','7B'}; % All centered and all realizations used in paper
% caseIDs = {'1A','1B','1C','1D','2A','2B','2C','2D','3A','3B','3C','4A','4B','4C','4D','4E','4F','5A','5B','5C','7A','7B'}; %ALL

%% Process
for caseID = caseIDs
    clear L1 Ancillary
    switch caseID{1}
        case '1A'
            dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; rawID = 'dJMM_M2uC_RM5';
            processID = 'JMM_M2uC_RM5';
        case '1B'
            dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; rawID = 'dJMM_M2uC_RM5';
            processID = 'JMM_M2aC_RM5';
        case '1C'
            dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; rawID = 'dJMM_M2uC_RM5';
            processID = 'JMM_M1aC_RM5';
        case '1D'
            dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; rawID = 'dJMM_M2uC_RM5';
            processID = 'JMM_M3uC_RM5';
        case '2A'
            dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; rawID = 'BDS_M1aC_RM7p5';
            processID = 'JMM_M2uC_RM7p5';
        case '2B'
            dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; rawID = 'BDS_M1aC_RM7p5'; 
            processID = 'JMM_M2aC_RM7p5';
        case '2C'
            dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; rawID = 'BDS_M1aC_RM7p5'; 
            processID = 'JMM_M1aC_RM7p5';
        case '2D'
            dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; rawID = 'BDS_M1aC_RM7p5'; 
            processID = 'JMM_M3uC_RM7p5';
        case '3A'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M2uC_RM1p5';
        case '3B'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M2aC_RM1p5';
        case '3C'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M1aC_RM1p5';
        case '3D'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M1aC_RM1p0';
        case '3E'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M2uC_RM1p0';
         case '3F'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M1aC_RM0p75';
        case '3G'
            dataSet = 'RDIWH600_CANDYFLOSS_TOP'; rawID = 'BDS_M1aC_RM1p5'; 
            processID = 'JMM_M2uC_RM0p75';
        case '4A'
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M2uC_RM2';
        case '4B' 
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M2aC_RM2';
        case '4C'
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M2uC_RM4';
        case '4D'
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M2aC_RM2';
        case '4E'
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M1aC_RM4';
        case '4F'
            dataSet = 'Signature5beam_TidalShelf'; rawID = 'CEB'; 
            processID = 'JMM_M2uC_RM2_rmin_3bins';
        case '5A'
            dataSet = 'AQD_Windermere_bedframe'; rawID = 'BDS_M1aA_RM2'; 
            processID = 'JMM_M2uC_RM2';
        case '5B'
            dataSet = 'AQD_Windermere_bedframe'; rawID = 'BDS_M1aA_RM2'; 
            processID = 'JMM_M1aC_RM2';
        case '5C'
            dataSet = 'AQD_Windermere_bedframe'; rawID = 'BDS_M1aA_RM2'; 
            processID = 'JMM_M2aC_RM2';
        case '6A'
            dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; rawID = 'NSL'; 
            processID = 'JMM_M2uC_RM5';
        case '6B'
            dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; rawID = 'NSL'; 
            processID = 'JMM_M1aC_RM5';
        case '7A'
            dataSet = 'AQD_NorthSea_bedframe'; rawID = 'CEB';
            processID = 'JMM_M2uC_RM0p3';
        case '7B'
            dataSet = 'AQD_NorthSea_bedframe'; rawID = 'CEB';
            processID = 'JMM_M1aC_RM0p3';
        otherwise
            error('Need to create case')
    end


    %% Filenames
    [dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);


%     matFileIn = [dataDir,'Downloaded/',dataFileRoot,'.mat']; % Provided file
    matFileIn = [dataDir,dataFileRoot,'_',rawID,'.mat']; % Output of convert_matIn_to_JMM_format.m
    matFileOut = [dataDir,dataFileRoot,'_',processID,'.mat'];

    infoFile =  [metaDir,processID,'/',dataSet,'_info.yml'];
    flagFile = [metaDir,processID,'/',dataSet,'_flags.yml'];
    metaFileGroups = [metaDir,processID,'/',dataSet,'_groups.yml'];
    metaFileGlobal = [metaDir,dataSet,'_global.yml'];
    
    %% Load Flags and Attributes

    % Metadata (for specific test)
    metadataGroups = ReadYaml(metaFileGroups);
    metadataGlobal = ReadYaml(metaFileGlobal);
    timeRef = datenum(metadataGroups.L1.time_ref);


    % Flags
    flags = ReadYaml(flagFile); 
    flags = get_flag_struct_clean(flags,struct('dispOutput',1));
    
    % Processing info
    infoProcessing = ReadYaml(infoFile)
    
    %% Load data 

    d = load(matFileIn);
    L1 = d.data.L1;  
    
    try            
       Ancillary = d.data.Ancillary; % Simply passed to output file if available
    catch 
        disp(' No ancillary data available'),pause(10)
    end

    %% Processing parameters 
    % Values are read from atomix metadata in yml file where possible

    flg.checkInputs = 0; % Set to 1 for the first time script is run

    try
        optionsLev2.burstInterval = metadataGroups.L2.burst_interval; % Time between subsequent bursts
    catch
        optionsLev2.burstInterval = 0; % Defaults to 0 for continuous sampling instruments
    end
    optionsLev2.ensLength = metadataGroups.L2.segment_length; % May need to be adapted for bursting instruments
    optionsLev2.freqApprox = ((L1.TIME(2) - L1.TIME(1))*24*3600)^(-1); % [Hz]
    optionsLev2.detrendMethod = metadataGroups.L2.detrending_method;
    optionsLev2.figureCheck = 0;

    optionsLev3.order = 2;
    %optionsLev3.rMax = metadataGroups.L3.rMax; 
    %optionsLev3.dr = (L1.Z_DIST(2) - L1.Z_DIST(1))/cosd(L1.THETA(1)); % Assumes all bins are the same size and all beam angles are the same
    %optionsLev3.nbinMax = floor(optionsLev3.rMax./optionsLev3.dr); % Max number of bins to use
    optionsLev3.diffMethod = metadataGroups.L3.dll_method;
    %optionsLev3.dllAvg = str2num(metadataGroups.L3.dll_averaging); 
    optionsLev3.flagFile = flagFile;
    optionsLev3.figure = 0;

    optionsLev4.Const = metadataGroups.L4.C2;
    optionsLev4.sigmaN_v = metadataGroups.L4.sigmaN_v; % Only used for plotting expected intercept 
    optionsLev4.order = optionsLev3.order;
    optionsLev4.rMin = metadataGroups.L4.rMin;
    optionsLev4.rMax = metadataGroups.L4.rMax;
    optionsLev4.points_select_method = metadataGroups.L4.points_select_method;
    optionsLev4.dll_averaging = str2num(metadataGroups.L4.dll_averaging);
    optionsLev4.flagFile = flagFile;
    optionsLev4.figure = 0;
    % NEW


    %% Checks and warnings

    % bin size
    binSize = L1.Z_DIST(2) - L1.Z_DIST(1); % Assumes all bins are the same size
    if any(abs(diff(L1.Z_DIST)-binSize)>1e-4)
        error('Vertical bin sizes are nonuniform')
    end

    % noise level
    flagInfo = get_flag_info(flagFile,'L4','EPSI_FLAGS','dll_intercept_too_high',struct());
    sigmaN_v_flags = flagInfo.flag_thresholds;
    if abs(sigmaN_v_flags-4*optionsLev4.sigmaN_v^2)>1e-4 % expected intercept = 2*sigmaV^2, so threshold = 4*sigmaV^2
        warning('dll_intercept_too_high value does not agree with optionsLev4.sigmaN_v. Continue?')
        disp(['dll_intercept_too_high = ',num2str(sigmaN_v_flags)])
        disp(['4*optionsLev4.sigmaN_v^2 = ',num2str(4*optionsLev4.sigmaN_v^2)])
        pause
    end


    % Manual check
    if flg.checkInputs
        disp('Level2:'),disp(optionsLev2)
        disp('Level3:'),disp(optionsLev3)
        disp('Level4:'),disp(optionsLev4)
        reply = input('Have you reviewed the options? Y/N [Y]:','s');
        if isempty(reply)
            reply = 'Y';
        end
        if ~strcmp(reply,'Y') 
            error('Need to review inputs before proceeding. Ensure consistency with Yaml metadata')
        end
    end


    disp('============PROCESSING====================')
    %% Level 2
    disp('===== LEVEL 2 =====')

    % Ensemble indices
    disp('* GETTING ENSEMBLES *')
    if optionsLev2.burstInterval == 0
        [ind_start, ind_end] = get_ens_inds(L1.TIME*24*3600,optionsLev2.ensLength,optionsLev2.freqApprox);
    else
        [ind_start,ind_end,npts] = get_burst_inds(L1.TIME*24*3600,0.9*(optionsLev2.burstInterval-optionsLev2.ensLength));
    end
    if length(ind_start)<1
        error('Error: Ensembles not computed correctly')
    end
    disp('=====')

    % Process
    L2 = calc_level2_ATOMIX(L1,ind_start,ind_end,optionsLev2);

    disp('===== LEVEL 2 (end) =====')

    %% Level 3
    disp('===== LEVEL 3 =====')
    L3 = calc_level3_ATOMIX(L2,optionsLev3);
    disp('===== LEVEL 3 (end) =====')

    %% Level 4
    disp('===== LEVEL 4 =====')
    L4 = calc_level4_ATOMIX(L3,optionsLev4);
    disp('===== LEVEL 4 (end) =====')

    %% Prepare for output files
    fileInfo.data = matFileIn;
    fileInfo.flagFile = flagFile;
    fileInfo.metaFileGroups = metaFileGroups;
    fileInfo.metaFileGlobal = metaFileGlobal;

    %% Create Mat file 
    % Is very slow, so save locally, then move
    disp('===== CREATE MAT FILE =====')
    data = struct('L1',L1,'L2',L2,'L3',L3,'L4',L4);
    try data.Ancillary = Ancillary; end

    history = get_metadata(mname);

    %[~,oname]=fileparts(matFileOut);
    save(matFileOut,'data','flags','metadataGroups','metadataGlobal','fileInfo','infoProcessing','history','-v7.3');
    %movefile(strcat(oname,'.mat'),matFileOut)

    disp(['Matfile created: ' matFileOut])

    disp('===== CREATE MAT FILE =====')
end

toc