function flagInfo = get_flag_info(flagFile,levelName,varName,flagMeaning,options)
% Function to extract flag info from yml file
% Inputs:
%  - flagFile: full file name of the yml file where flags are defined
%  - levelName: Level of the variable (only need start of name, eg. 'Level1')
%  - varName: Name of the variable with the flags
%  - flagMeaning: Flag meaning to get info for. If empty all flags for
%      level and var will be returned
%  - options: Structure with optional inputs
%
% Output:
%  - flagInfo: Structure with information about the flag
%
% Example Usage:
%  flagFile = 'GP130620BPb_atomix_flags.yml';
%  levelName = 'Level4';
%  varName = 'EPSI_FLAGS';
%  flagMeaning = 'dll_intercept_out_of_range'; 
%  options = struct('dispOutput',1);
%  flagInfo = get_flag_info(flagFile,levelName,varName,flagMeaning,options);
%
% Justine McMillan
% Mar 9, 2022

% Check inputs
if ~isfield(options,'dispOutput')
    options.dispOutput = 0;
end
% Initialize
flagInfo = struct();

% Get Flags
flags = ReadYaml(flagFile);

% Get desired level
fields = fieldnames(flags);
indLevel = find(~cellfun(@isempty,strfind(fields,levelName)));
if isempty(indLevel)
    disp([levelName ' does not exist. Options are:'])
    disp(fields)
    return
end

% Load all flag info into structure
try
    flagInfo = flags.(fields{indLevel}).(varName);
    
    % Convert text fields into cells
    flagInfo.flag_meanings = strsplit(flagInfo.flag_meanings);
    flagInfo.flag_threshold_meanings = strsplit(flagInfo.flag_threshold_meanings);
    
    % Remove name
    flagInfo = rmfield(flagInfo,'standard_name');
catch
    if ~isempty(varName)
        disp([varName ' does not exist for this level.'])
    end    
    disp('Flag variables are:')
    fields = fieldnames(flags.(fields{indLevel}));
    ind = ~isempty(strfind(fields,'FLAGS'));
    disp(fields(ind))
    return
end

if isempty(flagMeaning)
    disp(['Returning all ',varName,' info from ',flagFile])
    
    % Display Flags
    if options.dispOutput
        for ff = 1:length(flagInfo.flag_masks)
            disp([num2str(flagInfo.flag_masks(ff)) ' ' ...
                  flagInfo.flag_meanings{ff} ' ' ...
                  flagInfo.flag_threshold_meanings{ff} ' '...
                  num2str(flagInfo.flag_thresholds(ff))])
        end
    end
else
    % Find matching meaning
    ind = find(strcmp(flagInfo.flag_meanings,flagMeaning));
    if isempty(ind)
        disp([flagMeaning ' does not exist for this variable. Options are:'])
        disp((flagInfo.flag_meanings(:)))
        disp('Returning empty structure')
        flagInfo = struct();
        return
    end
    flagInfo.flag_meanings = flagInfo.flag_meanings{ind};
    flagInfo.flag_masks = flagInfo.flag_masks(ind);
    flagInfo.flag_thresholds = flagInfo.flag_thresholds(ind);
    flagInfo.flag_threshold_meanings = flagInfo.flag_threshold_meanings{ind};
end


