%%
% this script works on a bst protocol in which pre-processing has been performed.
% trial rejection has been made and sources kernel are already computed.
% aim of this script is to calculate test and retest images by split-half
% division (performed 8 times).

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end



%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/Prove_threshold';
export_folder1='Split-Half';


if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Prove_thresh';

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
my_sFiles_string={'First_adj'}

subject_sel='CT'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', subject_sel, ...
    'includeintra',  0,...
    'tag',         my_sFiles_string{1});

% exclude trial with average
my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');

%% SEPARATE FILES FOR SUBJECT
SubjectNames={my_subjects.Subject.Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);

%% SEPARATE FILES BY RUN
runs={'_01/','_02/', '_03/'}
Subj_run={};


for iSubj=1:length(Subj_grouped)
    
    Subj_run{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, runs); % IMPORTANT: notice I enter in the cell {}
    
end;


%% SEPARATE FILES BY CONDITION (not necessary, but I leave this for code re-use);
Conditions={'First_adj'}
Subj_run_Condition={}

for iSubj=1:length(Subj_grouped)
    for irun=1:length(runs)
        Subj_run_Condition{iSubj}{irun}=group_by_str_bst(Subj_run{iSubj}{irun}, Conditions); % IMPORTANT: notice I enter in the cell {}
    end;
end;


%% TIME-FREQUENCY ANALYSIS WHOLE-BRAIN (SEPARATE FOR RUN).
for iSubj=1:length(SubjectNames)
    for iCond=1:length(Conditions)
        
        files_info={}; % initialize a cell to store info of files entered in the average
        
        for iSplitHalf=1:8
            
            for irun=1:length(runs)
                
                curr_files=Subj_run_Condition{iSubj}{irun}{iCond};
                
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
                
                
                %% SPLIT-HALF HERE (by run) to avoid prominent role of one run to the
                % other. In this case each run will contribute equally to the
                % final map.
                data_test=datasample(link_files, round(length(link_files)/2), 'Replace', false);
                data_retest=setdiff(link_files, data_test);
                % NOTE: the following code above could bias the number of
                % elements in the first group or in the second, if the nummber of trials is even. However this is
                % irrelevant cause the analysis is always made in one sense
                % (AUC of test on retest) or the other (AUC of retest on test).
                
                % Start a new report
                bst_report('Start', link_files);
                
                %% TEST Process: Average: Everything
                Res = bst_process('CallProcess', 'process_average', data_test, [], ...
                    'avgtype',    1, ...  % Everything
                    'avg_func',   1, ...  % Arithmetic average:  mean(x)
                    'weighted',   0, ...
                    'keepevents', 0);
                
                
                % Process: Add tag to comment.
                Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                    'tag',  [runs{irun}, Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_test' ]  , ...
                    'output', 1);  % Add to comment
                
                % Process: Add tag to name.
                Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                    'tag',  [runs{irun}, Conditions{iCond} '_SH_', num2str(iSplitHalf), '_test']   , ...
                    'output', 2);  % Add to name
                
                
                %% RETEST Process: Average: Everything
                Res2 = bst_process('CallProcess', 'process_average', data_retest, [], ...
                    'avgtype',    1, ...  % Everything
                    'avg_func',   1, ...  % Arithmetic average:  mean(x)
                    'weighted',   0, ...
                    'keepevents', 0);
                
                
                % Process: Add tag to comment.
                Res2 = bst_process('CallProcess', 'process_add_tag', Res2, [], ...
                    'tag',  [runs{irun}, Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_retest' ]  , ...
                    'output', 1);  % Add to comment
                
                % Process: Add tag to name.
                Res2 = bst_process('CallProcess', 'process_add_tag', Res2, [], ...
                    'tag',  [runs{irun}, Conditions{iCond} '_SH_', num2str(iSplitHalf), '_retest']   , ...
                    'output', 2);  % Add to name
                
                
                
                % create the cell with run_files. To be stored in the final
                % results
                
                test_files{irun}=data_test;
                retest_files{irun}=data_retest;
                
                run_files{1}(irun)=Res;
                run_files{2}(irun)=Res2;
                
                
                % Save and export report
                ReportFile = bst_report('Save', Res);
                bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
                
            end;
            
            % start second report
            bst_report('Start', run_files{1});
            
            
            %% STEP 1a) RUN AVERAGE TEST
            % Process: Average: Everything
            Res = bst_process('CallProcess', 'process_average', run_files{1}, [], ...
                'avgtype',   1, ...  % Everything
                'avg_func',  1, ...  % Arithmetic average:  mean(x)
                'weighted',  1, ...
                'matchrows', 0, ...
                'iszerobad', 1);
            
            % Process: Add tag to name.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                'tag',   [Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_test_runave']  , ...
                'output', 2);  % Add to name
            
            % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
                'tag',  [Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_test_runave']   , ...
                'output', 1);  % Add to comment
            
            % GET TEST HISTORY
            
            FileName = file_fullpath(Res(1).FileName);
            FileMat.Add_info=test_files;
            % Save file
            bst_save(FileName, FileMat, 'v6', 1);
            
            
            % Save and export report
            ReportFile = bst_report('Save', Res);
            bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
            
            %% STEP 1b) RUN AVERAGE RETEST
            % Process: Average: Everything
            
            bst_report('Start', run_files{2});
            
            Res2 = bst_process('CallProcess', 'process_average', run_files{2}, [], ...
                'avgtype',   1, ...  % Everything
                'avg_func',  1, ...  % Arithmetic average:  mean(x)
                'weighted',  1, ...
                'matchrows', 0, ...
                'iszerobad', 1);
            
            % Process: Add tag to name.
            Res2 = bst_process('CallProcess', 'process_add_tag', Res2, [], ...
                'tag',   [Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_retest_runave']  , ...
                'output', 2);  % Add to name
            
            % Process: Add tag to comment.
            Res2 = bst_process('CallProcess', 'process_add_tag', Res2, [], ...
                'tag',  [Conditions{iCond}, '_SH_', num2str(iSplitHalf), '_retest_runave']   , ...
                'output', 1);  % Add to comment
            
            FileName = file_fullpath(Res2(1).FileName);
            FileMat.Add_info=run_files{2};
            % Save file
            bst_save(FileName, FileMat, 'v6', 1);
            
            
            % Save and export report
            ReportFile = bst_report('Save', Res2);
            bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
            
   
            
            
            % Process: Delete selected files (delete the imported epoch in the
            % first step, to save space).
            %Del = bst_process('CallProcess', 'process_delete', run_files, [], ...
            %    'target', 1);  % Delete selected files
            
            
        end;
    end;
end;
















