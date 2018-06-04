% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='Perm_t-test';


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

% Start a new report
bst_report('Start', Condition_grouped{1});


%% DEFINE INTERVALS TO BE ANALIZED
intervals={[0.1 0.2], [0.2 0.3], [0.3 0.4]}


for i=1:length(intervals)
    % Process: Perm t-test paired [0ms,100ms]          H0:(A=B), H1:(A<>B)
    Res = bst_process('CallProcess', 'process_test_permutation2p', Condition_grouped{1},  Condition_grouped{2}, ...
        'timewindow',     [intervals{i}(1),intervals{i}(2)], ...
        'scoutsel',       {}, ...
        'scoutfunc',      1, ...  % Mean
        'isnorm',         0, ...
        'avgtime',        1, ...
        'iszerobad',      1, ...
        'Comment',        '', ...
        'test_type',      'ttest_paired', ...  % Paired Student's t-test T = mean(A-B) / std(A-B) * sqrt(n)
        'randomizations', 1000, ...
        'tail',           'two');  % Two-tailed
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    bst_report('Export', ReportFile, [export_main_folder, export_folder]);
end;


