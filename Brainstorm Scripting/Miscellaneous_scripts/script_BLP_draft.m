%%
% this script works on a bst protocol in which pre-processing has been performed.
% trial rejection has been made and sources kernel are already computed.

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end



%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/Prove_threshold';
export_folder1='BLP_PROVE';


if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Prove_thresh';

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
my_sFiles_string={'Link to Raw'}

subject_sel='CT'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', subject_sel, ...
    'includeintra',  0,...
    'tag',         my_sFiles_string{1});

% exclude trial with average
my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, 'ArcaraMapping');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, '_01.mat');


%% VALID ONLY IN THIS EXAMPLES

curr_file=my_sel_sFiles

%% STEP 0

% get the current file (useful to get noise covariance)
curr_study=bst_get('StudyWithCondition', bst_fileparts(curr_file{1}));
 

%% STEP 1
% Filter the data


% Process: Band-pass:8Hz-10Hz



Res1 = bst_process('CallProcess', 'process_bandpass', curr_file, [], ...
    'sensortypes', 'MEG', ...
    'highpass',    8, ...
    'lowpass',     10, ...
    'attenuation', 'strict', ...  % 60dB
    'mirror',      0, ...
    'useold',      0, ...
    'read_all',    1);


%% RETRIEVE SOURCE (LINK) FILES
            % retrieve condition path
            
            % exclude with the following steps the empty filenames, in the
            % ResultFile, otherwise cannot use intersect
            no_empty_DataFile_ind=find(~cellfun(@isempty, {curr_study.Result.DataFile}));
            no_empty_Resultfile=curr_study.Result(no_empty_DataFile_ind);
            
            % find intersection between curr-files (the data to be processed)
            % and the non-empty Resultfile names
            [a ind_curr_files ind_no_empty_Resultfile]=intersect(curr_file, {no_empty_Resultfile.DataFile});
            
            % retrieve link_files
            link_files={no_empty_Resultfile(ind_no_empty_Resultfile).FileName};
            















