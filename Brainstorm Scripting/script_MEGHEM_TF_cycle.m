% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='Misc1'
export_folder2='Misc2'

if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;
if ~exist([export_main_folder, '/' export_folder2])
    mkdir([export_main_folder, '/' export_folder2]) % create folder if it does not exist
end;


%% SET PROTOCOL
ProtocolName = 'Mapping';

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
my_sFiles_string={'_trial_'}

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',        []);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');




%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials
Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'First_adj'} 
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;

%% SEPARATE FILES BY RUN
runs={'_01/','_02/'} 
Subj_Condition_run={};


for iSubj=1:length(Subj_grouped)
    for iCond=1:length(Conditions);
    Subj_Condition_run{iSubj}{iCond}=group_by_str_bst(Subj_Condition{iSubj}{iCond}, runs); % IMPORTANT: notice I enter in the cell {}
    end;
end;


%% RETRIEVE SOURCE FILES


%% TIME-FREQUENCY ANALYSIS WHOLE-BRAIN (SEPARATE FOR RUN).
for iSubj=1:2%length(SubjectNames)
    for iCond=1:length(Conditions)
        
        files_info={}; % initialize a cell to store info of files entered in the average
        
        for irun=1:length(runs)
            
            curr_files=Subj_Condition_run{iSubj}{iCond}{irun};
            
            %% RETRIEVE SOURCE (LINK) FILES
            % retrieve condition path
            curr_study=bst_get('StudyWithCondition', bst_fileparts(curr_files{1}));
            
            % exclude with the following steps the empty filenames, in the
            % ResultFile, otherwise cannot use intersect
            no_empty_DataFile_ind=find(~cellfun(@isempty, {curr_study.Result.DataFile}));
            no_empty_Resultfile=curr_study.Result(no_empty_DataFile_ind);
            
            % find intersection between curr-files (the data to be processed)
            % and the non-empty Resultfile names
            [a ind_curr_files ind_no_empty_Resultfile]=intersect(curr_files, {no_empty_Resultfile.DataFile});
            
            % retrieve link_files
            link_files={no_empty_Resultfile(ind_no_empty_Resultfile).FileName};
            
            
            % Start a new report
            bst_report('Start', link_files);
            
            
            % Process: Hilbert transform
            Res = bst_process('CallProcess', 'process_hilbert', link_files, [], ...
                'clusters',  {}, ...
                'scoutfunc', 1, ...  % Mean
                'edit',      struct(...
                'Comment',         'Avg,Power', ...
                'TimeBands',       [], ...
                'Freqs',           {{'theta', '5, 7', 'mean'; 'alpha', '8, 12', 'mean'}}, ...
                'ClusterFuncTime', 'none', ...
                'Measure',         'power', ...
                'Output',          'average', ...
                'RemoveEvoked',    0, ...
                'SaveKernel',      0), ...
                'normalize', 'none', ...  % None: Save non-standardized time-frequency maps
                'mirror',    0);
            
            % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                'tag',  [runs{irun}, my_sFiles_string{1}, Conditions{iCond} ]  , ...
                'output', 1);  % Add to comment
            
            % Process: Add tag to name.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                'tag',  [runs{irun}, my_sFiles_string{1}, Conditions{iCond} ]   , ...
                'output', 2);  % Add to name
            
            % create the struct at the first loop.
            % update the struct at all the other loops.
            if (irun==1)
                run_files=Res;
            else
                run_files(irun)=Res;
            end;
            
            % create cell with link_files
            files_info{irun}=link_files;
            
            % Save and export report
            ReportFile = bst_report('Save', Res);
            bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
            
        end;
        
        % start second report
        bst_report('Start', run_files);
        
        
        %% STEP 1) RUN AVERAGE
        % Process: Average: Everything
        Res = bst_process('CallProcess', 'process_average', run_files, [], ...
            'avgtype',   2, ...  % By subject
            'avg_func',  1, ...  % Arithmetic average:  mean(x)
            'weighted',  0, ...
            'matchrows', 1, ...
            'iszerobad', 1);
        
        % Process: Add tag to name.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',   [my_sFiles_string{1}, '_whole_', Conditions{iCond}]  , ...
            'output', 2);  % Add to name
        
        % Process: Add tag to comment.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [ my_sFiles_string{1},' | whole | ', Conditions{iCond}]   , ...
            'output', 1);  % Add to comment
        
        %% STEP 2) ERS/ERD
        % Process: Event-related perturbation (ERS/ERD): [-500ms,-300ms]
        Res = bst_process('CallProcess', 'process_baseline_norm', Res, [], ...
            'baseline',  [-0.5, -0.3], ...
            'method',    'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
            'overwrite', 1);
        
        % Process: Extract time: [-300ms,600ms]
        Res = bst_process('CallProcess', 'process_extract_time', Res, [], ...
            'timewindow', [-0.3, 0.6], ...
            'overwrite',  1);
        
        % add file info to the file
        FileName = file_fullpath(Res(1).FileName);
        FileMat.Add_info=files_info;
        % Save file
        bst_save(FileName, FileMat, 'v6', 1);
        
        
        % Save and export report
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder2]);
        
        
        % Process: Delete selected files (delete the imported epoch in the
        % first step, to save space).
        Del = bst_process('CallProcess', 'process_delete', run_files, [], ...
            'target', 1);  % Delete selected files
        
        
    end;
end;

        
        
        
        
        







