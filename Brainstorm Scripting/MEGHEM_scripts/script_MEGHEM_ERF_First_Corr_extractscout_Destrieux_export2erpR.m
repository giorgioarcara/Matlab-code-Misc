% launch brainstorm, with no gui (but only if is not already running)
clear

if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='export_erpR_ERF'

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
my_sFiles_string='First_corr'

% Process: Select results (i.e., select source data)
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_matrix', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ... % include intra as I select average of runs
    'includecommon', 0);



%% !!!! DA DATERMINARE COME FARE SELEZIONE

my_sel_sFiles=sel_files_bst({my_sFiles_ini.FileName}, 'ver4_Destrieux');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, 'zscore');

% TO BE DEFINED BETTER!!


%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials
Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'Fast18', 'Slow18'} 
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;



%% EXTRACT SCOUTS AND EXPORT TO erpR FORMAT
% notice I have to loop over subjects, otherwise in extracting values
% values from different subjects are concatenated together.
my_tag='Destrieux_First_';

% loop over subjects
for iSubj=1:length(SubjectNames)
    
    %loop over Conditions
    for iCond=1:length(Conditions);
        % Start a new report
        bst_report('Start', Subj_Condition{iSubj}{iCond});
        
        % Process: export to erpR
        Res = bst_process('CallProcess', 'process_export_erpR', Subj_Condition{iSubj}{iCond}, [], ...
            'base',       [my_tag, Conditions{iCond}], ...
            'chars',      70, ...
            'BadChans',   1 );
        
        % Save and export report for deleting and extracting
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
    end;
    
end;




