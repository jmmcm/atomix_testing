%%
% Prepare provided file for comparisons. Only relevant if provided file
% includes all levels and not just level 1.
%
% Justine McMillan
% Oct 21, 2022

clear
close all
addpath('functions')
addpath(genpath('../../adcp_toolbox/'))
addpath(genpath('../../utilitieswork/'))
addpath(genpath('../../netcdftools_ceb/'))
mname = mfilename('fullpath');

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'dJMM_M2uC_RM5'; % Method 2.1 differencing, standard regression (dJMM downloaded data, hack to distinguish downloaded and processed metadata folders)
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M1aC_RM7p5'; % Method 1 differencing, canonical regression
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M1aA_RM7p5'; % Method 1 differencing, modified regression
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M2uC_RM7p5'; % Method 2.1 differencing, standard regression
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M1aC_RM1p5'; % Labelled A1S (Mean deducted, Method 1 differencing, standard regression)
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M1aA_RM1p5'; % Labelled A1M (Mean deducted, Method 1 differencing, modified regression)
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M2uC_RM1p5'; % Labelled A2S (Mean deducted, Method 2 differencing, standard regression)
% dataSet = 'Signature5beam_TidalShelf'; processID = 'CEB'; % Only L1 data
% dataSet = 'AQD_Windermere_bedframe'; processID = 'BDS_M1aA_RM2'; % Method 1 differencing, modified regression
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; processID = 'NSL'; % Only L1 data
% dataSet = 'NortekSig1000_TidalChannel_2018_Burst'; processID = 'NSL_CEB'; % Only L1 data
dataSet = 'AQD_NorthSea_bedframe'; processID = 'CEB'; % Method 1 differencing, modified regression

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
infoProcessing = ReadYaml(infoFile);



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
        data.Ancillary.ENU = cat(3,data.Ancillary.EVEL_E, data.Ancillary.EVEL_N, data.Ancillary.EVEL_U, data.Ancillary.EVEL_ERR);
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
        
    case 'AQD_Windermere_bedframe'
        data.L1 = d.data.L1;
        data.Ancillary = d.data.Ancillary;
        switch processID
            case 'BDS_M1aA_RM2' % A1M: Mean removed, Method 1 differencing, modified regression
                data.L2 = d.data.L2;
                data.L3 = d.data.L3_M1;
                data.L4 = d.data.L4_M1A;
            otherwise
                error(['Need to define ',processID])
        end
        data.L1.PRES = data.L1.DEPTH;
        
        data.Ancillary = d.data.Ancillary;
        
        % ENU only at one depth in input file? (TODO: Calculate myself using beam velocities)
%         ENU = nanmean(data.Ancillary.ENU,3);
%         data.Ancillary.ENU = NaN*ones(length(data.Ancillary.TIME),length(data.L1.Z_DIST),3);
%         data.Ancillary.ENU(:,:,1) = ENU(1,:)'*ones(1,length(data.L1.Z_DIST));
%         data.Ancillary.ENU(:,:,2) = ENU(2,:)'*ones(1,length(data.L1.Z_DIST));
%         data.Ancillary.ENU(:,:,3) = ENU(3,:)'*ones(1,length(data.L1.Z_DIST));
        v1 = squeeze(data.L1.R_VEL(:,:,1));
        v2 = squeeze(data.L1.R_VEL(:,:,2));
        v3 = squeeze(data.L1.R_VEL(:,:,3));
        [vX,vY,vZ] = Aquadopp_beam2xyz(v1,v2,v3);
        
        [vE,vN,vU] = Aquadopp_xyz2enu(vX,vY,vZ,data.L1.HEADING,data.L1.PITCH,data.L1.ROLL);
        ENU = NaN*ones(204,44,3,1024);
        for tt = 1:204
            indTbeg = (tt-1)*1024+1;
            indTend = tt*1024;
            ENU(tt,:,1,:) = vE(indTbeg:indTend,:)'; 
            ENU(tt,:,2,:) = vN(indTbeg:indTend,:)';
            ENU(tt,:,3,:) = vU(indTbeg:indTend,:)';
        end
        data.Ancillary.ENU = mean(ENU,4,'omitnan');
        
        % speed and direction
        data.Ancillary.DIR = get_DirFromN(data.Ancillary.ENU(:,:,1),data.Ancillary.ENU(:,:,2));
        data.Ancillary.SPD = sqrt(data.Ancillary.ENU(:,:,1).^2+data.Ancillary.ENU(:,:,2).^2);
        
    case 'Signature5beam_TidalShelf' % Didn't use data
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
        
    case 'NortekSig1000_TidalChannel_2019_Burst'
        data.L1 = rmfield(d,'Config');
        data.L1 = rmfield(data.L1,{'ERR5','HEADING5','PITCH5','ROLL5','TIME5'});
        data.L1.THETA = [data.L1.THETA data.L1.THETA data.L1.THETA data.L1.THETA 0]';
        data.L1.N_BEAM = [1 2 3 4 5]';
        data.L1.BIN_SIZE = data.L1.BIN_SIZE*[1 1 1 1 1]';
        data.L1.TIME = datenum(data.L1.TIME);
        data.L1.Z_DIST = data.L1.Z_DIST';
        data.L1.R_VEL_FLAGS = 0*data.L1.R_VEL;
        
        % Flag above surface (Simplest QC)
        fieldIn = zeros(length(data.L1.TIME),length(data.L1.Z_DIST));
        [fieldOut, ~] = nan_AboveSurf(fieldIn,data.L1.Z_DIST,data.L1.PRES,0.65); %See sandbox file for determining these ratios
        [fieldOut5, ~] = nan_AboveSurf(fieldIn,data.L1.Z_DIST,data.L1.PRES,0.70);
        nanMask =isnan(fieldOut);
        nanMask5=isnan(fieldOut5);
        
        data.L1.R_VEL_FLAGS(:,:,1) = data.L1.R_VEL_FLAGS(:,:,1)+32*nanMask;
        data.L1.R_VEL_FLAGS(:,:,2) = data.L1.R_VEL_FLAGS(:,:,2)+32*nanMask;
        data.L1.R_VEL_FLAGS(:,:,3) = data.L1.R_VEL_FLAGS(:,:,3)+32*nanMask;
        data.L1.R_VEL_FLAGS(:,:,4) = data.L1.R_VEL_FLAGS(:,:,4)+32*nanMask;
        data.L1.R_VEL_FLAGS(:,:,5) = data.L1.R_VEL_FLAGS(:,:,5)+32*nanMask5; % 32 = flag value for out of water
        
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
        
        % speed and direction
        Anc.DIR = get_DirFromN(Anc.ENU(:,:,1),Anc.ENU(:,:,2));
        Anc.SPD = sqrt(Anc.ENU(:,:,1).^2+Anc.ENU(:,:,2).^2);
        
        data.Ancillary = Anc;
        
    case 'NortekSig1000_TidalChannel_2018_Burst' % Didn't use data (only three bursts)
        data.L1 = data.Level1_raw;
        data.L1.BIN_SIZE = data.L1.BIN_SIZE*[1 1 1 1 1]';
        data.L1.TIME = datenum(data.L1.TIME);
        
        % Flag above surface
        fieldIn = zeros(length(data.L1.TIME),length(data.L1.Z_DIST));
        [fieldOut, ~] = nan_AboveSurf(fieldIn,data.L1.Z_DIST,data.L1.PRES,0.72);
        nanMat = isnan(fieldOut); % ones where out of water, zeros elsewhere
        nanMat = repmat(nanMat,1,1,length(data.L1.N_BEAM)); % Make the same size as R_VEL
        ind = find(nanMat);
        data.L1.R_VEL_FLAGS(ind) = data.L1.R_VEL_FLAGS(ind)+32; % TODO: Move this and other QC to flag file
        
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
        
        % speed and direction
        Anc.DIR = get_DirFromN(Anc.ENU(:,:,1),Anc.ENU(:,:,2));
        Anc.SPD = sqrt(Anc.ENU(:,:,1).^2+Anc.ENU(:,:,2).^2);
        
        data.Ancillary = Anc;
    
    case 'AQD_NorthSea_bedframe'
        data.L1 = d.NetData;
        data.L1.THETA = data.L1.THETA';
        data.L1.N_BEAM = data.L1.N_BEAM';
        
        % Remove upper bins (data look bad) and out of water times
        binMax = 34;
        indT = find(d.NetData.TIME > datenum(2009,8,9,12,14,0) & d.NetData.TIME < datenum(2009,8,10,17,29,0));
        data.L1.TIME = d.NetData.TIME(indT);
        data.L1.Z_DIST = d.NetData.Z_DIST(1:binMax);
        data.L1.R_DIST = d.NetData.R_DIST(1:binMax);
        data.L1.THETA = d.NetData.THETA';
        data.L1.N_BEAM = d.NetData.N_BEAM';
        data.L1.PRES = d.NetData.PRES(indT);
        data.L1.TEMP = d.NetData.TEMP(indT);
        data.L1.HEADING = d.NetData.HEADING(indT);
        data.L1.PITCH = d.NetData.PITCH(indT);
        data.L1.ROLL = d.NetData.ROLL(indT);
        data.L1.ABSIC = d.NetData.ABSIC(indT,1:binMax,:);
        data.L1.CORR = d.NetData.CORR(indT,1:binMax,:);
        data.L1.XYZ_VEL = zeros(length(indT),length(data.L1.Z_DIST),3);
        data.L1.XYZ_VEL_WRAPPED = d.NetData.XYZ_VEL(indT,1:binMax,:);
        data.L1.XYZ_VEL_FLAGS = d.NetData.XYZ_VEL_FLAGS(indT,1:binMax,:);
        data.L1.R_VEL = NaN*ones(size(data.L1.XYZ_VEL));
        data.L1.R_VEL_WRAPPED = zeros(length(indT),length(data.L1.Z_DIST),3);
        data.L1.R_VEL_FLAGS = NaN*ones(size(data.L1.XYZ_VEL));
        data.L1.ENU = NaN*ones(size(data.L1.XYZ_VEL));
        
        % Sizes
        NBURST = length(data.L1.TIME)/2048;
        NZ = length(data.L1.Z_DIST);
        
        % Get Beam velocities (don't apply flags because don't want data gaps for unwrapping)
        disp(' == Convert to beam coordinates == ')
        for zz = 1:NZ
            disp(['bin: ' num2str(zz)])
            [data.L1.R_VEL_WRAPPED(:,zz,:), ~]=transformADV(squeeze(data.L1.XYZ_VEL_WRAPPED(:,zz,:)),d.hdr,...
                data.L1.HEADING,data.L1.PITCH,data.L1.ROLL,d.statusbit);
        end
        
        % Unwrapping options
        vAmb = (-min(data.L1.R_VEL_WRAPPED(:))+max(data.L1.R_VEL_WRAPPED(:)))/2; % Ambiguity velocity
        tFilt = 30; %[seconds] Length of moving median filter
        freq = 8; % Sampling rate of instrument
        binRef = 30; % Reference bin for second unwrapping stage
        
        % Unwrap each burst separately
        disp('Unwrapping')
        R_VEL_WRAPPED = data.L1.R_VEL_WRAPPED;
        R_VEL_UNWRAPPED = zeros(size(R_VEL_WRAPPED));
        for tt = 1:NBURST
            disp(['tt = ' num2str(tt)])

            indTbeg = (tt-1)*2048+1;
            indTend = tt*2048;
            indT = indTbeg:indTend;

            % Unwrap
            options.vAmb = vAmb;
            options.binRef = 30;
            R_VEL_UNWRAPPED(indT,:,:) = unwrap_nortek_aquadopp(R_VEL_WRAPPED(indT,:,:),tFilt*freq,options);

%             pause
        end 
        data.L1.R_VEL = R_VEL_UNWRAPPED;
        
        % Create mask
        % HACK: Additional flags for bad looking data
        indTbad = 32*2048+1:33*2048; % burst = 33
        data.L1.XYZ_VEL_FLAGS(indTbad,:,:) = 256; 
        indZbad = [18,19,22]; % Bad for beams 2 and 3 (worse for 2)
        data.L1.XYZ_VEL_FLAGS(:,indZbad,2:3) = 256; 
        
        data.L1.R_VEL_FLAGS = data.L1.XYZ_VEL_FLAGS; % TODO: Not quite right, but works for now.
        nanMask = ones(size(data.L1.XYZ_VEL));
        nanMask(data.L1.XYZ_VEL_FLAGS>0) = NaN;
        
        R_VEL_FLAGGED = R_VEL_UNWRAPPED.*nanMask;
        
        % Compute XYZ velocities and ENU velocities
        d2 = d;
        d2.hdr.coord = 'BEAM';
        for zz = 1:NZ
            disp(['bin: ' num2str(zz)])
            [data.L1.XYZ_VEL(:,zz,:), data.L1.ENU(:,zz,:)]=transformADV(squeeze(R_VEL_FLAGGED(:,zz,:)),d2.hdr,...
                data.L1.HEADING,data.L1.PITCH,data.L1.ROLL,d2.statusbit);
        end
        
        % Average ENU 
        disp(' == Calculate average to ENU == ')
        
        ENU = NaN*ones(NBURST,binMax,3,2048);
        XYZ = NaN*ones(NBURST,binMax,3,2048);
        TIME = NaN*ones(NBURST,2048);
        for tt = 1:NBURST
            indTbeg = (tt-1)*2048+1;
            indTend = tt*2048;
            ENU(tt,:,1,:) = data.L1.ENU(indTbeg:indTend,:,1)'; 
            ENU(tt,:,2,:) = data.L1.ENU(indTbeg:indTend,:,2)';
            ENU(tt,:,3,:) = data.L1.ENU(indTbeg:indTend,:,3)';
            XYZ(tt,:,1,:) = data.L1.XYZ_VEL(indTbeg:indTend,:,1)'; 
            XYZ(tt,:,2,:) = data.L1.XYZ_VEL(indTbeg:indTend,:,2)';
            XYZ(tt,:,3,:) = data.L1.XYZ_VEL(indTbeg:indTend,:,3)';
            TIME(tt,:) = data.L1.TIME(indTbeg:indTend);
        end
        data.Ancillary.ENU = mean(ENU,4,'omitnan');
        data.Ancillary.XYZ = mean(XYZ,4,'omitnan');
        data.Ancillary.TIME = mean(TIME,2);
        
        numNans = sum(isnan(ENU),4);
        data.Ancillary.ENU(find(numNans>1500)) = NaN;
        
        numNans = sum(isnan(XYZ),4);
        data.Ancillary.XYZ(find(numNans>1500)) = NaN;
        
        % speed and direction
        data.Ancillary.DIR = get_DirFromN(data.Ancillary.ENU(:,:,1),data.Ancillary.ENU(:,:,2));
        data.Ancillary.SPD = sqrt(data.Ancillary.ENU(:,:,1).^2+data.Ancillary.ENU(:,:,2).^2);
        data.Ancillary.Z_DIST = data.L1.Z_DIST;
        
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

% [~,oname]=fileparts(matFileOut);
save(matFileOut,'data','flags','metadataGroups','metadataGlobal','infoProcessing','fileInfo','history','-v7.3');
% movefile(strcat(oname,'.mat'),matFileOut)

disp(['Matfile created: ' matFileOut])

