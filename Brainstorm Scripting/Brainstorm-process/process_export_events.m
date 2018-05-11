function varargout = process_export_events( varargin )
% PROCESS_EXPORT_EVENTS: export events in a .mat file.
%
% USAGE:     sProcess = process_export_events('GetDescription')
%                       process_export_events('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.1

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'export events';
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
sProcess.options.Instructions.Comment='To export events in a .mat file';
sProcess.options.Instructions.Type='label';
% Separator
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = '';
% === RAGET
sProcess.options.include.Comment = 'include text';
sProcess.options.include.Type    = 'text';
sProcess.options.include.Value   = ''; % the second number indicates the numbers after decimall separator.

sProcess.options.exclude.Comment = 'exclude text';
sProcess.options.exclude.Type    = 'text';
sProcess.options.exclude.Value   = '';


end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

AllFiles = {sInputs.FileName};

OutputFiles = AllFiles;

include_string = sProcess.options.include.Value;
include_string = regexprep(include_string, ',', '|');

exclude_string = sProcess.options.exclude.Value;
exclude_string = regexprep(exclude_string, ',', '|');


for iFile = 1:length(AllFiles)
    
    % get current file
    curr_file=in_bst_data(AllFiles{iFile});
    
    % get events labels
    events_labels = {curr_file.F.events.label};
    
    if ~isempty(include_string)
        include_check=regexp(events_labels, include_string);
        selFiles_indices=find(~cellfun(@isempty, include_check));
    else
        selFiles_indices = repmat(1, length(events_labels), 1); % if nothing is specified all events are selected.
    end
    
    % exclude check
    if ~isempty(exclude_string)
        exclude_check=regexp(DataComments, exclude_string);
        selFiles_indices=find(~cellfun(@isempty, include_check) & cellfun(@isempty, exclude_check));
    end;
    
    events = curr_file.F(selFiles_indices).events;
    
    % get folder Name (comment)
    Curr_Name=curr_file.F.comment;
    
    % save current name
    save(strcat(Curr_Name,'_events.mat'), 'events')
    
    
end;

end



