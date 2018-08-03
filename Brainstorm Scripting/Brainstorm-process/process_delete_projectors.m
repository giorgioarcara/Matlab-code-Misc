function varargout = process_delete_projectors( varargin )
% PROCESS_import_EVENTS: import channel file .
%
% USAGE:     sProcess = process_import_channel('GetDescription')
%                       process_import_channel('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.1

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'delete projectors';
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
sProcess.options.Instructions.Comment='delete all existing projectors';
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

% CRUCIAL PART!!!
iStudies = unique([sInputs.iStudy]);
sStudies = bst_get('Study', iStudies);


for iStudy = 1:length(sStudies)
    
%     % get current Study
      curr_iStudy = iStudies(iStudy)
%     
     Channel = bst_get('ChannelForStudy',   curr_iStudy);
     
     ChannelData = in_bst_data(Channel.FileName);
     
     ChannelData.Projector = [];
%     
     bst_save(file_fullpath(Channel.FileName), ChannelData, 'v6', 1);
%   
end;

end


