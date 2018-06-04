%% STEP X NOPOSA
% This script fix
%
% 1) Re-import the channel file
% 2) re-import the pos


clear

%% RUN THE SCRIPT TO SET THE PATH
run('NOPOSA_startpath.m');

cd(curr_path);

addpath('functions');

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder=curr_path;
export_folder='Reports';

if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;


%% GET CURRENT SCRIPT NAME

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

%%


%% SET PROTOCOL
ProtocolName = 'NOPOSA_analysis1';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')


%% SELECT FILES WITH BRAINSTORM FUNCTIN
% select all files

% Input files
SubjectNames = {...
    'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



%% SPECIFY HERE THE FILES AND THE SUBJECTS TO BE PROCESSED.

my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'resample', 'SysTest');
my_sFiles = sel_files_bst(my_sFiles, '.', 'NP801|NP802');

my_sFiles = my_sFiles(1:2);

%% LOOP OVER FILE


AllRes={}; % initialize a cell for the report


bst_report('Start', my_sFiles);

% STEP 1 input the file to retrieve the original folder
for iFile = 1:length(my_sFiles)
    
    curr_file = my_sFiles{iFile};
    
    % first get the history of the file (to get the original folder)
    History = in_bst_data(curr_file, 'History');
    
    % get the folder name
    curr_path_temp = History.History{1,3};
    curr_path=regexprep(curr_path_temp, 'Link to raw file: ', '');
    
    % find (in that folder) the only pos file.
    curr_pos_temp=dir([curr_path, '/*.pos']);
    curr_pos = [curr_path, '/', curr_pos_temp.name];
    
    % Process: Set channel file (from current path)
    Res1 = bst_process('CallProcess', 'process_import_channel', curr_file, [], ...
        'channelfile',  {curr_path, 'CTF'}, ...
        'usedefault',   1, ...  %
        'channelalign', 0, ... % not use channels to align
        'fixunits',     1, ...
        'vox2ras',      1);
    
    % Process: Add head points
    Res2 = bst_process('CallProcess', 'process_headpoints_add', curr_file, [], ...
        'channelfile', {curr_pos, 'POLHEMUS'}, ...
        'fixunits',    1, ...
        'vox2ras',     1);
    
    AllRes = {AllRes, Res1.FileName, Res2.FileName};
    
end

AllRes = AllRes(2:end); % exclude first object (it was empty)

% Save and display report
ReportFile = bst_report('Save', AllRes);
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);

%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)


