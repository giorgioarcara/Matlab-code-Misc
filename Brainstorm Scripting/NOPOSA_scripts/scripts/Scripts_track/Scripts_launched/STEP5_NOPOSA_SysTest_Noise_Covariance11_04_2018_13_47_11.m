%% NOISE COVARIANCE
% this script generate noise covariance for the selected data.
% Importantly, run this code AFTER having created the last conditions
% (i.e., data folder containing the data on which the sources are computed) 
% so the noise is immediatly copied to the folder in
% which is needed

%% STEP 1 
% This script starts from a protocol (already created)
% with all files of all subjects
% 0) Convert epoched to continuos
% 1) Apply CTF compensation
% 2) resample at 600 Hz
% 3) calculate noise covariance
% 4) create snapshot.

%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath.m')

cd(curr_path)

addpath('functions')



% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/storages/LDATA/Giorgio Mapping/Parlog Analysis/';
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
SubjectNames = {...
    'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames{1}, ...
    'condition',     '', ...
    'tag',           'clean', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'SysTest');
my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'clean_resample');

%% SPECIFY HERE THE FILES AND THE SUBJECTS TO BE PROCESSED.

%%% compute noise covariance
sNoiseFiles = my_sFiles;

sNoiseFiles = bst_process('CallProcess', 'process_noisecov', sNoiseFiles, [], ...
    'baseline',       [,], ...
    'datatimewindow', [,], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       1, ... % copy directly to other conditions
    'copysubj',       0, ...
    'replacefile',    1);  % Replace


% Process: Snapshot: Noise covariance
sNoiseFiles = bst_process('CallProcess', 'process_snapshot', sNoiseFiles, [], ...
    'target',         3, ...  % Noise covariance
    'modality',       1, ...  % MEG (All)
    'orient',         1, ...  % left
    'time',           0, ...
    'contact_time',   [0, 0.1], ...
    'contact_nimage', 12, ...
    'threshold',      30, ...
    'Comment',        '');

% Save and display report
ReportFile = bst_report('Save', sNoiseFiles);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);

% USEFUL CODE to copy noie to other conditions (i.e., o other folders of
% the same subject)
% for iNoise=1:length(sNoiseFiles)
%     
%     OutputFiles = db_set_noisecov(sNoiseFiles(iNoise).iStudy, 'AllConditions')
%     
% end;


%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)
