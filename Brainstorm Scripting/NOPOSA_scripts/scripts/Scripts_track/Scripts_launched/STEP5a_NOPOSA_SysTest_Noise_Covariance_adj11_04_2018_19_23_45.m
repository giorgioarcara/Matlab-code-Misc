%% NOISE COVARIANCE
% this script make some adjustments for some subjects of Noise Covariance.
% In some cases I had to calculate and set different noise covariances
% (cause the subject was recorded in separate sessions, on differnet days)
% In other cases I just selected which noise to use. These case were
% because part of the recording was made with the camera turned off. In
% such cases, for sake of simplicity,I  opted for using the noise with th ecamera turned on, 
% regardless of the session.


%% PRELIMINARY PREPARATION
clear

run('NOPOSA_startpath.m')

cd(curr_path)

addpath('functions')



% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/storages/LDATA/Giorgio Mapping/Parlog Analysis/';
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
SubjectNames = {...
    'All'};

% Start a new report


%% SUBJECT NP807


%%% FIRST NOISE

Noise_File = {'NP807/@rawNP807_SysTest_20171023_01_clean_resample/data_0raw_NP807_SysTest_20171023_01_clean_resample.mat'};

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


%%% SECOND NOISE

% i take the second noise files ,the one with camera turned on

Noise_File = {...
    'NP807/@rawNP807_SysTest_20171025_02_clean_resample/data_0raw_NP807_SysTest_20171025_02_clean_resample.mat'};

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


Noise1_path = 'NP807/@rawNP807_SysTest_20171025_02_clean_resample/';
[sNoise, iNoise]=bst_get('Study', [Noise1_path, 'brainstormstudy.mat']);

Dest1 = 'NP807/NP807_NOPOSAMMN_20171025_01_resample/brainstormstudy.mat';
Dest2 = 'NP807/NP807_NOPOSAMMN_20171025_02_resample/brainstormstudy.mat';
Dest3 = 'NP807/NP807_ISRASSR_20171025_01_resample/brainstormstudy.mat';

[temp, iDest1]=bst_get('Study',Dest1);
[temp, iDest2]=bst_get('Study',Dest2);
[temp, iDest3]=bst_get('Study',Dest3);


db_set_noisecov(iNoise, [iDest1, iDest2, iDest3], 0, 1)


%% NP806

% FIRST NOISE

Noise_File = {'NP806/@rawNP806_SysTest_20171019_02_clean_resample/data_0raw_NP806_SysTest_20171019_02_clean_resample.mat'};

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

Noise1_path = 'NP806/@rawNP806_SysTest_20171019_02_clean_resample/';
[sNoise, iNoise]=bst_get('Study', [Noise1_path, 'brainstormstudy.mat']);

Dest1 = 'NP80/NP806_ISRRestingEO_20171019_01_resample/brainstormstudy.mat';
Dest2 = 'NP806/NP806_ISRRestingEO_20171019_02_resample/brainstormstudy.mat';
Dest3 = 'NP806/NP806_ISRRestingEC_20171019_01_resample/brainstormstudy.mat';
Dest4 = 'NP806/NP806_ISRProse_20171019_01_resample/brainstormstudy.mat';

[temp, iDest1]=bst_get('Study',Dest1);
[temp, iDest2]=bst_get('Study',Dest2);
[temp, iDest3]=bst_get('Study',Dest3);
[temp, iDest4]=bst_get('Study',Dest4);

db_set_noisecov(iNoise, [iDest1, iDest2, iDest3, iDest4], 0, 1)


%%% SECOND NOISE

% i take the second noise files ,the one with camera turned on


Noise_File = {'NP806/@rawNP806_SysTest_20171024_01_clean_resample/data_0raw_NP806_SysTest_20171024_01_clean_resample.mat'};

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

Noise1_path = 'NP806/@rawNP806_SysTest_20171024_01_clean_resample/';
[sNoise, iNoise]=bst_get('Study', [Noise1_path, 'brainstormstudy.mat']);

Dest1 = 'NP80/NP806_NOPOSAMMN_20171024_01_resample/brainstormstudy.mat';
Dest2 = 'NP806/NP806_NOPOSAMMN_20171024_02_resample/brainstormstudy.mat';
Dest3 = 'NP806/NP806_ISRASSR_20171024_02_resample/brainstormstudy.mat';


[temp, iDest1]=bst_get('Study',Dest1);
[temp, iDest2]=bst_get('Study',Dest2);
[temp, iDest3]=bst_get('Study',Dest3);

db_set_noisecov(iNoise, [iDest1, iDest2, iDest3], 0, 1)


%% NP817
Noise_File = {'NP817/@rawNP817_SysTest_20171109_01_clean_resample/data_0raw_NP817_SysTest_20171109_01_clean_resample.mat'};

Res = bst_process('CallProcess', 'process_noisecov', Noise_File, [], ...
    'baseline',       [], ...
    'datatimewindow', [,], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       1, ...
    'copysubj',       0, ...
    'replacefile',    1); 

%% NP822
Noise_File = {'NP822/@rawNP822_SysTest_20171120_02_clean_resample/data_0raw_NP822_SysTest_20171120_02_clean_resample.mat'};

Res = bst_process('CallProcess', 'process_noisecov', Noise_File, [], ...
    'baseline',       [], ...
    'datatimewindow', [,], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       1, ...
    'copysubj',       0, ...
    'replacefile',    1); 


%% NP827
Noise_File = {'NP827/@rawNP827_SysTest_20171219_02_clean_resample/data_0raw_NP827_SysTest_20171219_02_clean_resample.mat'};

Res = bst_process('CallProcess', 'process_noisecov', Noise_File, [], ...
    'baseline',       [], ...
    'datatimewindow', [,], ...
    'sensortypes',    'MEG', ...
    'target',         1, ...  % Noise covariance     (covariance over baseline time window)
    'dcoffset',       1, ...  % Block by block, to avoid effects of slow shifts in data
    'identity',       0, ...
    'copycond',       1, ...
    'copysubj',       0, ...
    'replacefile',    1); 



%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, [])
