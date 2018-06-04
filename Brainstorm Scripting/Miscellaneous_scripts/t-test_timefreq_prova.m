% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/Scout_run_average_ERSERD';


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

% IMPORTANT: I want to confine my analysis on Group analysis (the project
% on default data).



%% SELECT  TRIALS
% 
initial_files=[];

my_sFiles_string={'| ersd'}

    % make the first selection with bst process

% Process: Select results files in: Group_analysis/*/Second_Corr
my_sel_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', initial_files, [], ...
    'subjectname',   'All', ...
    'condition',     '', ...
    'tag',           my_sFiles_string{1}, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);



my_sel_sFiles=sel_files_bst({ my_sel_sFiles_ini(:).FileName }, 'average');


%% SEPARATE FILES ONLY BY CONDITION
Conditions={'Fast18','Slow18'};
Condition_grouped={};

Condition_grouped=group_by_str_bst(my_sel_sFiles, Conditions);

Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');

Condition_grouped{1}(:)
Condition_grouped{2}(:)


% Start a new report
bst_report('Start', Condition_grouped{1});


% Process: t-test paired [-2.000s,3.700s 1-150Hz]          H0:(A=B), H1:(A<>B)
Res = bst_process('CallProcess', 'process_test_parametric2p', Condition_grouped{1}, Condition_grouped{2}, ...
    'timewindow',    [-2, 2], ...
    'freqrange',     [1, 150], ...
    'rows',          '', ...
    'isabs',         0, ...
    'avgtime',       0, ...
    'avgrow',        0, ...
    'avgfreq',       0, ...
    'matchrows',     1, ...
    'Comment',       '', ...
    'test_type',     'ttest_paired', ...  % Paired Student's t-test        (A-B)~N(m,v)t = mean(A-B) / std(A-B) * sqrt(n)      df=n-1
    'tail',          'two');  % Two-tailed

% Save and display report
ReportFile = bst_report('Save', Res);

    
