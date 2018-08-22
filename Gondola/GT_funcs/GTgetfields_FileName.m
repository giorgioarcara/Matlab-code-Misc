% GTgetfields_FileName(FileNames, FileNamefields, structfields)
%
% This function takes as input a GTres object (object with results from an analysis
% with a script like BCT_analysis.m) and compute the average of the
% matrices in a field.
%
% INPUT
% - Filenames:
% - FileNamefields:
% - structfields:
%
%
%
%
% Author: Giorgio Arcara
%
% version: 14/08/2018
%
%

function GTres = GTgetfields_FileName(FileNames, varargin);


% part to check if, in a given group
p = inputParser;
addParameter(p, 'FileNamefields', [], @isstr);
addParameter(p, 'FileNameIgnore', [], @isstr);
addParameter(p, 'structfields', [], @iscell);

parse(p, varargin{:});

FileNameFields = p.Results.FileNamefields;
structfields = p.Results.structfields;
FileNameIgnore =  p.Results.FileNameIgnore;


split_symbol = '_';
split_pattern = strsplit(FileNameFields, split_symbol);
% get position of part of the files to exclude
excl_parts=regexpi(split_pattern, 'XX'); %
% get indices to include
incl_indices=find(cellfun(@isempty, excl_parts));

for iFile = 1:length(FileNames)
    
    % get current files
    curr_file = FileNames{iFile};
    
    % get rid of string to ignore, if required
    if (~isempty(FileNameIgnore))
        curr_file = regexprep(curr_file, FileNameIgnore, '');
    end;
    
    curr_filename_split = strsplit(FileNames{iFile}, split_symbol);
    
    % loop over fields (only the one to include).
    for iField = incl_indices
        
        GTres(iFile).( split_pattern{iField} ) = curr_filename_split{iField};
        
    end;
    
end



