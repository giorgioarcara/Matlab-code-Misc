function varargout = process_create_events( varargin )
% PROCESS_EXPORT_EVENTS: export events in a .mat file.
%
% USAGE:     sProcess = process_export_events('GetDescription')
%                       process_export_events('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.3

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'create events';
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
sProcess.options.Instructions.Comment='To create events in a raw file';
sProcess.options.Instructions.Type='label';
% Separator
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = '';
% === RAGET
sProcess.options.event_lab.Comment = 'Event Label';
sProcess.options.event_lab.Type    = 'text';
sProcess.options.event_lab.Value   = ''; % the second number indicates the numbers after decimall separator.

sProcess.options.sec.Comment = 'seconds {{start end} {start end} ... }';
sProcess.options.sec.Type    = 'text';
sProcess.options.sec.Value   = '';


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

EventsTimes = eval(sProcess.options.sec.Value);
newEventLab = sProcess.options.event_lab.Value;

for iFile = 1:length(AllFiles)
    
    % get current file
    sRaw=in_bst_data(AllFiles{iFile});
    
    % get timepoint duration (necessary after)
    timepoint_dur = (sRaw.F.prop.sfreq);
    
    
    for iTime = 1:length(EventsTimes)
        
        % check if label already exist otherwise create new.
        labels = {sRaw.F.events.label};
        
        
        %%%%%%%%  case existing event %%%%%%%%%%%
        if any(strcmpi(newEventLab, labels))
            lab_ind = find(strcmpi(newEventLab, labels));
            lab_ind = lab_ind(1); % this is to protect from a potential bug. IF there are more groups with the same_name
            
            % case extended event
            if length(EventsTimes{iTime})==2;
                New_Event_times = [ EventsTimes{iTime}{1}; EventsTimes{iTime}{2}];
                sRaw.F.events(lab_ind).times = [sRaw.F.events(lab_ind).times, New_Event_times];
                New_Event_samples = [round(EventsTimes{iTime}{1}*timepoint_dur); round(EventsTimes{iTime}{2}*timepoint_dur)];
                sRaw.F.events(lab_ind).samples = [sRaw.F.events(lab_ind).samples New_Event_samples];
                % case single event
            elseif length(EventsTimes{iTime})==1;
                New_Event_times = [EventsTimes{iTime}{1}];
                sRaw.F.events(lab_ind).times = [sRaw.F.events(lab_ind).times, New_Event_times]
                New_Event_samples = [round(EventsTimes{iTime}{1}*timepoint_dur)];
                sRaw.F.events(lab_ind).samples = [sRaw.F.events(lab_ind).samples, New_Event_samples];
            end;
            
            
        end;
        
        
        
        %%%%%%%%  case new event %%%%%%%%%%%
        if ~any(strcmpi(newEventLab, labels))
            
            % create new Label
            sRaw.F.events(end+1).label =newEventLab;
            sRaw.F.events(end).color = [1 0.6000 0];
            
            % case extended event
            if length(EventsTimes{iTime})==2;
                sRaw.F.events(end).times = [EventsTimes{iTime}{1}; EventsTimes{iTime}{2}];
                sRaw.F.events(end).samples = [round(EventsTimes{iTime}{1}*timepoint_dur); round(EventsTimes{iTime}{2}*timepoint_dur)];
                % case single event
            elseif length(EventsTimes{iTime})==1;
                sRaw.F.events(end).times = [EventsTimes{iTime}{1}];
                sRaw.F.events(end).samples = [round(EventsTimes{iTime}{1}*timepoint_dur)];
            end;
            
            sRaw.F.events(end).select = 1;
            
        end;
        
    end;
    
    
    lab_ind = find(strcmpi(newEventLab, labels));
    sRaw.F.events(lab_ind).epochs = repmat(1, 1, length(sRaw.F.events(lab_ind).times));
    
    bst_save(file_fullpath(AllFiles{iFile}), sRaw, 'v6', 1);
    
end;

end