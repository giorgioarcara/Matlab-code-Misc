clear all

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='PROVE'

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


%% SELECT  TRIALS
%
my_sFiles_string='Second_Corr_'

% Process: Select timefreq files in: */Freqbands
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);


my_sel_sFiles=sel_files_bst({my_sFiles_ini.FileName}, 'average');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, 'smooth');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, '.', 'MH013');

%% DIVIDE BY CONDITION
Conditions={'Fast18', 'Slow18'};

Condition_grouped=group_by_str_bst( my_sel_sFiles , Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');



my_scouts={'Destrieux', {'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'G_parietal_sup L', 'G_parietal_sup R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'}}
%my_scouts={'Destrieux', {'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R'}};

%%
% Start a new report
bst_report('Start', Condition_grouped{1});

% Process: Perm t-test paired [0ms, 400ms]          H0:(A=B), H1:(A<>B)
% Process: FT t-test paired cluster [-2.000s,2.000s]          H0:(A=B), H1:(A<>B)
Res = bst_process('CallProcess', 'process_ft_sourcestatistics', Condition_grouped{1}, Condition_grouped{2}, ...
    'timewindow',     [-2, 2], ...
    'scoutsel',       my_scouts, ...
    'scoutfunc',      3, ...  % All
    'isabs',          0, ...
    'avgtime',        1, ...
    'randomizations', 1000, ...
    'statistictype',  2, ...  % Paired t-test
    'tail',           'two', ...  % Two-tailed
    'correctiontype', 2, ...  % cluster
    'minnbchan',      2, ...
    'clusteralpha',   0.05);


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


        
        
        
        
        







