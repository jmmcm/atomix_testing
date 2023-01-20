function structOut = orderfields_dim_first(structIn,dimensionNames)
%% function structOut = orderfields_dim_first(structIn,dimensionNames)
%
% Reorder the fields in a structure with the dimensions first and then
% alphabetical thereafter
%
% Justine McMillan
% June 20, 2022

fieldsAll = sort(fieldnames(structIn));

indDim = NaN*ones(length(dimensionNames),1);
for ff = 1:length(dimensionNames)
    indDim(ff) = find(ismember(fieldsAll, dimensionNames(ff)));
end
indVar = find(~ismember(fieldsAll, dimensionNames));

structOut = orderfields(structIn,fieldsAll([indDim;indVar]));