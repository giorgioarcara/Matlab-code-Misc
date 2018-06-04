% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='TF_project'

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

% IMPORTANT: I want to confine my analysis on Group analysis (the project
% on default data).



%% SELECT  TRIALS
%
initial_files=[];

my_sFiles_string={'First_Corr'}

% make the first selection with bst process

% Process: Select results files in: Group_analysis/*/Second_Corr
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', initial_files, [], ...
    'subjectname',   'All', ...
    'condition',     '', ...
    'tag',           my_sFiles_string{1}, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, 'hilbert');





%% SEPARATE FILES FOR Condition
Conditions={'Fast18', 'Slow18'};
Conditions_grouped=group_by_str_bst(my_sel_sFiles, Conditions);


%%% CORRECTION FOR SUBJECT MH005
% is not necessary because it has been already done in the script Step1


%% LOOP OVER CONDITIONS (necessary to add the correct tags)

for iCond=1:length(Conditions)
    
    curr_files=Conditions_grouped{iCond};
    
    bst_report('Start', curr_files);
    
    
    Res = bst_process('CallProcess', 'process_project_sources', curr_files, [], ...
        'headmodeltype', 'surface');  % Cortex surface
    
    % Process: Spatial smoothing (3.00,abs)
    Res = bst_process('CallProcess', 'process_ssmooth_surfstat', Res, [], ...
        'fwhm',       3, ...
        'overwrite',  1, ...
        'source_abs', 1);
    
    % Process: Add tag to name.
    Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
        'tag',  ['_whole_', Conditions{iCond}]   , ...
        'output', 2);  % Add to name
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    %bst_report('Open', ReportFile);
    bst_report('Export', ReportFile,  [export_main_folder, '/', export_folder1]);
end;





