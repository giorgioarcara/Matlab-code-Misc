% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='Perm_t-test_TF_ROI';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
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


SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials


%% SELECT  TRIALS
% 
my_sFiles_string='Second_Corr'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname', 'Group_analysis', ...
    'includeintra',  1,...
    'tag',         my_sFiles_string);


%% DIVIDE BY CONDITION
Conditions={'Fast18', 'Slow18'};

Condition_grouped=group_by_str_bst( {my_sFiles_ini.FileName}, Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');


%%
% set frequencies
Freqs={[5 7]; [8 12]};
Freq_names={'theta' 'alpha'};

% NOTE: to make permutation on ROI i first extract values, isolating one
% frequency.
% in this way, results for one frequency are treated as a source object and
% I can use the permutation function for sources (that allows to specify
% scouts).

for iFreq=1:length(Freqs);
    for iCond=1:length(Conditions);
        for iSubj=1:length(SubjectNames);
             
            %% IN this loop I extract values separately for each subject
            % this is necessary cause extract values try always to
            % concatenate time or subjects. Only using just on subject at
            % the time I obtain what I want. a
            % Process: Extract values: [-300ms,600ms] 5-7Hz
            curr_file = bst_process('CallProcess', 'process_extract_values', Condition_grouped{iCond}{iSubj}, [], ...
                'timewindow', [-0.3, 0.6], ...
                'freqrange',  [Freqs{iFreq}(1), Freqs{iFreq}(2)], ...
                'rows',       '', ...
                'isabs',      0, ...
                'avgtime',    0, ...
                'avgrow',     0, ...
                'avgfreq',    0, ...
                'matchrows',  0, ...
                'dim',        2, ...  % Concatenate time (dimension 2)
                'Comment',    '');
            
            % Process: Add tag to name.
            curr_file = bst_process('CallProcess', 'process_add_tag', curr_file, [], ...
                'tag',  [SubjectNames{iSubj}, '_', my_sFiles_string, '_', Conditions{iCond}] , ...
                'output', 2);  % Add to name
            
            % create a cell with n Condition elements. Each one contain the
            % struct related to a condition
                extract_all_files{iCond}(iSubj)=curr_file;
        end;
    end;
            
            bst_report('Start', extract_all_files{1});
            
            % notice that the order of subjects of group 1 and 2 is correct (i.e., paired) cause
            % it reflects the order of Grouped_condition, that were sorted
            % by fragment before
            
            % Process: Perm t-test paired [0ms, 400ms]          H0:(A=B), H1:(A<>B)
            Res = bst_process('CallProcess', 'process_test_permutation2p', extract_all_files{1},  extract_all_files{2}, ...
                'timewindow',     [0, 0.4], ...
                'scoutsel',       {'Destrieux', {'G_temporal_middle R', 'G_temporal_middle L', 'G_front_middle L', 'G_front_middle R', 'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'}}, ...
                'scoutfunc',      1, ...  % Mean
                'isnorm',         0, ...
                'avgtime',        0, ...
                'iszerobad',      1, ...
                'Comment',        '', ...
                'test_type',      'ttest_paired', ...  % Paired Student's t-test T = mean(A-B) / std(A-B) * sqrt(n)
                'randomizations', 1000, ...
                'tail',           'two');  % Two-tailed
            
            
            
            
            %export_matlab(Res, %% Cannot USE DELETE PROCESS TO DELETE (due to a probable bug)
            % also the results of the perm-test is deleted. I should add here some lines to delete manually the files 
            % and then reload files in brainstorm
            
            % alternativly you can temporary store the dataset and then
            % re_import_it with db_add_data 
            
            % Process: Delete selected files (delete the imported epoch in the
                % first step, to save space).
             %Del = bst_process('CallProcess', 'process_delete', extract_all_files{1}, [], ...
              %      'target', 1);  % Delete selected files (group 1)
             %Del = bst_process('CallProcess', 'process_delete', extract_all_files{2}, [], ...
              %      'target', 1);  % Delete selected files  (group 2)
            
            % Save and display report
            ReportFile = bst_report('Save', Res);
            bst_report('Export', ReportFile, [export_main_folder, '/' export_folder]);
    end;
