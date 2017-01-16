% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='Perm_t-test_ERF_ROI';


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


%% SELECT  TRIALS
% 
my_sFiles_string='Second_Corr'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname', 'Group_analysis', ...
    'includeintra',  1,...
    'tag',         my_sFiles_string);


%% DIVIDE BY CONDITION
Conditions={'Fast18', 'Slow18'};

Condition_grouped=group_by_str_bst( {my_sFiles_ini.FileName}, Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');


%%
% Start a new report
bst_report('Start', Condition_grouped{1});

% Process: Perm t-test paired [0ms, 400ms]          H0:(A=B), H1:(A<>B)
Res = bst_process('CallProcess', 'process_test_permutation2p', Condition_grouped{1},  Condition_grouped{2}, ...
    'timewindow',     [0, 0.4], ...
    'scoutsel',       {'Destrieux', {'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'G_parietal_sup L', 'G_parietal_sup R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'}}, ...
    'scoutfunc',      1, ...  % Mean
    'isnorm',         0, ...
    'avgtime',        0, ...
    'iszerobad',      1, ...
    'Comment',        '', ...
    'test_type',      'ttest_paired', ...  % Paired Student's t-test T = mean(A-B) / std(A-B) * sqrt(n)
    'randomizations', 1000, ...
    'tail',           'two');  % Two-tailed

   % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [my_sFiles_string, '_ROI']   , ...
            'output', 1);  % Add to comment
        
          % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [my_sFiles_string, '_ROI']   , ...
            'output', 2);  % Add to name
            

 % Save and display report
    ReportFile = bst_report('Save', Res);
    bst_report('Export', ReportFile, [export_main_folder, '/' export_folder]);
  
