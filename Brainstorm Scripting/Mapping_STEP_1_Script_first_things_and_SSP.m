%% STEP 1 
% This script starts from a protocol (already created)
% with all files of all subjects
% 
% 1) Import data
% 2) Convert epoched data to continuous
% 3) Add an end bad segment to epoched files
% 4) resample to 600 Hz
% 5) All SSP.
% 6) Calculate PSD and save in report.

%% PRELIMINARY PREPARATION
clear


addpath('/storages/LDATA/Giorgio/Mapping_pre_post_Analyses/Scripts/functions');
addpath('/storages/LDATA/Giorgio/Mapping_pre_post_Analyses/Scripts/');

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/storages/LDATA/Giorgio/Mapping_pre_post_Analyses/';
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
ProtocolName = 'mapping_pre_post';

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
sFiles = [];
SubjectNames = {...
    'All'};

% Start a new report

% Process: Select data files in: */*
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname',   SubjectNames{1}, ...
    'condition',     '', ...
    'tag',           '', ...
    'includebad',    0, ...
    'includeintra',  0, ...
    'includecommon', 0);



%% SPECIFY HERE THE FILES AND THE SUBJECTS TO BE PROCESSED.
% avoid to ciao

my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'LanguageTasks|ArcaraMapping');

my_sFiles = sel_files_bst(my_sFiles, 'MC_pre|MC_post|PC_pre|PC_post|SL_pre|SL_post');



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
epoched_files_bad=my_sFiles;


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




%% PART 2 PREPROCESS SUBJECT FILES  STEP 1


Subj_files = my_sFiles;


% Start a new report
bst_report('Start', Subj_files);

% Process: Resample: 600Hz
Subj_files = bst_process('CallProcess', 'process_resample', Subj_files, [], ...
    'freq',      600, ...
    'overwrite', 0);

% Process: Power spectrum density (Welch)
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

% Process: SSP: generic. To detect eye movements in some cases
% NOT MANDATORY!! It is important to check and apply only if necessary.
sFiles = bst_process('CallProcess', 'process_ssp', sFiles, [], ...
    'timewindow',  [0, 20], ...
    'eventname',   '', ...
    'eventtime',   [-0.2, 0.2], ...
    'bandpass',    [0, 6], ...
    'sensortypes', 'MEG', ...
    'usessp',      1, ...
    'saveerp',     0, ...
    'method',      1, ...  % PCA: One component per sensor
    'select',      1);


% Save and display report
ReportFile = bst_report('Save', Subj_files);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);




% 
% % Process: Select data files in: */*
% my_PSD_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
%     'subjectname',   SubjectNames{1}, ...
%     'condition',     '', ...
%     'tag',           '', ...
%     'includebad',    0, ...
%     'includeintra',  0, ...
%     'includecommon', 0);
% 
% Res_PSD = sel_files_bst({my_PSD_ini.FileName}, 'psd');


%% REPORT FOR FREQUENCY SPECTRUM

% Start a new report
bst_report('Start', Res_PSD);
  
% Process: Snapshot: Frequency spectrum
Res_PSD = bst_process('CallProcess', 'process_snapshot', Res_PSD, [], ...
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
ReportFile = bst_report('Save', Res_PSD);
bst_report('Open', ReportFile);
bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);





%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)



