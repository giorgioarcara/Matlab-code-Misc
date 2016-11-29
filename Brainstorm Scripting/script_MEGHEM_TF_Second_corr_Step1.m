% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='TF_Second'
export_folder2='Second_runAve_ERSERD'

if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;
if ~exist([export_main_folder, '/' export_folder2])
    mkdir([export_main_folder, '/' export_folder2]) % create folder if it does not exist
end;


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


%% SELECT  TRIALS
%
my_sFiles_string={'First_Corr_'}

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string{1});


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');






%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'Fast18','Slow18'} 
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;

%% SEPARATE FILES BY RUN
runs={'_01_','_02_', '_03_'} 
Subj_Condition_run={};

for iSubj=1:length(Subj_grouped)
    for iCond=1:length(Conditions);
    Subj_Condition_run{iSubj}{iCond}=group_by_str_bst(Subj_Condition{iSubj}{iCond}, runs); % IMPORTANT: notice I enter in the cell {}
    end;
end;

%%% CORRECTION FOR SUBJECT MH005
% Subject 05, has run _01_, _03_ and _04
Subj_Condition_run{5}{1}{2}=Subj_Condition_run{5}{1}{3} % put run 3 in cell 2 (for Condition 1, Fast)
Subj_Condition_run{5}{2}{2}=Subj_Condition_run{5}{2}{3} % put run 3 in cell 2 (for Condition 2, Slow)

other_run=sel_files_bst(my_sel_sFiles, '(MH005/)([\w]+)(_04_)'); % \w match for all alphanumeric characters
other_run_Cond=group_by_str_bst(other_run, Conditions);

Subj_Condition_run{5}{1}{3}=other_run_Cond{1}; % retrieve condition 1 (Fast) of third run
Subj_Condition_run{5}{2}{3}=other_run_Cond{2}; % retrive condition 2 (Slow) of third run



%% TIME-FREQUENCY ANALYSIS SCOUT LEVEL (SEPARATE FOR RUN).

% set some tags, they will be used in the script (same length of iCond)
my_tag={'Second_corr_Fast18', 'Second_Corr_Slow18'};

        

%% TIME-FREQUENCY ANALYSIS WHOLE-BRAIN (SEPARATE FOR RUN).
for iSubj=1%:2%length(SubjectNames)
    for iCond=1:length(Conditions)
        
        files_info={}; % initialize a cell to store info of files entered in the average
        
        for irun=1:length(runs)
            
            % I select the epochs around the event First
            curr_files=Subj_Condition_run{iSubj}{iCond}{irun};
            
            bst_report('Start', curr_files);
            
            % first I import the file epoched aroung the event Second.
            % Process: Import MEG/EEG: Events
            curr_files_2 = bst_process('CallProcess', 'process_import_data_event', curr_files, [], ...
                'subjectname', SubjectNames{1}, ...
                'condition',   '', ...
                'eventname',   my_tag{iCond}, ... % notice I use my_tag for selection, but Conditions for determining the loop
                'timewindow',  [-2, 3.7], ...
                'epochtime',   [-2.5, 2.5], ...
                'createcond',  0, ...
                'ignoreshort', 1, ...
                'usectfcomp',  1, ...
                'usessp',      1, ...
                'freq',        [], ...
                'baseline',    [-0.3, 0]);
            
            
            %% RETRIEVE SOURCE (LINK) FILES AROUND SECOND EVENTS
            % retrieve condition path
            curr_study=bst_get('StudyWithCondition', bst_fileparts(curr_files_2(1).FileName));
            
            % exclude with the following steps the empty filenames, in the
            % ResultFile, otherwise cannot use intersect
            no_empty_DataFile_ind=find(~cellfun(@isempty, {curr_study.Result.DataFile}));
            no_empty_Resultfile=curr_study.Result(no_empty_DataFile_ind);
            
            % find intersection between curr-files (the data to be processed)
            % and the non-empty Resultfile names
            [a ind_curr_files ind_no_empty_Resultfile]=intersect({curr_files_2.FileName}, {no_empty_Resultfile.DataFile});
            
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
                'tag',  [runs{irun}, my_tag{1}, Conditions{iCond} ]  , ... %% !! NOTICE: here I use my_tag
                'output', 1);  % Add to comment
            
            % Process: Add tag to name.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                'tag',  [runs{irun}, my_tag{1}, Conditions{iCond} ]   , ...  %% !! NOTICE: here I use my_tag
                'output', 2);  % Add to name
            
            % create the struct at the first loop.
            % update the struct at all the other loops.
            if (irun==1)
                run_files=Res;
            else
                run_files(irun)=Res;
            end;
            
            % create cell with link_files to be stored as info
            files_info{irun}=link_files;
            
            % Save and export report
            ReportFile = bst_report('Save', Res);
            bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
            
            % delete Second Files to save storage space
            
            % Process: Delete selected files (delete the imported epoch in the
            % first step, to save space).
            Del = bst_process('CallProcess', 'process_delete', curr_files_2, [], ...
                'target', 1);  % Delete selected files
            
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
            'tag',   [ '_whole_', my_tag{iCond}]  , ...
            'output', 2);  % Add to name
        
        % Process: Add tag to comment.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [ ' | whole | ', my_tag{iCond}]   , ...
            'output', 1);  % Add to comment
        
        Res_to_del=Res;
        
        %% STEP 2) ERS/ERD
        % Process: Event-related perturbation (ERS/ERD): [-500ms,-300ms]
        Res = bst_process('CallProcess', 'process_baseline_norm', Res, [], ...
            'baseline',  [-1.2, -1], ... % Notice! these limits are -0.5 -0.3 - (0.7) - with 0.7 the distance between First and Second
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
        
        % Process: Delete selected files (delete the imported epoch in the
        % first step, to save space).
        Res_to_del = bst_process('CallProcess', 'process_delete', Res_to_del, [], ...
            'target', 1);  % Delete selected files
                
        % Save and export report
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder2]);
        
        
        % Process: Delete selected files (delete the imported epoch in the
        % first step, to save space).
        Del = bst_process('CallProcess', 'process_delete', run_files, [], ...
            'target', 1);  % Delete selected files
        
        
    end;
end;