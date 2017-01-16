% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports';
export_folder1='Graphics'

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


%% SELECT THE FILE BY COMMENT
%
my_sFiles_string={'grandaverage'}

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname', 'Group_analysis', ...
    'includeintra',  1,...
    'tag',         my_sFiles_string{1});



% Process: Scouts time series: G_Ins_lg_and_S_cent_ins L G_Ins_lg_and_S_cent_ins R G_and_S_cingul-Ant L G_and_S_cingul-Ant R G_and_S_cingul-Mid-Ant L G_and_S_cingul-Mid-Ant R
Res = bst_process('CallProcess', 'process_extract_scout', my_sFiles_ini, [], ...
    'timewindow',     [-0.3, 0.6], ...
    'scouts',         {'Destrieux', {'G_temporal_middle R', 'G_temporal_middle L', 'G_front_middle L', 'G_front_middle R', 'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'G_parietal_sup L', 'G_parietal_sup R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'}}, ...
    'scoutfunc',      1, ...  % Mean
    'concatenate',    0, ...
    'save',           1, ...
    'addrowcomment',  1, ...
    'addfilecomment', 1);
