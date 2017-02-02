% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='my_directory';
export_folder1='ERS/ERD'

if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;


%% SET PROTOCOL
ProtocolName = 'myprotocol';

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
my_sFiles_string={'start (#'}

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string{1});


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');






%% SEPARATE FILES FOR SUBJECT
SubjectNames={my_subjects.Subject(2:end).Name};
Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'INC', 'COR'}
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}
end;

%% TIME-FREQUENCY ANALYSIS WHOLE-BRAIN (SEPARATE FOR RUN).
for iSubj=1:length(SubjectNames)
    for iCond=1:length(Conditions)
        
        %% STEP 0) GET FILES
        % get all files for current Subject and current Condition
        
        curr_files=Subj_Condition{iSubj}{iCond};
        
        %% STEP 1) TIME-FREQUENCY DECOMPOSITION
        % Start a new report
        bst_report('Start', curr_files);
        
        % Process: Time-frequency (Morlet wavelets)
        Res = bst_process('CallProcess', 'process_timefreq', curr_files, [], ...
            'sensortypes', '', ...
            'edit',        struct(...
            'Comment',         'Avg,Power,1-45Hz', ...
            'TimeBands',       [], ...
            'Freqs',           [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17, 17.5, 18, 18.5, 19, 19.5, 20, 20.5, 21, 21.5, 22, 22.5, 23, 23.5, 24, 24.5, 25, 25.5, 26, 26.5, 27, 27.5, 28, 28.5, 29, 29.5, 30, 30.5, 31, 31.5, 32, 32.5, 33, 33.5, 34, 34.5, 35, 35.5, 36, 36.5, 37, 37.5, 38, 38.5, 39, 39.5, 40, 40.5, 41, 41.5, 42, 42.5, 43, 43.5, 44, 44.5, 45], ...
            'MorletFc',        1, ...
            'MorletFwhmTc',    3, ...
            'ClusterFuncTime', 'none', ...
            'Measure',         'power', ...
            'Output',          'average', ...
            'RemoveEvoked',    0, ...
            'SaveKernel',      0), ...
            'normalize',   'none');  % None: Save non-standardized time-frequency maps
        
        % Process: Add tag to comment.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [my_sFiles_string{1}, Conditions{iCond} ]  , ...
            'output', 1);  % Add to comment
        
        % Process: Add tag to name.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [my_sFiles_string{1}, Conditions{iCond} ]   , ...
            'output', 2);  % Add to name
        
        
        %% STEP 2) ERS/ERD
        % Process: Event-related perturbation (ERS/ERD): [-400,-100ms]
        Res = bst_process('CallProcess', 'process_baseline_norm', Res, [], ...
            'baseline',  [-0.4, -0.1], ...
            'method',    'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
            'overwrite', 1);
        
        
        
        %% WRITE FINAL REPORT IN THE FOLDER
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
        
        
        
        
    end;
end;















