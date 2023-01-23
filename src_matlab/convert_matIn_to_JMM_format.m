%%
% Prepare provided file for comparisons. Only relevant if provided file
% includes all levels and not just level 1.
%
% Justine McMillan
% Oct 21, 2022

clear
close all
mname = mfilename('fullpath');

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'dJMM_M2uC_RM5'; % Method 2.1 differencing, standard regression (dJMM downloaded data, hack to distinguish downloaded and processed metadata folders)
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M1aC_RM7p5'; % Method 1 differencing, canonical regression
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M1aA_RM7p5'; % Method 1 differencing, modified regression
dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M2uC_RM7p5'; % Method 2.1 differencing, standard regression
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M1aC_RM1p5'; % Labelled A1S (Mean deducted, Method 1 differencing, standard regression)
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M1aA_RM1p5'; % Labelled A1M (Mean deducted, Method 1 differencing, modified regression)
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M2uC_RM1p5'; % Labelled A2S (Mean deducted, Method 2 differencing, standard regression)
% dataSet = 'Signature5beam_TidalShelf'; processID = 'CEB'; % Only L1 data

%% Data files
[dataFileRoot,dataDirRoot,metaDir] = get_data_paths(dataSet);

dataDirFull = [dataDirRoot 'Downloaded/' processID];
matFile = dir([dataDirFull '/*.mat']);
matFileIn  = [dataDirFull '/' matFile.name]; % Provided file
matFileOut = [dataDirRoot,dataFileRoot,'_',processID,'.mat']; 

infoFile =  [metaDir,processID,'/',dataSet,'_info.yml'];
flagFile = [metaDir,processID,'/',dataSet,'_flags.yml'];
metaFileGroups = [metaDir,processID,'/',dataSet,'_groups.yml'];
metaFileGlobal = [metaDir,dataSet,'_global.yml'];


%% Load Flags and Attributes

% Global metadata
metadataGlobal = ReadYaml(metaFileGlobal);

% Group Metadata (for specific processID)
metadataGroups = ReadYaml(metaFileGroups);

% Flags
flags = ReadYaml(flagFile);
flags = get_flag_struct_clean(flags,struct('dispOutput',1));
if ~isfield(flags,'L2'); flags.L2 = struct(); end
flags = orderfields(flags);

% Processing info
infoProcessing = ReadYaml(infoFile)

%% Load data

d = load(matFileIn);
switch dataSet
    case 'RDI4beam_TidalChannel_GP130620BPb'
        data = d.data;
    case 'RDIWH600_CANDYFLOSS_bedframe'
        data.L1 = d.data.L1;
        data.Ancillary = d.data.Ancillary;
        data.Ancillary.ENU = nanmean(data.Ancillary.ENU,4);
        data.Ancillary.ENU = permute(data.Ancillary.ENU,[2,3,1]);
        
        data.L2 = d.data.L2;
        data.L3 = d.data.L3;
        data.L4 = d.data.L4;
               
        % Apply flags and calculate EPSI_FINAL
        epsitmp = data.L4.EPSI;
        epsitmp(data.L4.EPSI_FLAGS>0) = NaN;
        data.L4.EPSI_FINAL = squeeze(nanmean(epsitmp,3));
        
        % Convert DLL
        if strcmp(processID(5:8),'M2uC')
            data.L3 = convert_DLL_BDS_to_JMM(data.L3,metadataGroups.L4.r_max_req);
        end

        
    case 'RDIWH600_CANDYFLOSS_TOP'
        data.L1 = d.data.L1;
        data.Ancillary = d.data.Ancillary;
        switch processID
            
            case 'BDS_M1aC_RM1p5' % A1S: Mean removed, Method 1 differencing, standard regression
                data.L2 = d.data.L2_A;
                data.L3 = d.data.L3_A1;
                data.L4 = d.data.L4_A1S;
            case 'BDS_M1aA_RM1p5' % A1M: Mean removed, Method 1 differencing, modified regression
                data.L2 = d.data.L2_A;
                data.L3 = d.data.L3_A1;
                data.L4 = d.data.L4_A1M;
            case 'BDS_M2uC_RM1p5' % A2S: Mean removed, Method 2 differencing, standard regression
                data.L2 = d.data.L2_A;
                data.L3 = d.data.L3_A2;
                data.L4 = d.data.L4_A2S;
                
                data.L3 = convert_DLL_BDS_to_JMM(data.L3,1.5);
            otherwise
                error(['Need to define ',processID])
        end
    case 'Signature5beam_TidalShelf'
        data.L1 = d.lev1;
        
        % Apply flags
        velB = data.L1.R_VEL;
        velBFlags = double(data.L1.R_VEL_FLAGS);
        velBFlags(velBFlags>0) = NaN;
        velBFlags = velBFlags+1;
        velBqc = velB.*velBFlags;
        
        % Calculate raw ENU
        V1 = velBqc(:,:,1);
        V2 = velBqc(:,:,2);
        V3 = velBqc(:,:,3);
        V4 = velBqc(:,:,4);
        hdg = data.L1.HEADING;
        pitch = data.L1.PITCH;
        roll = data.L1.ROLL;
        options = struct('figure',0);
        
        ENUraw = NaN*ones(length(data.L1.TIME),length(data.L1.Z_DIST),4);
        for zz = 1:length(data.L1.Z_DIST)
            disp(['Computing ENU velocities. Bin ',num2str(zz),' of ',num2str(length(data.L1.Z_DIST))])
            [ENUraw(:,zz,1),ENUraw(:,zz,2),ENUraw(:,zz,3),ENUraw(:,zz,4)] = AD2CP_coordTransform(V1(:,zz),V2(:,zz),V3(:,zz),V4(:,zz),hdg,pitch,roll,options);
        end
        
        % Calculate average ENU (TODO: Read these in from metafile)
        ensLength = metadataGroups.Ancillary.segment_length; % [s]
        freqApprox = 1/(data.L1.TIME(2)-data.L1.TIME(1))/24/3600; % [Hz]
        
        [ind_start, ind_end] = get_ens_inds(data.L1.TIME*24*3600,ensLength,freqApprox);
        NT = length(ind_start);
        NZ = length(data.L1.Z_DIST);
        
        Anc.TIME = NaN*ones(NT,1);
        Anc.ENU = NaN*ones(NT,NZ,4);
        
        for nn = 1:NT
            nPtsSegment = ind_end(nn) - ind_start(nn) + 1;
            Anc.TIME(nn) = mean(data.L1.TIME(ind_start(nn):ind_end(nn)));
            Anc.ENU(nn,:,:) = nanmean(ENUraw(ind_start(nn):ind_end(nn),:,:),1);
        end
        Anc.Z_DIST = data.L1.Z_DIST;
        
        data.Ancillary = Anc;

    otherwise
        error('Need to define dataset')
end


%% Save data
disp('===== CREATE MAT FILE =====')

fileInfo.data = matFileIn;
fileInfo.infoFile = infoFile;
fileInfo.flagFile = flagFile;
fileInfo.metaFileGroups = metaFileGroups;
fileInfo.metaFileGlobal = metaFileGlobal;

history = get_metadata(mname);

[~,oname]=fileparts(matFileOut);
save(oname,'data','flags','metadataGroups','metadataGlobal','infoProcessing','fileInfo','history','-v7.3');
movefile(strcat(oname,'.mat'),matFileOut)

disp(['Matfile created: ' matFileOut])

