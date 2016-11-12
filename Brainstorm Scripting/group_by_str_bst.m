%% group_by_string_bst(FileNames, SubjectNames);
% this function group a cell containing file names in a cell cotanining
% several cells in which file names (i.e., data in Brainstorm) are separated
% according to a string.
% It can be used to group by Subject (using a string identifying Subject names)
% or the Run (using a string identifying run name).



function sGroupByStr = group_by_str_bst(FileNames, Strings);

sGroupByStr = {};
for istr=1:length(Strings); % NOTE! 2 because the first subject is intra subject.
    
    curr_str=Strings{istr};
    curr_sFiles=sel_files_bst(FileNames, curr_str);
    
    sGroupByStr{istr}=curr_sFiles;%
    
end;