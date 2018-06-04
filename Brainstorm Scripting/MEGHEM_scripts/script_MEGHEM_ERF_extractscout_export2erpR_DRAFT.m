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
my_sFiles_string='Second_corr'

% Process: Select results (i.e., select source data)
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ... % include intra as I select average of runs
    'includecommon', 0);



%% !!!! DA DATERMINARE COME FARE SELEZIONE

my_sel_sFiles=sel_filesbyComment_bst(my_sFiles_ini, 'Fast18|Slow18');

% TO BE DEFINED BETTER!!


%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials
Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'First18', 'Slow18'} 
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;


my_scouts={'Destrieux', {'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'G_parietal_sup L', 'G_parietal_sup R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'}}
%my_scouts={'Destrieux', {'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R'}};


%% EXTRACT SCOUTS AND EXPORT TO erpR FORMAT
% notice I have to loop over subjects, otherwise in extracting values
% values from different subjects are concatenated together.


% loop over subjects
for iSubj=1:length(SubjectNames)
    
    %loop over Conditions
    for iCond=1:length(Conditions);
        % Start a new report
        bst_report('Start', Condition_grouped{iCond});
        
        % Process: Extract values: [-300ms,600ms] 5 scouts
        Temp = bst_process('CallProcess', 'process_extract_values', Subj_Condition[], ...
            'timewindow', [-0.3, 0.6], ...
            'scoutsel',   my_scouts, ...
            'scoutfunc',  1, ...  % Mean
            'isnorm',     0, ...
            'avgtime',    0, ...
            'dim',        2, ...  % Concatenate time (dimension 2)
            'Comment',    '');
        
        
        % Process: export to erpR
        Res = bst_process('CallProcess', 'process_export_erpR', Condition_grouped{iCond}, [], ...
            'base',       Conditions{iCond}, ...
            'chars',      70, ...
            'BadChans',   1 );
        
        % Save and export report for deleting and extracting
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
    end;
    
end;




