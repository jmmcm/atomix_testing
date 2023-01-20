%% Calculate the along beam velocity frequency spectra
% Used to confirm presence of inertial subrange and ultimately determine
% what rMax should be. See plots_spectra.m for the plots of the resulting
% data.
%
% Justine McMillan
% Oct 20, 2022
% Nov 24, 2022 -- Moved plots to a different function

clear all
close all
mname = mfilename('fullpath');

%dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
% dataSet = 'Signature5beam_TidalShelf';
processID = 'JMM01'; % Always use my processed file because it will have ancillary data and correct format

%% datafiles
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
dataFile =  [dataDir,dataFileRoot,'_',processID,'.mat'];
saveFile = [dataDir,dataFileRoot,'_spectra.mat'];


%% Load data
load(dataFile);
L2 = data.L2;
try
    Anc = data.Ancillary;
end

%% Load metadata to get options

metaFileGroups = [metaDir,processID,'/',dataSet,'_groups.yml'];
metadataGroups = ReadYaml(metaFileGroups);

spectraOpts.overlap = metadataGroups.spectra.overlap/100;
spectraOpts.nfft = metadataGroups.spectra.nfft;

%% Sizes
NT = length(L2.N_SEGMENT);
NZ = length(L2.Z_DIST);
NB = length(L2.N_BEAM);
NS = length(L2.N_SAMPLE);

%% Initialize
fs = 1/(nanmean(diff(L2.TIME(1,:)))*24*3600); % Assumes all bursts are the same sampling
NF = spectraOpts.nfft/2+1;
Sxx = NaN*ones(NT,NZ,NB,NF);
%% Calculate spectra
warning off
for tt = 1:NT
    tt
    for bb = 1:NB
        
        time = L2.TIME(tt,:);
        field = squeeze(L2.R_VEL_DETRENDED(tt,:,bb,:));
        
        fieldI = NaN*field;
        for zz=1:NZ
            if length(find(isnan(field(zz,:)))) < 0.5*NS
                fieldI(zz,:) = naninterp(field(zz,:));
            end
        end
        
        
        [SxxTmp,freq,varTS,varSPEC,varSPEC_sum] = calc_spectra_checkvar(fieldI,fs,spectraOpts);
        Sxx(tt,:,bb,:) = SxxTmp';
    end
end
warning on

%% Save
metadata = get_metadata(mname);
save(saveFile,'Sxx','freq','metadata')



