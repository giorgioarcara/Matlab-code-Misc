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
    'ChannelIn'};    % DefaultFormats

sProcess.options.Explanation.Comment=['<B>NOTE</B>: this process is meant to be used after the process export channel file<BR>',...
'it will not work on other type of exported files'];
sProcess.options.Explanation.Type='label';

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
NewChannelMat = load(NewChannelFile, '-struct');
% determine study names
% CRUCIAL PART!!!
iStudies = unique([sInputs.iStudy]);
sStudies = bst_get('Study', iStudies);


for iStudy = 1:length(sStudies)
    
%     % get current Study
      curr_iStudy = iStudies(iStudy)
%     
     Channel = bst_get('ChannelForStudy',   curr_iStudy);
%     
     bst_save(file_fullpath(Channel.FileName), NewChannelMat.ChannelFile, 'v6', 1);
%     
   
    
end;

end



