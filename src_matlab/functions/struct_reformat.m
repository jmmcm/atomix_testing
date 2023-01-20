function structOut = struct_reformat(structIn)
%% function structOut = struct_reformat(structIn)
% 
% Read structures that have fields 'Name' and 'Value' or 'Name' and
% 'Length' and output a new structure that uses 'Name' as the field name.
% Objective is to improve readability.
%
% Input:
% - structIn: Input structure which has at least two fields ('Name' and
% 'Value' for variables and metadata or 'Name' and 'Length' for dimensions)
%
% Output:
% - structOut: Output structure that has field names being all the 'Name'
% strings from structIn.
%
% Note: If structIn has fields other than 'Value' or 'Length', these will
% get ignored.
%
% Justine McMillan
% Mar 31, 2022


for ii = 1:length(structIn)
    field = structIn(ii).Name;
    
    if field(1) == '_';
        field = field(2:end);
    end
    
    if isfield(structIn(ii),'Value')
        structOut.(field) = structIn(ii).Value;
    elseif isfield(structIn(ii),'Length')
        structOut.(field) = structIn(ii).Length;
    end
end
