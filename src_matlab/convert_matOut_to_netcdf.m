%% Converts a matlab file to an ATOMIX netcdf file
% Should be run after calc_all_levels.m
%
% Justine McMillan
% July 4, 2022

clear all
close all

dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
%dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
%dataFileRoot = 'RDI4beam_TidalChannel_GP130620BPb_JMM_20220708';
testNum = '02';


%% filenames
dataDir = ['D:/ATOMIX/Data/', dataSet,'/'];
switch dataSet
    case 'RDI4beam_TidalChannel_GP130620BPb'
       dataFileRoot = 'RDI4beam_TidalChannel_GP130620BPb_JMM_20220708';
    case 'RDIWH600_CANDYFLOSS_bedframe'
       dataFileRoot = 'RDIWH600_CANDYFLOSS_bedframe';
        
    otherwise
        error('Data set not recognized')
end 
matFile = [dataDir,dataFileRoot,'_TestJMM',testNum,'.mat'];
ncFile = [dataDir,dataFileRoot,'_TestJMM',testNum,'.nc'];

%% load data
load(matFile)

timeRef = datenum(metadataGroups.L1.time_ref);
%% Create Netcdf file
disp('===== CREATE NETCDF =====')

try 
   % create file
    make_ncfile_ATOMIX(data, fileInfo,ncFile,timeRef)  
catch
    [~,oname]=fileparts(ncFile);
    if exist(strcat(oname,'.nc'),'file')>0
        delete(strcat(oname,'.nc'))
    end
    warning('Could not create netcdf')
end
disp('===== CREATE NETCDF (end) =====')