function struct_compare(s1,s2)
%% function struct_compare(s1,s2)
%
% Simple function to compare two structures
%
% JMM, 2023-01-10

fields1=fieldnames(s1);
fields2=fieldnames(s2);

fieldsAll=union(fields1,fields2);

disp('=======================')
for ii = 1:length(fieldsAll)
    clear d1 d2
    field = fieldsAll{ii};
    disp(field)
    try 
        d1 = s1.(field);
    catch
        disp([ ' - not in s1'])
    end
    try 
        d2 = s2.(field);
    catch
        disp([ ' - not in s2'])
    end
    
    if exist('d1','var') && exist('d2','var') 
        if isnumeric(d1)
            try 
                diff = abs(d1 - d2);
                maxDiff = max(diff(:));
                if maxDiff == 0
                    disp([ ' - no difference'])
                else
                    cprintf('*blue',[ ' - max difference: ',num2str(maxDiff),'\n'])
                end
            catch
                cprintf('*blue',[ ' - matrices are different sizes \n'])
            end
                
        else
            disp([ ' - not numeric'])
        end
    end
end

