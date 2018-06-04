%% ERS/ERD sensor level
% 1) Calculate ERS/ERD at sensor level


%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath')

cd(curr_path)
addpath('functions')


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


%% SELECT FILES WITH BRAINSTORM FUNCTION
% select all files

% Input files
sFiles = [];


%% SELECT SUBJECT NAMES (note that only subject names are used to calculate bem).
SubjectNames = sel_files_bst({my_subjects.Subject.Name}, '.');

%% SELECT FILES
% select all files

% Input files
sFiles = [];
% SubjectNames = {...
%     'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname',   SubjectNames, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'sensors');


%% SELECT HERE THE CORRECT FILES
sel_subjects = 'NP801|NP802|NP804|NP805|NP806|NP807|NP808|NP809|NP810|NP811|NP812|NP813|NP814|NP815|NP816|NP817|NP818|NP819|NP820|NP821|NP822|NP823|NP824|NP825|NP826|NP827';
SubjectNames = sel_files_bst(SubjectNames, sel_subjects);


my_sFiles = sel_files_bst(my_sFiles, sel_subjects);


% apply ERS/ERD and make overall average.
curr_files = my_sFiles

bst_report('Start', curr_files);

% Process: Event-related perturbation (ERS/ERD): [-400ms,-20ms]
Res = bst_process('CallProcess', 'process_baseline_norm', curr_files, [], ...
    'baseline',  [-0.4, -0.2], ...
    'method',    'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
    'overwrite', 0);


% Save and display report
ReportFile = bst_report('Save', Res);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);



% BACKUP SCRIPT AND OBJECT WITH DATA


export_script(script_name, my_sFiles_ini)