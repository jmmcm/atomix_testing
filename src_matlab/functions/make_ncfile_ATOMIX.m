function fid = make_ncfile_ATOMIX(fieldData,fileInfo, ncFile,timeRef)
%MAKE_NCFILE_ATOMIX Create the netcdf file for ATOMIX data.
%
% Syntax:
%  MAKE_FILE_ATOMIX(fieldData,fileInfo, ncFile)
%
% Inputs:
%  - fieldData: Structure with substructures for each level of data
%  - fileInfo: Structure of variables indicating fileNames for flags and
%              metadata
%       * flagFile: yaml file with flag info
%       * metaFileGlobal: yaml file with global attributes
%       * metaFileGroup: yaml file with group attributes
%  - ncFile: output netcdf filename
%  - timeRef: reference time to use when creating netcdf file 
%       e.g. timeRef=datenum(2013,1,1,0,0,0); The code presumes you supplied TIME variables in matlab datenum format 
%
%
% Justine McMillan
% Apr 8, 2022
% Apr 20, 2022 - Added time ref as an input


%% Flags and metadata
flags = ReadYaml(fileInfo.flagFile);
metaGlobal = ReadYaml(fileInfo.metaFileGlobal,[],1);
metaGroups = ReadYaml(fileInfo.metaFileGroups,[],1);
metaGroups.L1.time_ref = datestr(metaGroups.L1.time_ref,'yyyy-mm-dd HH:MM:SS'); % Hack to convert reference time to string (otherwise, I get error when creating netcdf)


%% Add flags and Metadata to fieldData
vF=fieldnames(flags);
gF=fieldnames(fieldData);
mF=fieldnames(metaGroups);
nGrp=length(gF); % nbre Groups
for ii=1:nGrp
    if any(strcmp(gF{ii},vF))
        fieldData.(gF{ii}).Flags=flags.(gF{ii});
    end
    
    if any(strcmp(gF{ii},mF))
        fieldData.(gF{ii}).Meta=metaGroups.(gF{ii});
    end
   
end

vF=fieldnames(flags);
gF=fieldnames(fieldData);
mF=fieldnames(metaGroups);
nGrp=length(gF); % nbre Groups
for ii=1:nGrp
    if any(strcmp(gF{ii},vF))
        fieldData.(gF{ii}).Flags=flags.(gF{ii});
    end
    
    if any(strcmp(gF{ii},mF))
        fieldData.(gF{ii}).Meta=metaGroups.(gF{ii});
    else
        disp('Data fields')
        disp(gF)
        disp('Meta fields')
        disp(mF)
        error(['Meta data not added to ', gF{ii},'. Ensure data fields and meta fields have the same name.'])
    end
   
end

%%
create_netcdf_fielddata(fieldData,metaGlobal,ncFile,1,timeRef);
disp(['ncFile:' ncFile])
[~,oname]=fileparts(ncFile);
movefile(strcat(oname,'.nc'),ncFile)