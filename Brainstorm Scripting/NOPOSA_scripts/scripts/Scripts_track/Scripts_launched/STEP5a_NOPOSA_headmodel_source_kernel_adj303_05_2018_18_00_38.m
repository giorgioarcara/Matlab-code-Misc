%% GENERATE HEAD MODEL AND CALCULATE SOURCE KERNEL (ONLY SUBJECT 07), missing for some reasons
% This script generate the head model and then calculate the source kernel
% 1) generate head model (BEM, it assumenes that BEM surfaces are available)
% 2) calculate source inversion kernel (wMNE, fixed orient).


%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath')

cd(curr_path)
addpath('functions')


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



% Input files
sFiles = [];
% SubjectNames = {...
%     'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);


my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'standard_adj');
my_sFiles = sel_files_bst(my_sFiles, 'MMN');
my_sFiles = sel_files_bst(my_sFiles, '_02');


%% SELECT HERE THE CORRECT FILES
sel_subjects = {'NP807|NP810'};


Subj_grouped = group_by_str_bst(my_sFiles, sel_subjects);

%% !! LEAVE THIS IN CASE I WANT TO DIVIDE BY RUN
%% DIVIDE BY RUN
% get study names for each file
study_names = cell (1, length(Subj_grouped));
for iSubj = 1: length(Subj_grouped);
    for iFile = 1:length(Subj_grouped{iSubj});
        study_names{iSubj}{iFile} = bst_fileparts(Subj_grouped{iSubj}{iFile});
    end;
end;

% get unique and divide in
Subj_cond=cell (1, length(Subj_grouped));
for iSubj = 1: length(Subj_grouped);
    Subj_cond{iSubj} = group_by_str_bst(Subj_grouped{iSubj}, unique(study_names{iSubj}));
end


% begin loop 
for iSubj=1:length(Subj_grouped)
    
    nruns = length(Subj_cond{iSubj})
    
    %% check to see if you want to perform the model
    
    if nruns > 0;
    
    for iRun = 1:nruns
        
        % NOTE: take just one file for run
        curr_file = Subj_cond{iSubj}{iRun}{1};
        
        bst_report('Start', curr_file);
        
        %COMPUTE HEAD MODEL (BEM)
        Res = bst_process('CallProcess', 'process_headmodel', curr_file, [], ...
            'Comment',     '', ...
            'sourcespace', 1, ...  % Cortex surface
            'volumegrid',  struct(...
            'Method',        'isotropic', ...
            'nLayers',       17, ...
            'Reduction',     3, ...
            'nVerticesInit', 4000, ...
            'Resolution',    0.005, ...
            'FileName',      ''), ...
            'meg',         4, ...  % OpenMEEG BEM
            'eeg',         1, ...  %
            'ecog',        1, ...  %
            'seeg',        1, ...  %
            'openmeeg',    struct(...
            'BemFiles',     {{}}, ...
            'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
            'BemCond',      [1, 0.0125, 1], ...
            'BemSelect',    [1, 1, 1], ...
            'isAdjoint',    0, ...
            'isAdaptative', 1, ...
            'isSplit',      0, ...
            'SplitLength',  4000));
        
        %         % Process: Compute head model
        %         Res = bst_process('CallProcess', 'process_headmodel', curr_file, [], ...
        %             'Comment',     'Overlapping Spheres', ...
        %             'sourcespace', 2, ...  % MRI volume
        %             'volumegrid',  struct(...
        %             'Method',        'isotropic', ...
        %             'nLayers',       17, ...
        %             'Reduction',     3, ...
        %             'nVerticesInit', 4000, ...
        %             'Resolution',    0.005, ...
        %             'FileName',      []), ...
        %             'meg',         3, ...  % Overlapping spheres
        %             'eeg',         1, ...  %
        %             'ecog',        1, ...  %
        %             'seeg',        1, ...  %
        %             'openmeeg',    struct(...
        %             'BemSelect',    [1, 1, 1], ...
        %             'BemCond',      [1, 0.0125, 1], ...
        %             'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
        %             'BemFiles',     {{}}, ...
        %             'isAdjoint',    0, ...
        %             'isAdaptative', 1, ...
        %             'isSplit',      0, ...
        %             'SplitLength',  4000));
        
        % Process: Compute sources
        Res2 = bst_process('CallProcess', 'process_inverse', curr_file, [], ...
            'Comment',     '', ...
            'method',      1, ...  % Minimum norm estimates (wMNE)
            'wmne',        struct(...
            'NoiseCov',      [], ...
            'InverseMethod', 'wmne', ...
            'ChannelTypes',  {{}}, ...
            'SNR',           3, ...
            'diagnoise',     0, ...
            'SourceOrient',  {{'fixed'}}, ...
            'loose',         0.2, ...
            'depth',         1, ...
            'weightexp',     0.5, ...
            'weightlimit',   10, ...
            'regnoise',      1, ...
            'magreg',        0.1, ...
            'gradreg',       0.1, ...
            'eegreg',        0.1, ...
            'ecogreg',       0.1, ...
            'seegreg',       0.1, ...
            'fMRI',          [], ...
            'fMRIthresh',    [], ...
            'fMRIoff',       0.1, ...
            'pca',           1), ...
            'sensortypes', 'MEG', ...
            'output',      1);  % Kernel only: shared
        
        
        
        % Save and display report
        ReportFile = bst_report('Save', Res2);
        bst_report('Open', ReportFile);
        bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
        
    end; % end run
    end % end if nruns
end;


%% BACKUP SCRIPT AND OBJECT WITH DATA



export_script(script_name, SubjectNames)
