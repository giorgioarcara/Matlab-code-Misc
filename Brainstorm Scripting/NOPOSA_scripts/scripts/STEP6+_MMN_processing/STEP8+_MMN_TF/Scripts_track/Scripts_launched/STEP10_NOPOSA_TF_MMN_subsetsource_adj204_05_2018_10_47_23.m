%% Time Frequency
% 1) Calculate TF at source level on given frequency
% 2) TF is separate long and short session (with bst loops)
% 3) other loops are made separately for subjects,


%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath')

cd(curr_path)
addpath(genpath('functions'))


% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder=curr_path;
export_folder='Reports';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;


%% GET CURRENT SCRIPT NAME

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

%%



%% SET PROTOCOL
ProtocolName = 'NOPOSA_analysis1';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')


%% SELECT FILES WITH BRAINSTORM FUNCTION
% select all files

% Input files
sFiles = [];


%% SELECT SUBJECT NAMES (note that only subject names are used to calculate bem).
SubjectNames = sel_files_bst({my_subjects.Subject.Name}, '.');

%% SELECT FILES
% select all files

% Input files
sFiles = [];
% SubjectNames = {...
%     'All'};

%% LOOP OVER SHORT/LONG

% I use the selection by comment of bst cause I could not add the tag to the comment
Session_names={'long', 'short'};

for iSession=1:length(Session_names);
    
    % Process: Select data files in: */*
    my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
        'subjectname',   SubjectNames, ...
        'condition',     '', ...
        'tag',           Session_names{iSession}, ...
        'includebad',    0, ...
        'includeintra',  0, ...
        'includecommon', 0);
    
    my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'standard_adj|deviant_adj');
    
    
    %% SELECT HERE THE CORRECT FILES
    sel_subjects = 'NP807|NP810';
    SubjectNames = sel_files_bst(SubjectNames, sel_subjects);
    
    % select only files of the selected subjects (to be sure to exclude group
    % analysis).
    my_sFiles = sel_files_bst(my_sFiles, sel_subjects);
    
    
    %% DIVIDE BY SUBJECTS
    Subj_grouped = group_by_str_bst(my_sFiles, SubjectNames);
    
    % divide by condition
    cond_names={'deviant_adj', 'standard_adj'};
    run_names = {'_01', '_02'}; % i create this cause I want to be sure to have two files.
    
    Subj_cond = cell (1, length(Subj_grouped));
    for iSubj = 1: length(Subj_grouped);
        Subj_cond{iSubj} = group_by_str_bst(Subj_grouped{iSubj}, cond_names);
    end
    
    % TO EXCLUDE SOME SUBJECTS
    % my_sFiles = sel_files_bst(my_sFiles, '.', 'S001_|S002_');
    my_tag = ['subsetsour'] % NOTE! I dont's use subsetsource, so "source" is not included in this tag
    
    % loop over subjects
    for iSubj = 1:length(SubjectNames)
        
        iCond=2; % i removed a loop cause I want only standard
        
        % get only standard wich are
        curr_files_ini=Subj_cond{iSubj}{2};
        % DETERMINE NUMBER OF FILES TO TAKE FROM THE SELECTED FILES IN
        % DEVIANT (so the number is exactly the same)
        n_files_to_take = length(Subj_cond{iSubj}{1});
        
        
        % Start a new report
        bst_report('Start', curr_files_ini);
        
        % Process: Select 30 files (uniform)
        curr_files = bst_process('CallProcess', 'process_select_subset', curr_files_ini, [], ...
            'nfiles', n_files_to_take, ...
            'method', 4);  % Uniformly distributed
        
        curr_files = {curr_files.FileName};
        
        
        %% RETRIEVE SOURCE (LINK) FILES
        % retrieve condition path
        curr_study=bst_get('StudyWithCondition', bst_fileparts(curr_files{1}));
        
        % exclude with the following steps the empty filenames, in the
        % ResultFile, otherwise cannot use intersect
        no_empty_DataFile_ind=find(~cellfun(@isempty, {curr_study.Result.DataFile}));
        no_empty_Resultfile=curr_study.Result(no_empty_DataFile_ind);
        
        % find intersection between curr-files (the data to be processed)
        % and the non-empty Resultfile names
        [a ind_curr_files ind_no_empty_Resultfile]=intersect(curr_files, {no_empty_Resultfile.DataFile});
        
        % retrieve link_files
        link_files={no_empty_Resultfile(ind_no_empty_Resultfile).FileName};
        
        
        % Start a new report
        bst_report('Start', link_files);
        
        % Process: Hilbert transform
        Res = bst_process('CallProcess', 'process_hilbert', link_files, [], ...
            'clusters',  {}, ...
            'scoutfunc', 1, ...  % Mean
            'edit',      struct(...
            'Comment',         ['Avg,Magnitude,', my_tag, ',', cond_names{iCond}, ',', Session_names{iSession}], ...
            'TimeBands',       [], ...
            'Freqs',           {{'theta', '4,7', 'mean'; 'alpha', '8,12', 'mean'; 'beta', '13, 30', 'mean'; 'low_gamma', '30, 60', 'mean'; 'high_gamma', '60, 80', 'mean'}}, ...
            'ClusterFuncTime', 'none', ...
            'Measure',         'Magnitude', ...
            'Output',          'average', ...
            'RemoveEvoked',    0, ...
            'SaveKernel',      0), ...
            'normalize', 'none', ...  % None: Save non-standardized time-frequency maps
            'mirror',    0);
        
        
        
        % Process: Add tag: Response_adj
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',    [my_tag, '_', cond_names{iCond}, '_', Session_names{iSession}], ...
            'output', 2);  % Add to filename
        
        
        
        % Save and display report
        ReportFile = bst_report('Save', curr_files);
        bst_report('Open', ReportFile);
        bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
        
    end;
end;
%% BACKUP SCRIPT AND OBJECT WITH DATA


export_script(script_name, my_sFiles_ini)
