%% IMPORT EPOCHS
% 1) adjust events with audio channel
% 1) import epochs with -1.5 - 1.5 of Adjusted
% 2) baseline corection -100 - 0



%% PRELIMINARY PREPARATION
clear

run('COBRAM_startpath')
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
ProtocolName = 'COBRAM_analysis1';

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
my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'COBRAM');
my_sFiles = sel_files_bst(my_sFiles, 'resample');
my_sFiles = sel_files_bst(my_sFiles, 'COB01|COB02|COB03|COB04|COB05|COB06|COB07|COB08|COB09|COB10|COB11');



%% FIRST PART ADJUST ALL FILES WITH PHOTODIODE CHANNEL

% Start a new report
bst_report('Start', my_sFiles);

% Process: Detect: Response_adj
Res = bst_process('CallProcess', 'process_evt_detect_analog', my_sFiles, [], ...
    'eventname',   'Met_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    1, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Met', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

Res = bst_process('CallProcess', 'process_evt_detect_analog', Res, [], ...
    'eventname',   'Lit_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    1, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Lit', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

Res = bst_process('CallProcess', 'process_evt_detect_analog', Res, [], ...
    'eventname',   'Fil_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    1, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Fil', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

%% FIX ERROR IN SOME FILES
% in the next lines of code I correct a mistake in the photodiode positioning (it was 0.1 sec after the stimulus)
%In this correction I still assume that in handling the photodiode Psychopy is more precise that in sending the simple trigger.
Res_tofix = sel_files_bst({Res.FileName}, 'COB01|COB02|COB03|COB04|COB05|COB06|COB07|COB08|COB09|COB10|COB11');

% Process: Add time offset
Res_tofix = bst_process('CallProcess', 'process_evt_timeoffset', Res_tofix, [], ...
    'info',      [], ...
    'eventname', 'Met_adj, Fil_adj, Lit_adj', ...
    'offset',    -0.1);

Res_tofix2 = sel_files_bst({Res.FileName}, 'COB01');


% Process: Rename event
% here I correct a mistake in the first subject: The trigger were inverted (fixed from the second subject).
Res_tofix2  = bst_process('CallProcess', 'process_evt_rename', Res_tofix2 , [], ...
    'src',  'Correct', ...
    'dest', 'Wrong2');

Res_tofix2  = bst_process('CallProcess', 'process_evt_rename', Res_tofix2 , [], ...
    'src',  'Wrong', ...
    'dest', 'Correct');

Res_tofix2  = bst_process('CallProcess', 'process_evt_rename', Res_tofix2 , [], ...
    'src',  'Wrong2', ...
    'dest', 'Wrong');

% AFTER FIX ARE MADE COMBIND STIMULUS AND RESPONSE
% Process: Combine stim/response
Res = bst_process('CallProcess', 'process_evt_combine', Res, [], ...
    'combine', ['Met_adj_Corr, ignore , Met_adj , Correct' 10 'Lit_adj_Corr, ignore, Lit_adj, Correct' 10 'Fil_adj_Corr, ignore , Fil_adj , Correct' 10 ''], ...
    'dt',      5);



% Save and display report
ReportFile = bst_report('Save', Res);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);

ReportFile2 = bst_report('Save', {Res_tofix.FileName, Res_tofix2.FileName});
bst_report('Export', ReportFile2, [export_main_folder, '/', export_folder]);

%% SECOND PART IMPORT EPOCHS
% DIVIDE BY SUBJECTS
SubjectNames={my_subjects.Subject.Name};
Subj_files_grouped = group_by_str_bst(my_sFiles, SubjectNames);

% DIVIDE BY RUN
COB_runs = {'_01', '_02', '_03', '_04'}
for iSubj=1:length(Subj_files_grouped)
    Subj_run{iSubj} = group_by_str_bst(Subj_files_grouped{iSubj}, COB_runs);
end

% loop over subjects
for iSubj=1:length(SubjectNames)
    
    for iRun=1:length(COB_runs)
        
        curr_files = Subj_run{iSubj}{iRun}
        
        % process import
        % Script generated by Brainstorm (01-Nov-2017)
        
        % Start a new report
        bst_report('Start', curr_files);
        
        % Process: Import MEG/EEG: Events
        Res = bst_process('CallProcess', 'process_import_data_event', curr_files, [], ...
            'subjectname', SubjectNames{iSubj}, ...
            'condition',   '', ...
            'eventname',   'Met_adj_Corr, Lit_adj_corr, Fil_adj_corr', ...
            'timewindow',  [], ...
            'epochtime',   [-1.5, 1.5], ...
            'createcond',  0, ...
            'ignoreshort', 1, ...
            'usectfcomp',  1, ...
            'usessp',      1, ...
            'freq',        [], ...
            'baseline',    [-0.1, 0]);
        
        % Save and display report
        ReportFile = bst_report('Save', Res);
        bst_report('Open', ReportFile);
        % bst_report('Export', ReportFile, ExportDir);
        
    end
end

% loop over run



%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)
