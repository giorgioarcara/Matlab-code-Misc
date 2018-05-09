function varargout = process_import_channelmat( varargin )
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
sProcess.Comment     = 'import channel file';
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
sProcess.options.Instructions.Comment='To import channel file from a .mat file';
sProcess.options.Instructions.Type='label';

%INPUT
sProcess.options.channelfile.Comment = 'File to import:';
sProcess.options.channelfile.Type    = 'filename';
sProcess.options.channelfile.Value   = {...
    '', ...                                % Filename
    '', ...                                % FileFormat
    'open', ...                            % Dialog type: {open,save}
    'Import channel file', ...             % Window title
    'ImportChannel', ...                   % LastUsedDir: {ImportData,ImportChannel,ImportAnat,ExportChannel,ExportData,ExportAnat,ExportProtocol,ExportImage,ExportScript}
    'single', ...                          % Selection mode: {single,multiple}
    'files_and_dirs', ...                  % Selection mode: {files,dirs,files_and_dirs}
    bst_get('FileFilters', 'channel'), ... % Get all the available file formats
    'ChannelIn'};                          % DefaultFormats
end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = [];

NewChannelFile = sProcess.options.channelfile.Value{1};
% determine study names
% CRUCIAL PART!!!
sStudies = bst_get('Study', unique([sInputs.iStudy]));


for iInput = 1:length(sInputs)
    
    % get current Study
    curr_iStudy = sInputs(iInput).iStudy;
    
    curr_file = in_bst_data(sInputs(iInput).FileName, 'F');
    Curr_Name = curr_file.F.comment;
    
    Channel = bst_get('ChannelForStudy',   curr_iStudy);
    
    if ~isempty(Channel)
    ChannelFile = load(file_fullpath(Channel.FileName));    
    % delete old CHannel file
    delete(file_fullpath(Channel.FileName));
    
    
    Channel_path = bst_fileparts(file_fullpath(Channel.FileName))
    
    % copy new Channel File
    copyfile(NewChannelFile, Channel_path);

    db_reload_studies(curr_iStudy);
    
end;

end



