% launch brainstorm, with no gui (but only if is not already running)
clear

if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='TF_exploration'

if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
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


%% ADD SPECIFIC TAG TO ALL FILES CREATED

%% SELECT  TRIALS
%
my_sFiles_string='Avg: 3 files | | scout'

% Process: Select timefreq files in: */Freqbands
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, 'ersd');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, '.', 'MH013');

%% TAG
my_tag='explore'

%% DIVIDE BY CONDITION
Conditions={'Fast18', 'Slow18'};

Condition_grouped=group_by_str_bst(my_sel_sFiles, Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');


my_scout_names= {'G_temporal_middle R', 'G_temporal_middle L', 'G_front_middle L', 'G_front_middle R', 'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R', 'G_parietal-sup L', 'G_parietal-sup R' };
my_scout_strings=strjoin(my_scout_names,', ') % NOTE: this is necessary cause t-test process expect a single string with all ROI (and not a cell as usual).


% Start a new report
bst_report('Start', Condition_grouped{1});

Res = bst_process('CallProcess', 'process_test_parametric2p', Condition_grouped{1}, Condition_grouped{2}, ...
    'timewindow',    [0, 1.3], ...
    'freqrange',     [1, 150], ...
    'rows',          my_scout_strings, ...
    'isabs',         0, ...
    'avgtime',       0, ...
    'avgrow',        0, ...
    'avgfreq',       0, ...
    'matchrows',     1, ...
    'Comment',       '', ...
    'test_type',     'ttest_paired', ...  % Paired Student's t-test        (A-B)~N(m,v)t = mean(A-B) / std(A-B) * sqrt(n)      df=n-1
    'tail',          'two');  % Two-tailed

% Process: Add tag to comment.
Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
    'tag',  [my_sFiles_string, my_tag]   , ...
    'output', 1);  % Add to comment

% Process: Add tag to comment.
Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
    'tag',  [my_sFiles_string, my_tag]   , ...
    'output', 2);  % Add to name


% Save and display report
ReportFile = bst_report('Save', Res);
bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);






