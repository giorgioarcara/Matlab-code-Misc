%% ADJUST NOISE
% adjust noise of two subjects (with problems on noise)
%



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
% Start a new report
% Input files
sFiles = [];
SubjectNames = {...
    'All'};

%% SUBJECT NP807


%%% FIRST NOISE

Noise_File = {'NP807/@rawNP807_SysTest_20171023_01_clean_resample/data_0raw_NP807_SysTest_20171023_01_clean_resample.mat'};

% Process: Set bad channels
Res = bst_process('CallProcess', 'process_channel_setbad', Noise_File, [], ...
    'sensortypes', 'MLC22');


Res = bst_process('CallProcess', 'process_noisecov', Noise_File, [], ...
    'baseline',       [], ...
    'datatimewindow', [,], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       0, ...
    'copysubj',       0, ...
    'replacefile',    1); 

Noise1_path = 'NP807/@rawNP807_SysTest_20171023_01_clean_resample/';
[sNoise, iNoise]=bst_get('Study', [Noise1_path, 'brainstormstudy.mat']);

Dest1 = 'NP807/NP807_ISRRestingEO_20171023_01_resample/brainstormstudy.mat';
Dest2 = 'NP807/NP807_ISRRestingEO_20171023_02_resample/brainstormstudy.mat';
Dest3 = 'NP807/NP807_ISRRestingEC_20171023_01_resample/brainstormstudy.mat';
Dest4 = 'NP807/NP807_ISRProse_20171023_01_resample/brainstormstudy.mat';

[temp, iDest1]=bst_get('Study',Dest1);
[temp, iDest2]=bst_get('Study',Dest2);
[temp, iDest3]=bst_get('Study',Dest3);
[temp, iDest4]=bst_get('Study',Dest4);

db_set_noisecov(iNoise, [iDest1, iDest2, iDest3, iDest4], 0, 1)

db_reload_database('current');

%% NP810


sFiles = {...
    'NP810/@rawNP810_SysTest_20171030_01_clean_resample/data_0raw_NP810_SysTest_20171030_01_clean_resample.mat'};

% Start a new report
bst_report('Start', sFiles);

% Process: Compute covariance (noise or data)
sFiles = bst_process('CallProcess', 'process_noisecov', sFiles, [], ...
    'baseline',       [8, 119.998], ...
    'datatimewindow', [0, 119.998], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       1, ...
    'copysubj',       0, ...
    'replacefile',    1);  % Replace



%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, [])
