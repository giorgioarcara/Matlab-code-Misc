% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/Scout_run_average_ERSERD';


%% SET PROTOCOL
ProtocolName = 'Meghem_analisi_3';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')

% IMPORTANT: I want to confine my analysis on Group analysis (the project
% on default data).



%% SELECT  TRIALS
% 
initial_files=[];

my_sFiles_string={'First_Corr'}

    % make the first selection with bst process

% Process: Select results files in: Group_analysis/*/Second_Corr
my_sel_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', initial_files, [], ...
    'subjectname',   'All', ...
    'condition',     '', ...
    'tag',           my_sFiles_string{1}, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);

    my_sel_sFiles={ my_sFiles_ini(:).FileName };



    
%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);

%% SEPARATE FILES BY CONDITION (BY SUBJECT)
Conditions={'Fast18','Slow18'} 
Subj_run_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;

%% SEPARATE FILES BY RUN (BY SUBJECT, BY CONDITION)
runs={'_01_First','_02_First', '_03_First'} 
Subj_Condition_run={};

for iSubj=1:length(Subj_grouped)
    for iCond=1:length(Conditions)
    Subj_Condition_run{iSubj}{iCond}=group_by_str_bst(Subj_Condition{iSubj}{iCond}, runs); % IMPORTANT: notice I enter in the cell {}   
    end;
end;


%% SEPARATE FILES ONLY BY CONDITION
Conditions={'Fast18','Slow18'} 
Condition_grouped={}

Condition_grouped=group_by_str_bst(my_sel_sFiles, Conditions);
    

%%% CORRECTION FOR SUBJECT MH005
% is not necessary because it has been already done in the script time freq
% on scout centroids


% Start a new report
bst_report('Start', Condition_grouped);

for iCond=1:length(Conditions)
    
    %% STEP 1) RUN AVERAGE
    % Process: Average: Everything
    Res = bst_process('CallProcess', 'process_average', Condition_grouped{iCond}, [], ...
        'avgtype',   2, ...  % By subject
        'avg_func',  1, ...  % Arithmetic average:  mean(x)
        'weighted',  0, ...
        'matchrows', 1, ...
        'iszerobad', 1);
    % Process: Add tag to comment.
    Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
        'tag',  ['| scout | ', Conditions{iCond}]  , ...
        'output', 1);  % Add to comment
    
    % Process: Add tag to name.
    Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
        'tag',  ['_scout_', Conditions{iCond}]   , ...
        'output', 2);  % Add to name
    
    %% STEP 2) ERS/ERD
    % Process: Event-related perturbation (ERS/ERD): [-500ms,-300ms]
    Res = bst_process('CallProcess', 'process_baseline_norm', Res, [], ...
    'baseline',  [-0.5, -0.3], ...
    'method',    'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
    'overwrite', 0);
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    %bst_report('Open', ReportFile);
    bst_report('Export', ReportFile,  export_folder);
end;





