function varargout = process_raw_count_events( varargin )
% process_raw_count_events: count events in raw files.
%
% USAGE:     sProcess = process_raw_count_events('GetDescription')
%                       process_raw_count_events('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2016, version 0.2

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'Count events in raw files';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Giorgio';
sProcess.Index       = 1022;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'raw'};
sProcess.OutputTypes = {'raw'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options
% Instructions
% Separator
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = '';
% === events.
sProcess.options.events.Comment = 'select events';
sProcess.options.events.Type    = 'text';
sProcess.options.events.Value   = ''; % the second number indicates the numbers after decimall separator.

% explanation
sProcess.options.expl.Type = 'label';
sProcess.options.expl.Comment = 'Insert event labels as: eventname1, eventname2, ...';


end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = {sInputs.FileName};

events_lab_temp = sProcess.options.events.Value;
events_lab = strsplit(events_lab_temp, ', ');

% initialize emtpy object (files x labels)
EventsCount = zeros(length(sInputs), length(events_lab));
RowNames = cell(1, length(sInputs));

for iFile = 1:length(sInputs)
    
    % select current study
    curr_raw = in_bst_data(sInputs(iFile).FileName);
    
    curr_events_labs = {curr_raw.F.events.label};
    curr_events_samp = {curr_raw.F.events.samples};
    
    for iEvent = 1:length(events_lab)
        event_ind = find(strcmpi(events_lab{iEvent}, curr_events_labs));
        
        if isempty(event_ind)
            curr_events_count=0;
        else
            curr_events_count = size(curr_events_samp{event_ind}, 2); % the length of samples is the number of events
        end
        % update output object
        EventsCount(iFile, iEvent)=curr_events_count;
        RowNames{iFile} = curr_raw.F.comment;
    end;
    
    
    
end;

EventsTable = array2table(EventsCount);
EventsTable.Properties.VariableNames = strcat('ev_', events_lab);
EventsTable.Properties.RowNames = RowNames;
% export to workspace
assignin('base', 'EventsTable', EventsTable);
writetable(EventsTable, 'EventsTable.txt','delimiter', '\t', 'WriteRowNames',true);   

end



