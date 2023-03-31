function [rDelUnq,DllAvg] = get_DLL_averages(rDel,Dll)
%
%
% Outputs:
% - rDelAvg : unique r values
% - DllAvg : Average Dll for each r

ind = find(~isnan(rDel));
rDelUnq = unique(rDel(ind));
nPts = length(rDelUnq);
if nPts > 0
    DllAvg = NaN*ones(1,nPts);
    
    for rr = 1:length(rDelUnq)
        indR = find(rDel == rDelUnq(rr));
        DllAvg(rr) = mean(Dll(indR));
    end
    
else
    error('get_DLL_averages: No unique points')
end