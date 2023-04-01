function [binL,binU] = get_binL_binU(bins,deltas,dll_method)

NZ = length(bins);
NR = length(deltas);
binL = NaN*ones(NZ,NR);
binU = NaN*ones(NZ,NR);

if strcmp(dll_method,'forward')
    for zz = 1:NZ
        binL(zz,:) = zz;

        binUtmp = zz+deltas;
        ind = find(binUtmp<=bins(end));
        binU(zz,1:length(ind)) = binUtmp(ind);
    end
end