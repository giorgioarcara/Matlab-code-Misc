% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='First_Average_Filter';


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
my_sFiles_string={'First_Corr_'}

  for iCondition=1:length(my_sFiles_string)
    % make the first selection with bst process
    my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
        'subjectname', 'All', ...
        'includeintra',  0,...
        'tag',         my_sFiles_string{iCondition});


    my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');


end;




%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);

%% SEPARATE FILES BY RUN
runs={'_01_','_02_', '_03_'} 
Subj_run={};


for iSubj=1:length(Subj_grouped)
    
    Subj_run{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, runs); % IMPORTANT: notice I enter in the cell {}
    
end;

%%% CORRECTION FOR SUBJECT MH005
% Subject 05, has run _01_, _03_ and _04
Subj_run{5}{2}=Subj_run{5}{3} % put run 3 in cell 2
other_run=sel_files_bst(my_sel_sFiles, '(MH005/)([\w]+)(_04_)'); % \w match for all alphanumeric characters

Subj_run{5}{3}=other_run;


%% SEPARATE FILES BY CONDITION
Conditions={'Fast18','Slow18'} 
Subj_run_Condition={}

for iSubj=1:length(Subj_grouped)
    for irun=1:length(runs)
    Subj_run_Condition{iSubj}{irun}=group_by_str_bst(Subj_run{iSubj}{irun}, Conditions); % IMPORTANT: notice I enter in the cell {}   
    end;
end;



%% AVERAGE OF FIRST TRIAL (FAST VS SLOW)
for iSubj=1:length(SubjectNames)
    for irun=1:length(runs)
        for iCond=1:length(Conditions)
         
         % select files 
        curr_files=Subj_run_Condition{iSubj}{irun}{iCond};
        
        % Start a new report
        bst_report('Start', curr_files);
        
        % Process: Average: Everything
        Res = bst_process('CallProcess', 'process_average', curr_files, [], ...
            'avgtype',    1, ...  % Everything
            'avg_func',   1, ...  % Arithmetic average:  mean(x)
            'weighted',   0, ...
            'keepevents', 0);
        
        % Process: DC offset correction: [-200ms,0ms]
        Res = bst_process('CallProcess', 'process_baseline', Res, [], ...
            'baseline',    [-0.2, 0], ...
            'sensortypes', 'MEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'overwrite',   1);
        
        % low pass filter 40 Hz
        % Process: Low-pass:40Hz
        Res = bst_process('CallProcess', 'process_bandpass', Res, [], ...
            'sensortypes', 'MEG', ...
            'highpass',    0, ...
            'lowpass',     40, ...
            'attenuation', 'strict', ...  % 60dB
            'mirror',      1, ...
            'useold',      0, ...
            'overwrite',   1);
        
        % Save and display report
        ReportFile = bst_report('Save', Res);
        
        bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
        
        end;
    end;
end;


