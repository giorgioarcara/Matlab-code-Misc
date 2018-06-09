function varargout = process_rename_links( varargin )
% PROCESS_EXPORT_EVENTS: export events in a .mat file.
%
% USAGE:     sProcess = process_rename_links('GetDescription')
%                       process_rename_links('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.1

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'rename links to raw files';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Giorgio';
sProcess.Index       = 1021;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'raw'};
sProcess.OutputTypes = {'raw'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options
% Instructions
sProcess.options.Instructions.Comment='replace (via reg exp) part of the path of Links to raw files';
sProcess.options.Instructions.Type='label';
% Separator
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = '';
% === RAGET
sProcess.options.orpath.Comment = 'original path';
sProcess.options.orpath.Type    = 'text';
sProcess.options.orpath.Value   = ''; % the second number indicates the numbers after decimall separator.

sProcess.options.newpath.Comment = 'new path';
sProcess.options.newpath.Type    = 'text';
sProcess.options.newpath.Value   = '';

sProcess.options.warn.Comment = ['<B>WARNING </B>: use this process with caution. <BR> It may break all links to raw files.'];
sProcess.options.warn.Type    = 'label';


end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

original_path = sProcess.options.orpath.Value;
new_path = sProcess.options.newpath.Value;

AllFiles = {sInputs.FileName};

% select only Link to Raw Files
AllComments = {sInputs.Comment}
incl_sFiles=regexpi(AllComments, 'Link to raw file'); %
selFiles_indices=find(~cellfun(@isempty, incl_sFiles));
selFiles = AllFiles(selFiles_indices);

OutputFiles = selFiles;

for iFile = 1:length(AllFiles)
    
    Data = in_bst_data(selFiles{iFile});
    % rename
    Data.F.filename = regexprep(Data.F.filename, original_path, new_path);
    
    bst_save(file_fullpath(selFiles{iFile}), Data, 'v6', 1);
      
    
end;

end



