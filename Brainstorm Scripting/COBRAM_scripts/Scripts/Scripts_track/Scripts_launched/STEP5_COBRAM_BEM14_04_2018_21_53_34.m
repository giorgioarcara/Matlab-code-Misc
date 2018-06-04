%% GENERATE BEM
%This script generates BEM model for selected Subjects

%% PRELIMINARY PREPARATION
clear

run('COBRAM_startpath.m')

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
ProtocolName = 'COBRAM_analysis1';

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
SubjectNames = sel_files_bst({my_subjects.Subject.Name}, 'COB01|COB02|COB03|COB04|COB05|COB06|COB07|COB08|COB09|COB10|COB11', 'Default');

%% CALCULATE BEM


for iSubj=1:length(SubjectNames);
    
    % Start a new report
    bst_report('Start', sFiles);
    
    % Process: Generate BEM surfaces
    Res = bst_process('CallProcess', 'process_generate_bem', sFiles, [], ...
        'subjectname', SubjectNames{iSubj}, ...
        'nscalp',      1922, ...
        'nouter',      1922, ...
        'ninner',      1922, ...
        'thickness',   4);
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    bst_report('Open', ReportFile);
    bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
end

%% BACKUP SCRIPT AND OBJECT WITH DATA



export_script(script_name, SubjectNames)
