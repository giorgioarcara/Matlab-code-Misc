% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Brainstorm_Reports/';
export_folder='Exp_numerosity2';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Exp_numerosity2_merged';

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
my_sFiles_string='p_'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string);


my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'average');
my_sFiles = sel_files_bst(my_sFiles, 'p_');


%% DIVIDE BY CONDITION
Conditions={'m_qualche_sg', 'm_un_sg'};

Condition_grouped=group_by_str_bst( my_sFiles, Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'sj00..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'sj00..');


%%
% Start a new report
bst_report('Start', Condition_grouped{1});

% Process: t-test paired [all]          H0:(A=B), H1:(A<>B)
Res = bst_process('CallProcess', 'process_test_parametric2p', Condition_grouped{1}, Condition_grouped{2}, ...
    'timewindow',    [], ...
    'sensortypes',   '', ...
    'isabs',         0, ...
    'avgtime',       0, ...
    'avgrow',        0, ...
    'Comment',       '', ...
    'test_type',     'ttest_paired', ...  % Paired Student's t-test        (A-B)~N(m,v)t = mean(A-B) / std(A-B) * sqrt(n)      df=n-1
    'tail',          'two');  % Two-tailed



% Save and display report
ReportFile = bst_report('Save', Res);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);





