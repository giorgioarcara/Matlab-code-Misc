%% STEP 1 COBRAM
% This script starts from a protocol (already created)
% with all files of all subjects
%
% 1) Import data
% 2) Convert epoched data to continuous
% 3) Add an end bad segment to epoched files if necessary (only in ASSR and in MMN).
% 4) downsample all fils to 600 hz
% 5) SSP depending on the file type.
% 6) Calculate PSD and save in report.

%% PRELIMINARY PREPARATION
clear

%% RUN THE SCRIPT TO SET THE PATH
run('COBRAM_startpath.m');

cd(curr_path);

addpath('functions');

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


%% SELECT FILES WITH BRAINSTORM FUNCTIN
% select all files

% Input files
SubjectNames = {...
    'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



%% SPECIFY HERE THE FILES AND THE SUBJECTS TO BE PROCESSED.

%my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'COB01|COB02|COB03|COB04|COB05|COB06|COB07|COB08|COB09|COB10');
my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'COB10|COB11|COB12|COB13');



%% PART 1 CONVERT EPOCHED FILES TO CONTINOUS

% Start a new report
bst_report('Start', my_sFiles);

for i=1:length(my_sFiles);
    
    curr_file = in_bst_data(my_sFiles{i}, 'F');
    
    if (regexpi(curr_file.F.format, '^CTF$')) % when F.format is CTF, the data are epoched
        
        % Process: Convert to continuous (CTF): Continuous
        Temp = bst_process('CallProcess', 'process_ctf_convert', my_sFiles{i}, [], ...
            'rectype', 2);  % Continuous
    end;
    
end;


%% PART 2 ADD END_BAD to EPOCHED FILES
% Script to add END_BAD events.

% THe script ADD an END_BAD event to the files. Starting from the end of
% the recordings and going backward n seconds. Useful to avoid effect of zero-padding on subsequent PSD.


% Input files
epoched_files_bad=sel_files_bst(my_sFiles, 'COBRAM');


for iFile=1:length(epoched_files_bad);
    
    % select curr_file
    curr_raw_file=epoched_files_bad{iFile};
    
    % the following parameter set the duration of the bad segments from the
    % end.
    End_dur=3; % in seconds
    
    % load the data
    sRaw=in_bst_data(curr_raw_file);
    
    % retrieve final time (end of recordings)
    End_time=sRaw.Time(end);
    
    % determine time and sample according to End_dur
    End_time_1=End_time-End_dur;
    End_time_1_ind=dsearchn(sRaw.Time', End_time_1);
    End_time_1_exact=sRaw.Time(End_time_1_ind);
    
    
    % Add new bad event %
    % !!! NOTE: at the first step the index is (end +1) cause a new
    % event is created and added to the struct. Tehn is just (end)
    sRaw.F.events(end+1).label ='End_BAD';
    sRaw.F.events(end).color = [1 0.6000 0];
    sRaw.F.events(end).epochs = 1;
    sRaw.F.events(end).times = [ End_time_1_exact; End_time ];
    sRaw.F.events(end).samples = [End_time_1_ind; length(sRaw.Time)];
    sRaw.F.events(end).select = 1;
    
    
    bst_save(file_fullpath(curr_raw_file), sRaw, 'v6', 1);
end;




%% PART 2 PREPROCESS  FILES

%% NOISE - APPLY CTF COMPENSATION -  RESAMPLE - PSD of Systest


Noise_files = sel_files_bst(my_sFiles, 'SysTest');


% Start a new report
bst_report('Start', Noise_files);


% Process: Apply SSP & CTF compensation
Noise_Res = bst_process('CallProcess', 'process_ssp_apply', Noise_files, []);

Noise_Res = bst_process('CallProcess', 'process_resample', Noise_Res, [], ...
    'freq',     600, ...
    'read_all', 0);


% Process: Power spectrum density 
Noise_Res_PSD = bst_process('CallProcess', 'process_psd', Noise_Res, [], ...
    'timewindow',  [], ...
    'win_length',  1, ...
    'win_overlap', 50, ...
    'sensortypes', 'MEG', ...
    'edit',        struct(...
    'Comment',         'Power', ...
    'TimeBands',       [], ...
    'Freqs',           [], ...
    'ClusterFuncTime', 'none', ...
    'Measure',         'power', ...
    'Output',          'all', ...
    'SaveKernel',      0));



% Save and display report
ReportFile = bst_report('Save', Noise_Res_PSD);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);




%% ALL OTHER FILES: RESAMPLE + DETECT ARTIFACT + SSP

Subj_files = sel_files_bst(my_sFiles, 'Resting|COBRAM');

% NOT INCLUDED, because it does not work properly.
% (I Tried also without bad segments, but it does not work).

% % Process: Detect movement [Experimental]
% Subj_files = bst_process('CallProcess', 'process_evt_detect_movement', Subj_files, [], ...
%     'thresh',       5, ...
%     'allowance',    5, ...
%     'fiterror',     3, ...
%     'minSegLength', 5);

bst_report('Start', Subj_files);

Subj_files = bst_process('CallProcess', 'process_resample', Subj_files, [], ...
    'freq',     600, ...
    'read_all', 0);

% Process: Detect heartbeats
Subj_files = bst_process('CallProcess', 'process_evt_detect_ecg', Subj_files, [], ...
    'channelname', 'ECG', ...
    'timewindow',  [], ...
    'eventname',   'cardiac');

%Process: Detect eye blinks -
% THIS IS EYE CLOSED. But this is done nevertheless, to identify segment
% with excessive eye movements
Subj_files = bst_process('CallProcess', 'process_evt_detect_eog', Subj_files, [], ...
    'channelname', 'VEOG', ...
    'timewindow',  [], ...
    'eventname',   'blink');

% Process: Remove simultaneous
Subj_files = bst_process('CallProcess', 'process_evt_remove_simult', Subj_files, [], ...
    'remove', 'cardiac', ...
    'target', 'blink', ...
    'dt',     0.25, ...
    'rename', 0);

% Process: SSP ECG: cardiac
Subj_files = bst_process('CallProcess', 'process_ssp_ecg', Subj_files, [], ...
    'eventname',   'cardiac', ...
    'sensortypes', 'MEG', ...
    'usessp',      0, ...
    'select',      1);


% Process: SSP EOG: blink
Subj_files = bst_process('CallProcess', 'process_ssp_eog', Subj_files, [], ...
    'eventname',   'blink', ...
    'sensortypes', 'MEG', ...
    'usessp',      1, ...
    'select',      1);

% % Process: SSP: generic. To detect eye movements in some cases
% % NOT MANDATORY!! It is important to check and apply only if necessary.
% Subj_files = bst_process('CallProcess', 'process_ssp', Subj_files, [], ...
%     'timewindow',  [0, 20], ...
%     'eventname',   '', ...
%     'eventtime',   [-0.2, 0.2], ...
%     'bandpass',    [0, 6], ...
%     'sensortypes', 'MEG', ...
%     'usessp',      1, ...
%     'saveerp',     0, ...
%     'method',      1, ...  % PCA: One component per sensor
%     'select',      1);


Res_PSD = bst_process('CallProcess', 'process_psd', Subj_files, [], ...
    'timewindow',  [], ...
    'win_length',  1, ...
    'win_overlap', 50, ...
    'sensortypes', 'MEG', ...
    'edit',        struct(...
    'Comment',         'Power', ...
    'TimeBands',       [], ...
    'Freqs',           [], ...
    'ClusterFuncTime', 'none', ...
    'Measure',         'power', ...
    'Output',          'all', ...
    'SaveKernel',      0));

% Save and display report
ReportFile = bst_report('Save', Subj_files);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);



%% COBRAM FILES - adjust trigger
COBRAM_files = sel_files_bst({Subj_files.FileName}, 'COBRAM');


bst_report('Start', COBRAM_files);


COBRAM_files = bst_process('CallProcess', 'process_evt_detect_analog', COBRAM_files, [], ...
    'eventname',   'Met_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    2, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Met', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

COBRAM_files = bst_process('CallProcess', 'process_evt_detect_analog', COBRAM_files, [], ...
    'eventname',   'Lit_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    2, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Lit', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

COBRAM_files = bst_process('CallProcess', 'process_evt_detect_analog', COBRAM_files, [], ...
    'eventname',   'Fil_adj', ...
    'channelname', 'UADC001', ...
    'timewindow',  [,], ...
    'threshold',   2, ...
    'blanking',    2, ...
    'highpass',    0, ...
    'lowpass',     0, ...
    'refevent',    'Fil', ...
    'isfalling',   0, ...
    'ispullup',    1, ...
    'isclassify',  0);

% Save and display report
ReportFile = bst_report('Save', COBRAM_files);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);





%% REPORT FOR FREQUENCY SPECTRUM
% (combine PSD for Noise and for all the other files):

All_PSD =  {Res_PSD.FileName, Noise_Res_PSD.FileName};

% Start a new report
bst_report('Start', All_PSD);

% Process: Snapshot: Frequency spectrum
All_PSD = bst_process('CallProcess', 'process_snapshot', All_PSD, [], ...
    'target',         10, ...  % Frequency spectrum
    'modality',       1, ...  % MEG (All)
    'orient',         1, ...  % left
    'time',           0, ...
    'contact_time',   [0, 0.1], ...
    'contact_nimage', 12, ...
    'threshold',      30, ...
    'rowname',        '', ...
    'Comment',        '');

% Save and display report
ReportFile = bst_report('Save', All_PSD);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);



%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)


