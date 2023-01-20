function flagsClean = get_flag_struct_clean(flags,options)
% Function to convert flags from output of ReadYaml to nicer structure
% Inputs:
%  - flags: Structure output from flags = ReadYaml(flagFile) that contains 
%           a substructure for each level, and then another substructure
%           for each flags variable. This subsubstructure contains:
%               * flag_masks
%               * flag_meanings
%               * flag_thresholds
%               * flag_threshold_meanings
%  - options: Structure with options
%
% Output:
%  - flagsClean: Structure with a substructure for each level, and then 
%                another substructure for each flags variable, and then
%                another for each flag_meaning which contains the fields:
%                   * mask (i.e. value)
%                   * threshold
%                   * threshold_meaning
%           e.g. flagStruct.L1.R_VEL_FLAGS.low_amplitude.mask = 2
%                flagStruct.L1.R_VEL_FLAGS.low_amplitude.threshold = 70
%                flagStruct.L1.R_VEL_FLAGS.low_amplitude.threshold_meaning = 'excluded_if_value_below_threshold
%
% 
%
% Justine McMillan
% Jul 5, 2022

% Check inputs
if ~isfield(options,'dispOutput')
    options.dispOutput = 0;
end

% Get levels
levels = fieldnames(flags);

for ll = 1:length(levels)
    levelName = levels{ll};
    
    varNames = fieldnames(flags.(levels{ll}));
    ind = ~isempty(strfind(varNames,'FLAGS'));
    varNames = varNames(ind);
    
    
    
    for vv = 1:length(varNames)
        var = varNames{vv};

        if options.dispOutput
            disp('-----------------------')
            disp([levelName, ' - ',var])
            disp('-----------------------')
        end

        % Flag info for level and variable
        flagInfo = flags.(levels{ll}).(var);
        
        %Convert text fields into cells
        flagInfo.flag_meanings = strsplit(flagInfo.flag_meanings);
        flagInfo.flag_threshold_meanings = strsplit(flagInfo.flag_threshold_meanings);
        
        % Create substructure for each flag
        for ff = 1:length(flagInfo.flag_meanings)
            meaning = flagInfo.flag_meanings{ff};
            flagsClean.(levelName).(var).(meaning).mask              = flagInfo.flag_masks(ff);
            flagsClean.(levelName).(var).(meaning).threshold         = flagInfo.flag_thresholds(ff);
            flagsClean.(levelName).(var).(meaning).threshold_meaning = flagInfo.flag_threshold_meanings{ff};
            
            if options.dispOutput
                disp(['* ',meaning,' *'])
                disp(flagsClean.(levelName).(var).(meaning))
%                  disp(['  ', num2str(flagsClean.(levelName).(var).(meaning).mask,'%3d') ': ' ...
%                    meaning ' ' ...
%                    flagsClean.(levelName).(var).(meaning).threshold_meaning ' '...
%                    num2str(flagsClean.(levelName).(var).(meaning).threshold)])
            end
        
        end
    end
%     % Load all flag info into structure
%     try
%         flagInfo = flags.(levels{ll}).(varName);
% 
%         % Convert text fields into cells
%         flagInfo.flag_meanings = strsplit(flagInfo.flag_meanings);
%         flagInfo.flag_threshold_meanings = strsplit(flagInfo.flag_threshold_meanings);
% 
%         % Remove name
%         flagInfo = rmfield(flagInfo,'standard_name');
%     catch
%         if ~isempty(varName)
%             disp([varName ' does not exist for this level.'])
%         end    
%         disp('Flag variables are:')
%         fields = fieldnames(flags.(fields{indLevel}));
%         ind = ~isempty(strfind(fields,'FLAGS'));
%         disp(fields(ind))
%         return
%     end
% 
%     if isempty(flagMeaning)
%         disp(['Returning all ',varName,' info from ',flagFile])
% 
%         % Display Flags
%         if options.dispOutput
%             for ff = 1:length(flagInfo.flag_masks)
%                 disp([num2str(flagInfo.flag_masks(ff)) ' ' ...
%                       flagInfo.flag_meanings{ff} ' ' ...
%                       flagInfo.flag_threshold_meanings{ff} ' '...
%                       num2str(flagInfo.flag_thresholds(ff))])
%             end
%         end
%     else
%         % Find matching meaning
%         ind = find(strcmp(flagInfo.flag_meanings,flagMeaning));
%         if isempty(ind)
%             disp([flagMeaning ' does not exist for this variable. Options are:'])
%             disp((flagInfo.flag_meanings(:)))
%             disp('Returning empty structure')
%             flagInfo = struct();
%             return
%         end
%         flagInfo.flag_meanings = flagInfo.flag_meanings{ind};
%         flagInfo.flag_masks = flagInfo.flag_masks(ind);
%         flagInfo.flag_thresholds = flagInfo.flag_thresholds(ind);
%         flagInfo.flag_threshold_meanings = flagInfo.flag_threshold_meanings{ind};
%     end
end


