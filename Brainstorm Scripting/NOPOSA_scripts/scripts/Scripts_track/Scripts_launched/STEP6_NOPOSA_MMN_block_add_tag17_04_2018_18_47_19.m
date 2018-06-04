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
my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'MMN');
my_sFiles = sel_files_bst(my_sFiles, 'deviant_adj|standard_adj');


% DIVIDE BY SUBJECTS
SubjectNames={my_subjects.Subject.Name};
% SELECT SUBJECTS!
SubjectNames = sel_files_bst(SubjectNames, 'NP801|NP802|NP804|NP805|NP806|NP807|NP808|NP809|NP810|NP811|NP812|NP813|NP814|NP815|NP816|NP817|NP818|NP820|NP821|NP822|NP823|NP824|NP825|NP826|NP827');

Subj_files_grouped = group_by_str_bst(my_sFiles, SubjectNames);

% DIVIDE BY RUN
MMN_runs = {'_01', '_02'}
for iSubj=1:length(Subj_files_grouped)
    Subj_run{iSubj} = group_by_str_bst(Subj_files_grouped{iSubj}, MMN_runs);
end

% IMPORT DATA WITH CORRESPONDENCE
sessions_file = 'NOPOSA_MMN_sessions.csv'
MMN_sessions=readtable([curr_path, 'other_data/', sessions_file]);

% loop over subject
for iSubj=1:length(SubjectNames);
    
    curr_subj = SubjectNames{iSubj};
    
    MMN_iSubj = find(strcmp(MMN_sessions.id, curr_subj));
    
    session_1_dur = MMN_sessions(MMN_iSubj,:).block1;
    session_1_dur = session_1_dur{1};
    session_2_dur = MMN_sessions(MMN_iSubj,:).block2;
    session_2_dur = session_2_dur{1};
    
    sessions_dur = {session_1_dur, session_2_dur};
    
    % loop over runs
    for iRun = 1:length(MMN_runs)
        
        curr_files = Subj_run{iSubj}{iRun}
        
        % Process: Add tag: session duration
        Res = bst_process('CallProcess', 'process_add_tag', curr_files, [], ...
            'tag',    sessions_dur{iRun}, ...
            'output', 1);  % Add to comment
        
        % Process: Add tag: session duration
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',    sessions_dur{iRun}, ...
            'output', 2);  % Add to file name
        
        % Save and display report
        ReportFile = bst_report('Save', Res);
        %bst_report('Open', ReportFile);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder]);
        
    end;
end;


%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)





