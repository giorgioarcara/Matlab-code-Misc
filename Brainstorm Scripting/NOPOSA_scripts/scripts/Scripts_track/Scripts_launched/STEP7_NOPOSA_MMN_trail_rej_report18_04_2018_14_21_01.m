%% MMN blocks add tag
% 1) add tags to distinguish MMN blocks (long vs short).



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
% Start a new report
% Input files
sFiles = [];
SubjectNames = {...
    'All'};

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames{1}, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);


%% SELECT HERE THE CORRECT FILES
my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'Prose|RestingEO');


% DIVIDE BY SUBJECTS
SubjectNames={my_subjects.Subject.Name};
% SELECT SUBJECTS!
SubjectNames = sel_files_bst(SubjectNames, 'NP801|NP802|NP803|NP804|NP805|NP806|NP807|NP808|NP809|NP810|NP811|NP812|NP813|NP814|NP815|NP816|NP817|NP818|NP819|NP820|NP821|NP822|NP823|NP824|NP825|NP826|NP827');

Subj_files_grouped = group_by_str_bst(my_sFiles, SubjectNames);

% % DIVIDE BY RUN
% MMN_runs = {'_01', '_02'}
% for iSubj=1:length(Subj_files_grouped)
%     Subj_run{iSubj} = group_by_str_bst(Subj_files_grouped{iSubj}, MMN_runs);
% end


%% CREATE FOLDER
trial_rej_folder = 'ProseResting_trial_rej';
Report_tag = '_ProseResting_block';
mkdir([export_main_folder, export_folder, '/' trial_rej_folder]) %


% loop over subject
for iSubj=1:length(SubjectNames);
    
    curr_files = Subj_files_grouped{iSubj}
    
    Res = bst_process('CallProcess', 'process_snapshot', curr_files, [], ...
        'target',         5, ...  % Recordings time series
        'modality',       1, ...  % MEG (All)
        'orient',         5, ...  % front
        'time',           0, ...
        'contact_time',   [0, 0.1], ...
        'contact_nimage', 12, ...
        'threshold',      30, ...
        'Comment',        '');
    
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    newReportName = [SubjectNames{iSubj}, Report_tag, date '.mat'];
    newReportName=regexprep(newReportName, '-', '_');
    Report_path = bst_fileparts(ReportFile);
    copyfile(ReportFile, [Report_path, '/', newReportName]);
    
    %bst_report('Open', ReportFile);
    bst_report('Export', [Report_path, '/', newReportName], [export_main_folder, export_folder, '/',trial_rej_folder]);
    
    
end;

%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)





