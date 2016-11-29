% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='Run_Average_Project';


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
my_sFiles_string='MN'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, 'average');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, 'First_Corr');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, '(low)');




%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY CONDITION
Conditions={'Fast18','Slow18'} 
Subj_Condition={};

for iSubj=1:length(Subj_grouped)
    
    Subj_Condition{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, Conditions); % IMPORTANT: notice I enter in the cell {}
    
end;

%% AVERAGE 3 RUN - Z-SCORE - EXTRACT time - PROJECT - SPATIAL SMHOOTHING
for iSubj=1%%length(SubjectNames)
        for iCond=1:length(Conditions)
         
            % select files
            curr_files=Subj_Condition{iSubj}{iCond};
            
            % Start a new report
            bst_report('Start', curr_files);
            
            % Process: Weighted Average: Everything
            Res = bst_process('CallProcess', 'process_average', curr_files, [], ...
                'avgtype',         1, ...  % Everything
                'avg_func',        1, ...  % Arithmetic average:  mean(x)
                'weighted',        1, ...
                'scalenormalized', 0);
            
            % Process: Z-score transformation: [-200ms,0ms]
            Res = bst_process('CallProcess', 'process_baseline_norm', Res, [], ...
                'baseline',   [-0.2, 0], ...
                'source_abs', 0, ...
                'method',     'zscore', ...  % Z-score transformation:    x_std = (x - &mu;) / &sigma;
                'overwrite',  1);
            
            % Process: Extract time: [-300ms,600ms] (and overwrite to save
            % space).
            Res = bst_process('CallProcess', 'process_extract_time', Res, [], ...
                'timewindow', [-0.3, 0.6], ...
                'overwrite',  1);
            
            Res = bst_process('CallProcess', 'process_project_sources', Res, [], ...
                'headmodeltype', 'surface');  % Cortex surface
            
            ReportFile = bst_report('Save', Res);
            % Process: Spatial smoothing (3.00,abs)
            Res = bst_process('CallProcess', 'process_ssmooth_surfstat', Res, [], ...
                'fwhm',       3, ...
                'overwrite',  1, ...
                'source_abs', 1);
            
             % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  ['whole']   , ...
            'output', 1);  % Add to comment
        
          % Process: Add tag to comment.
            Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [ '_whole_', Conditions{iCond}]   , ...
            'output', 2);  % Add to name
            
            
            % add file info to the file
            FileName = file_fullpath(Res(1).FileName);
            FileMat.Add_info=curr_files;
            % Save file
            bst_save(FileName, FileMat, 'v6', 1);
            
            
            bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
            
        end;
    end;


