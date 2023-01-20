function [structData,structMeta] = struct_split_data_meta(structIn)

structData = struct();
structMeta = struct();

fields = fieldnames(structIn);
for ff = 1:length(fields)
    field = fields{ff};
    if strcmp(field,'Meta')
        structMeta.Group = structIn.Meta;
    else
        structData.(field) = structIn.(field).Values;
        structMeta.(field).Dimensions = structIn.(field).Dimensions;
        structMeta.(field).Attributes = structIn.(field).Attributes;
    end
end

structData = orderfields(structData);