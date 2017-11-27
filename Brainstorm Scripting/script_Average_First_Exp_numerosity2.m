% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Brainstorm_Reports/';
export_folder='Exp_numerosity2';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Exp_numerosity2_merged';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')


%% SELECT  TRIALS
%
my_sFiles_string='p_'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string);


my_sFiles = {my_sFiles_ini.FileName}


%% AVERAGE (separating by folder)
bst_report('Start', my_sFiles);

% Process: Average: By trial group (folder average)
Res = bst_process('CallProcess', 'process_average', my_sFiles, [], ...
    'avgtype',    5, ...  % By trial group (folder average)
    'avg_func',   1, ...  % Arithmetic average:  mean(x)
    'weighted',   0, ...
    'keepevents', 0);


% Save and display report
ReportFile = bst_report('Save', Res);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
