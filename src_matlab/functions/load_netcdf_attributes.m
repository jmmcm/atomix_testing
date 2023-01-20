function [AttGlobal, AttGroup] = load_netcdf_attributes(filename)
% Att = load_netcdf_attributes(filename)
% fetch all global attributes from an NC file to a structure Att. 
% Field % names are the attribute names.
%
% Ilker Fer, 20220512
% 2022-05-31, Justine McMillan: Added extraction of group Attributes
% 2022-06-01, Justine McMillan: Remove leading underscore for global
%   attributes and use try/catch to limit errors


finfo=ncinfo(filename);

%% extract global attributes
for ii=1:length(finfo.Attributes)
    var = finfo.Attributes(ii).Name;
    val = finfo.Attributes(ii).Value;
    if strcmp(var(1),'_');var = var(2:end);end % Remove leading underscore
    try
        AttGlobal.(var)=val;
        clear name val
    catch
        disp(['Could not save:' var])
    end
end

%% extract group (i.e. levels) attributes
%
groups = {finfo.Groups.Name};
for gg = 1:numel(groups)
    group = groups{gg};
    vars = {finfo.Groups(gg).Variables.Name};
    for vv = 1:numel(vars)
        var = vars{vv};        
        atts = {finfo.Groups(gg).Variables(vv).Attributes.Name};
        for aa = 1:numel(atts)
            att = atts{aa};
            val = finfo.Groups(gg).Variables(vv).Attributes(aa).Value;
            if strcmp(att,'_FillValue')
                att = 'FillValue';
            end
            AttGroup.(group).(var).(att) = val;
        end
        clear att val
    end
end; 
