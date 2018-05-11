function varargout = process_export_channelmat( varargin )
% PROCESS_export_EVENTS: export channel file .
%
% USAGE:     sProcess = process_export_channel('GetDescription')
%                       process_export_channel('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.1

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'export channel file';
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
sProcess.options.Instructions.Comment='To export channel file for a study';
sProcess.options.Instructions.Type='label';

end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = [];

% determine study names
% CRUCIAL PART!!!
sStudies = bst_get('Study', unique([sInputs.iStudy]));


for iInput = 1:length(sInputs)
    
    % get current Study
    curr_iStudy = sInputs(iInput).iStudy;
    
    curr_file = in_bst_data(sInputs(iInput).FileName, 'F');
    Curr_Name = curr_file.F.comment;
    
    Channel = bst_get('ChannelForStudy',   curr_iStudy);
    ChannelFile = load(file_fullpath(Channel.FileName));
        
    % save current Channel File
    save(strcat(Curr_Name,'_ChannelFile.mat'), 'ChannelFile')
    
end;

end



