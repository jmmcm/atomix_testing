function dataStruct = apply_ATOMIX_flags(dataStruct,levelName,varName,flagFile,options)
%% function levelData = apply_ATOMIX_flags(dataStruct,levelName,varName,flagFile)
% 
% Inputs
%  - dataStruct: structure that contains all the data for the level and the
%                flags field
%  - levelName: Name of the level in the flag file
%  - flagFile: Yml file that contains the flag info
%  - varName: variable name to apply flags to (should already be initialized)
%  - options: Structure with optional inputs
%
% Output:
%  - dataStruct: data structure with the flags applied
%
% Justine McMillan, 2022-06-21
% 2022-07-27: Fixed bug so that subsequent flags are now added to each
%             other

% Check inputs
if ~isfield(dataStruct, varName);
    error([varName ' does not exist in the data structure.'])
end
if ~isfield(options,'dispOutput')
    options.dispOutput = 0;
end

% Get initial data and number of values (for computing percentages)
varData0 = dataStruct.(varName);
numValues = numel(varData0);

% Get structure with flag info
flagInfo = get_flag_info(flagFile,levelName,varName,'',struct());

%% Apply flags
for ff = 1:length(flagInfo.flag_masks)
    
    % Define simple variables
    flagMeaning = flagInfo.flag_meanings{ff};
    mask = flagInfo.flag_masks(ff);
    threshold = flagInfo.flag_thresholds(ff);
    thresholdMeaning = flagInfo.flag_threshold_meanings{ff};
    
    % Get indices for flags
    if strcmp(varName,'R_VEL_FLAGS')
        switch flagMeaning
            case 'unknown' % Will be applied at the end
                maskUnknown = mask;
                continue
            case 'low_amplitude'
                ind = find(dataStruct.ABSI<threshold);
            case 'high_amplitude'
                ind = find(dataStruct.ABSI>threshold);
            case 'low_correlation'
                ind = find(dataStruct.CORR<threshold);
            case 'large_obstruction' % Not implemented in GP data
                continue
            case 'velocity_out_of_range'
                ind = find(dataStruct.R_VEL>threshold);
            case 'tilt_out_of_range'
                ind = find(dataStruct.PITCH>threshold | dataStruct.ROLL>threshold);
            case 'out_of_water_or_missing' 
                fieldIn = zeros(length(dataStruct.TIME),length(dataStruct.Z_DIST));
                [fieldOut, ~] = nan_AboveSurf(fieldIn,dataStruct.Z_DIST,dataStruct.PRES,threshold);
                nanMat = isnan(fieldOut); % ones where out of water, zeros elsewhere
                nanMat = repmat(nanMat,1,1,length(dataStruct.N_BEAM)); % Make the same size as R_VEL
                ind = find(nanMat);     
        end
    elseif strcmp(varName,'DLL_FLAGS')
        switch flagMeaning
            case 'unknown' % Will be applied at the end
                maskUnknown = mask;
                continue
            case 'insufficient_number_velocity_samples'
                ind = find((dataStruct.DLL_N_ratio < threshold) | (isnan(dataStruct.DLL_N_ratio)));
            case 'too_close_to_range_limits'
                NZ = length(dataStruct.Z_DIST);
                indZ = [1:1:threshold-1, NZ-threshold+2:1:NZ];
                nanMat = zeros(size(dataStruct.DLL));
                nanMat(:,indZ,:,:) = 1;
                ind = find(nanMat);
            case 'non_existent_bin_pair'
                ind = find((isnan(dataStruct.BIN_L)) | (isnan(dataStruct.BIN_U)));
        end
    elseif strcmp(varName,'EPSI_FLAGS')
        switch flagMeaning
            case 'unknown' % Will be applied at the end
                maskUnknown = mask;
                continue
            case 'Rsquared_too_low'
                 ind = find(dataStruct.REGRESSION_R2 < threshold);
            case 'delta_epsi_too_large'
                ind = find(dataStruct.EPSI_DEL_RATIO > threshold);
            case 'A3_coeff_invalid'
                if ~isfield(dataStruct,'REGRESSION_COEFF_A3')
                    ind = [];
                else
                    ind = find(dataStruct.REGRESSION_COEFF_A3 < threshold);
                end
            case 'dll_intercept_too_low'
                ind = find(dataStruct.REGRESSION_COEFF_A0 < threshold);
            case 'dll_intercept_too_high'
                ind = find(dataStruct.REGRESSION_COEFF_A0 > threshold);
            case 'regression_poorly_conditioned'
                ind = find(dataStruct.REGRESSION_N < threshold);
            case 'dll_slope_out_of_range'
                ind = find(dataStruct.REGRESSION_COEFF_A1 < threshold);
            otherwise
                disp(['Not configured for flag: ',flagMeaning])
                continue
        end
        
    end
    
    % Apply flag masks
    dataStruct.(varName)(ind) = dataStruct.(varName)(ind) + mask;
    
    % Display Output
    if options.dispOutput
        disp_flag_summary(flagMeaning, mask, threshold, thresholdMeaning,length(ind)/numValues*100)
    end
    clear ind 
     
end

% Apply unknown flags to any other Nan values 
if strcmp(varName,'R_VEL_FLAGS')
    indUnknown = find(isnan(dataStruct.R_VEL) & dataStruct.R_VEL_FLAGS== 0 );
elseif strcmp(varName,'DLL_FLAGS')
    indUnknown = find(isnan(dataStruct.DLL) & dataStruct.DLL_FLAGS== 0 );
elseif strcmp(varName,'EPSI_FLAGS')
    indUnknown = find(isnan(dataStruct.EPSI) & dataStruct.EPSI_FLAGS == 0 );
end
dataStruct.(varName)(indUnknown) = dataStruct.(varName)(indUnknown) + maskUnknown;
if options.dispOutput
    disp_flag_summary('unknown', maskUnknown, '', '',length(indUnknown)/numValues*100)
end
    
end % apply_ATOMIX_flags

%% 
function disp_flag_summary(flagMeaning, mask, threshold, thresholdMeaning,percFlags)
    if strcmp(flagMeaning,'unknown')
        disp(['Flag = ',num2str(mask),': ',num2str(percFlags),'% additional values for unknown reason'])
    else
        disp(['Flag = ',num2str(mask),': ',num2str(percFlags),'% of values for ',flagMeaning,...
                ' (', thresholdMeaning,' of ' num2str(threshold),')'])
    end
end
