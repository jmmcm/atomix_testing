function disp_flags(flagVal,flagFileInfo)
% Display individual flags for a certain value and show meaning based on
% yml file.
%
% Inputs:
% - flagVal: Total numeric value of the flag
% - flagFileInfo: Structure with relevant information for the yml file with
%                   flag info
%     Fields:
%       * fileName: name of the yml file (e.g. 'GP130620BPb_atomix_flags.yml')
%       * levelName: name of the level (i.e. group) that contains the
%                    desired variable
%       * varName: Name of the variable that contains the flags
%
% Example Usage:
% > disp_flags(112,struct('fileName','GP130620BPb_atomix_flags.yml','levelName','Level4','varName','EPSI_FLAGS'))
%
% Justine McMillan
% Feb 18, 2022
% Mar 9, 2022 - Updated to get flag meaning from yml file


if isempty(flagFileInfo)
    disp('No flag file')
else
    flagInfo = get_flag_info(flagFileInfo.fileName,flagFileInfo.levelName,flagFileInfo.varName,[],struct()); 
end

flagStr = dec2base(flagVal,2);
L = length(flagStr);


header = ['Total Flag Value: ',num2str(flagVal), ' (',flagStr, ')'];
disp(header)
for ii = 1:length(flagStr)
    N = L-ii; % Exponent
    flagVal = 2^N;
    
    if isempty(flagFileInfo)
        flagMeaning = '';
    else
        ind = find(flagInfo.flag_masks == flagVal);
        flagMeaning = [', ' flagInfo.flag_meanings{ind}];
    end
    if flagStr(ii) == '1'
        disp(['Flag: ', num2str(flagVal),flagMeaning])
    end
end


    
    
