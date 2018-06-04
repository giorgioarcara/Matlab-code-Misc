%% Time Frequency
% 1) Calculate TF at sensor level


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
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'standard_adj|deviant_adj');


%% SELECT HERE THE CORRECT FILES
SubjectNames = sel_files_bst(SubjectNames, 'NP801|NP802|NP804|NP805|NP806|NP807|NP808|NP809|NP810|NP811|NP812|NP813|NP814|NP815|NP816|NP817|NP818|NP819|NP820|NP821|NP822|NP823|NP824|NP825|NP826|NP827');



%% DIVIDE BY SUBJECTS
Subj_grouped = group_by_str_bst(my_sFiles, SubjectNames);

%% DIVIDE BY RUN (i.e. SESSION)

% get study names for each file
study_names = cell (1, length(Subj_grouped));
for iSubj = 1: length(Subj_grouped);
    for iFile = 1:length(Subj_grouped{iSubj});
        study_names{iSubj}{iFile} = bst_fileparts(Subj_grouped{iSubj}{iFile});
    end;
end;

% get unique and divide in
Subj_run=cell (1, length(Subj_grouped));
for iSubj = 1: length(Subj_grouped);
    Subj_run{iSubj} = group_by_str_bst(Subj_grouped{iSubj}, unique(study_names{iSubj}));
end

% divide by condition
cond_names={'deviant_adj', 'standard_adj'};
run_names = {'_01', '_02'}; % i create this cause I want to be sure to have two files.

Subj_run_cond = cell (1, length(Subj_grouped));
for iSubj = 1: length(Subj_run);
    for iRun = 1:length(run_names);
        Subj_run_cond{iSubj}{iRun} = group_by_str_bst(Subj_run{iSubj}{iRun}, cond_names);
    end
end;

% TO EXCLUDE SOME SUBJECTS
% my_sFiles = sel_files_bst(my_sFiles, '.', 'S001_|S002_');

% loop over subjects run and conditions
for iSubj = 1:length(SubjectNames)
    
    for iRun = 1:length(run_names);
        
        for iCond = 1:length(cond_names)
            
            curr_files=Subj_run_cond{iSubj}{iRun}{iCond};
            
            
            % Start a new report
            bst_report('Start', curr_files);
            
            
            % Start a new report
            bst_report('Start', curr_files);
            
            my_tag='beta'
            
            % Process: Time-frequency (Morlet wavelets)
            curr_files = bst_process('CallProcess', 'process_timefreq', curr_files, [], ...
                'sensortypes', 'MEG', ...
                'edit',        struct(...
                'Comment',         'Avg,Magnitude,1-80Hz,log,sensors', ...
                'TimeBands',       [], ...
                'Freqs',           [1, 1.5, 2.1, 2.7, 3.3, 4, 4.7, 5.5, 6.3, 7.2, 8.1, 9, 10, 11.1, 12.3, 13.5, 14.8, 16.2, 17.6, 19.2, 20.8, 22.6, 24.4, 26.4, 28.4, 30.6, 33, 35.4, 38.1, 40.9, 43.8, 47, 50.3, 53.8, 57.6, 61.5, 65.8, 70.2, 75, 80], ...
                'MorletFc',        1, ...
                'MorletFwhmTc',    3, ...
                'ClusterFuncTime', 'none', ...
                'Measure',         'magnitude', ...
                'Output',          'average', ...
                'RemoveEvoked',    0, ...
                'SaveKernel',      0), ...
                'normalize',   'none');  % None: Save non-standardized time-frequency maps
            
            % Process: Add tag: log_sensors
            curr_files = bst_process('CallProcess', 'process_add_tag', curr_files, [], ...
                'tag',    'log_sensors', ...
                'output', 2);  % Add to file name
            
            
            
            % Save and display report
            ReportFile = bst_report('Save', curr_files);
            bst_report('Open', ReportFile);
            bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
            
        end;
        
    end;
end;
    
    %% BACKUP SCRIPT AND OBJECT WITH DATA
    
    
    export_script(script_name, my_sFiles_ini)
