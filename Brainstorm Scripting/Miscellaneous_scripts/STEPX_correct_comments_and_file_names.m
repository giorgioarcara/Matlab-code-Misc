%% CORREZIONE ERORE
% ----------- IMPORTANT -----------
% works on the extracted values from COHERENCE.


%% PRELIMINARY PREPARATION
clear


addpath('/storages/LDATA/Analyses tDCS-MEG - 03 2017')

% launch brainstorm, with no gui (but only if is not already condning)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/storages/LDATA/Analyses tDCS-MEG - 03 2017';
export_folder='Reports';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;

%% SET PROTOCOL
ProtocolName = 'tDCS_MEG_Neural_Plasticity_new';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')


% Input files
sFiles = [];
SubjectNames = {...
    'Subject06_A'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname',   SubjectNames{1}, ...
    'condition',     '', ...
    'tag',           'Coh(', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'delta', 'Subject10|Group_analysis');

% strings to be replaced
to_replace_comment = '\| delta '; % note the '\', it is for the special character '|';
to_replace_filename = 'delta_';

% substitutions
sub_comment='';
sub_filename='';



for iFile=1:length(my_sFiles);
    % get file name (complete)
    FileName = file_fullpath(my_sFiles{iFile});
    % retrieve comment
    curr_comment = in_bst_data(FileName, 'Comment');
    % adjust comment
    curr_comment_adj = regexprep(curr_comment.Comment, to_replace_comment, sub_comment);
    FileMat.Comment = curr_comment_adj;
    % save FileMat with adjusted filed (it will just update the field).
    bst_save(FileName, FileMat,'v6', 1);
    
    % rename the files (dangerous)
    NewFileName = regexprep(FileName, to_replace_filename, sub_filename);
    movefile(FileName, NewFileName);
    
    % create object with newFileNames in case of disasters
    AllnewFileNames{iFile} = NewFileName;
end;


AllOriginalFileNames = my_sFiles;

% in case of mistakes. You can go back to the preceding state by using the 
% AllOriginalFileNames and AllNewFileNames (and renaming back with a loop)
    
