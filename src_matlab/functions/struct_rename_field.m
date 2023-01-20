function structOut = struct_rename_field(structIn, oldField, newField)  
%% function structOut = struct_rename_field(structIn, oldField, newField)  
%
% Renames a field in a structure
%
% Justine McMillan
% Apr 19, 2022 - modified function found on MathWorks

for ss = 1:length(structIn)          
    structIn = setfield(structIn,{ss},newField,getfield(structIn(ss),oldField));                
end
structOut = rmfield(structIn,oldField);
