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
my_tag='_ver2';

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



%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials
Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'First_corr'} 
Subj_Condition={}

for iSubj=1:length(Subj_grouped)
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}   
end;


%loop over Subjects (necessary, otherwise it will concatenate all Subjects
%in a single file.)
for iSubj=1:length(SubjectNames);
    
    for iCond=1:length(Conditions);
        % Start a new report
               
        bst_report('Start', Subj_Condition{iSubj}{iCond});
        
        % Process: Extract values: [-2.000s,3.700s] 1-150Hz
        Res = bst_process('CallProcess', 'process_extract_values', Subj_Condition{iSubj}{iCond}, [], ...
            'timewindow', [-2, 3.7], ...
            'freqrange',  [1, 150], ...
            'rows',       '', ...
            'isabs',      0, ...
            'avgtime',    0, ...
            'avgrow',     0, ...
            'avgfreq',    1, ...
            'matchrows',  0, ...
            'dim',        2, ...  % Concatenate time (dimension 2). Notice: if I concatenate signals. The name of subjects is added to the label.
            'Comment',    '');
   
              
        % Process: export to erpR
        Res1 = bst_process('CallProcess', 'process_export_erpR', Res, [], ...
            'base',       Conditions{iCond}, ...
            'chars',      70, ...
            'BadChans',   1 );
        
        % export report for erpR exporting
        ReportFile = bst_report('Save', Res1);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
        
        % Process: Delete Extract Values Files
        Res = bst_process('CallProcess', 'process_delete', Res, [], ...
    'target', 1);  % Delete selected files
           
        % Save and export report for deleting and extracting
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
    end;
end;




