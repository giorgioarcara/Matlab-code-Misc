%% MMN blocks add tag
% 1) add tags to distinguish MMN blocks (long vs short).



%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath')
cd(curr_path)
addpath(genpath('functions'))

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
% Start a new report
% Input files
sFiles = [];
SubjectNames = {...
    'All'};

Session_names={'long', 'short'};

for iSession=1:length(Session_names);
    
    % Process: Select data files in: */*
    my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
        'subjectname',   SubjectNames, ...
        'condition',     '', ...
        'tag',           Session_names{iSession}, ...
        'includebad',    0, ...
        'includeintra',  0, ...
        'includecommon', 0);
    
    
    %% SELECT HERE THE CORRECT FILES
    my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'MMN');
    my_sFiles = sel_files_bst(my_sFiles, 'deviant_adj|standard_adj', 'Avg');
    
    sel_subjects = 'NP801|NP802|NP804|NP805|NP806|NP807|NP808|NP809|NP810|NP811|NP812|NP813|NP814|NP815|NP816|NP817|NP818|NP820|NP821|NP822|NP823|NP824|NP825|NP826|NP827';
    
    my_sFiles = sel_files_bst(my_sFiles, sel_subjects);
    
    curr_files = my_sFiles;
    
    % TO EXCLUDE SOME SUBJECTS
    % my_sFiles = sel_files_bst(my_sFiles, '.', 'S001_|S002_');
    my_tag = ''; % i leave this for consistency in this tag
    
    
    % Start a new report
    bst_report('Start', curr_files);
    
    
    
    % Process: Average: By trial group (folder average)
    Res = bst_process('CallProcess', 'process_average', curr_files, [], ...
        'avgtype',    5, ...  % By trial group (folder average)
        'avg_func',   1, ...  % Arithmetic average:  mean(x)
        'weighted',   0, ...
        'keepevents', 0);
    
    
    % NOTA!! non posso mettere il tag perchE' c'e' il link alla source e da
    % errore (l'info e' comuunque nel tag)
    %     % Process: Add tag: Response_adj
    %     Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
    %         'tag',    [my_tag, Session_names{iSession}], ...
    %         'output', 2);  % Add to filename
    
    
    
    % Save and display report
    ReportFile = bst_report('Save', curr_files);
    bst_report('Open', ReportFile);
    bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
    
end;

%% BACKUP SCRIPT AND OBJECT WITH DATA


export_script(script_name, my_sFiles_ini)


