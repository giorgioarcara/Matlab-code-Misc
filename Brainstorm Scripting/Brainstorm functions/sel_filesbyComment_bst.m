%% sel_filesbyComment_bst(sFiles, include_string, exclude_string)
% This functions take as first argument a Brainstorm struct 
% (as the ones produced by process_select_data). The function select a subset of files based on
% an inclusion string (part that should be included in the name), or an
% exclusion string in the Comment field of the Brainstorm Struct.
% Currently  NOT supported only the exclusion string, but you can just put
% "." in the inclusion string to select all files.
%
% The function is meant to be used with Brainstorm Software 
% http://neuroimage.usc.edu/brainstorm/Introduction (Tadel et al., 2011)
%
% Author: Giorgio Arcara
%
% Version: 24/02/2017

function [selFiles, selFiles_indices] = sel_filesbyComment_bst(sFiles, include_string, exclude_string)

incl_sFiles=regexpi({sFiles.Comment}, include_string); %

if (nargin <3) % case only select by inclusion
    selFiles_indices=find(~cellfun(@isempty, incl_sFiles));
    
else % case in which there is both inclusion and exclusion
    
    excl_sFiles=regexp({sFiles.Comment}, exclude_string);
    selFiles_indices=find(~cellfun(@isempty, incl_sFiles) & cellfun(@isempty, excl_sFiles)); 
% select fineal file
end

% extract filenames
sFilesNames={sFiles.FileName};

selFiles=sFilesNames(selFiles_indices);

end