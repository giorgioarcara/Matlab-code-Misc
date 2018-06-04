% launch brainstorm, with no gui (but only if is not already running)
clear

if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='export_erpR_TF_scout'

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
my_tag=[];

%% SELECT  TRIALS
%
my_sFiles_string='ersd'

% Process: Select timefreq files in: */Freqbands
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, 'average', '_ver2');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, 'scout');



%% SEPARATE FILES BY CONDITION
Conditions={'Fast18','Slow18'} 

Condition_grouped=group_by_str_bst(my_sel_sFiles, Conditions); 
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');


%% EXPOR TO ERPR FORMAT

%loop over Conditions
for iCond=1:length(Conditions);
    % Start a new report
    bst_report('Start', Condition_grouped{iCond});
    
    % Process: export to erpR
    Res = bst_process('CallProcess', 'process_export_erpR', Condition_grouped{iCond}, [], ...
        'base',       Conditions{iCond}, ...
        'chars',      70, ...
        'BadChans',   1 );
    
    % Save and export report for deleting and extracting
    ReportFile = bst_report('Save', Res);
    bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
end;




