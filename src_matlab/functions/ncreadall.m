function data = ncreadall(source)
% function data = ncreadall(source)
%
% BDS
% March 2022
% Mar 31, 2022 (JMM): Used 'struct_reformat' function to create output
%                     strucures that are easier to read and use in code.  
%                     Particularly useful for metadata and attributes
%
%% read file info
finfo = ncinfo(source);

%% extract meta data
%
data.Meta = struct_reformat(finfo.Attributes);
%
%% extract variable data
%
lvls = {finfo.Groups.Name};
for i1 = 1:numel(lvls)
    lvl = lvls{i1};
    data.(lvl).Meta = struct_reformat(finfo.Groups(i1).Attributes);
    vars = {finfo.Groups(i1).Variables.Name};
    for i2 = 1:numel(vars)
        var = vars{i2};
        data.(lvl).(var).Values = ncread(source,['/',lvl,'/',var]);
        if ~isempty(finfo.Groups(i1).Variables(i2).Dimensions)
            data.(lvl).(var).Dimensions = struct_reformat(finfo.Groups(i1).Variables(i2).Dimensions);
        else
            data.(lvl).(var).Dimensions = '';
        end
        data.(lvl).(var).Attributes = struct_reformat(finfo.Groups(i1).Variables(i2).Attributes);
        clear var
    end; clear i2
    clear lvl vars
end; clear i1
clear lvls finfo