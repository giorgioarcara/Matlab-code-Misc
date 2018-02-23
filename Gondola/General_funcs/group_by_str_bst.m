%% group_by_string_bst(FileNames, Strings, grouping_strings);
% this function group a cell containing file names in a cell cotanining
% several cells in which file names (i.e., data in Brainstorm) are separated
% according to a string.
% Normally FileNames are grouped according to FileNames themseleves, but a
% different grouping_string can be specified.
% It can be used to group by Subject (using a string identifying Subject names)
% or the Run (using a string identifying run name).
% A potential use of grouping strings is to use the Comment of a brainstorm
% file to group Names
% e.g.
%
% my_Strings={'Correct', 'Incorrect'};
%
% group_by_string_bst({sFiles.FileNames}, my_Strings, {sFiles.Comment});



function sGroupByStr = group_by_str_bst(FileNames, Strings, grouping_strings);

if nargin>2
    if length(grouping_strings)~=length(FileNames);
        error('!!! The length of grouping_strings must be the same of FileNames !!!');
    end
end;

if nargin<3
    grouping_strings=FileNames;
end;

sGroupByStr = {};
for istr=1:length(Strings); % NOTE! 2 because the first subject is intra subject.
    
    curr_str=Strings{istr};
    [~, curr_sFiles_indices]=sel_files_bst(grouping_strings, curr_str);
    
    sGroupByStr{istr}={FileNames{curr_sFiles_indices}};%
    
end;