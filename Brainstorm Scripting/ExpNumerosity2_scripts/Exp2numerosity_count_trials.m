%% EXP2 NUMEROSITY
% This script count the trials of the average retrieved.


% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Brainstorm_Reports/';
export_folder='Exp_numerosity2';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Exp_numerosity2_merged';

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
my_sFiles_string='Avg'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string);


my_sFiles = {my_sFiles_ini.FileName};
my_sFiles = sel_files_bst(my_sFiles, 'data_p');
my_sFiles = sel_files_bst(my_sFiles, 'low');

% select only final subjects
my_sFiles = sel_files_bst(my_sFiles, 'sj0001|sj0002|sj0003|sj0004|sj0006|sj0007|sj0008|sj0009|sj0010|sj0011|sj0012|sj0013|sj0014|sj0015|sj0016|sj0017|sj0018|sj0019|sj0020|sj0021|sj0022|sj0023|sj0024|sj0025|sj0026');





%% EXPORT FILES
% loop over file to export a simple file with subject name, condition and
% number of trials in the Average.

colnames = {'Subject_Name', 'Condition', 'nAvg'};

export_name = 'ExpNumerosity_trialcount.txt'

fid = fopen(export_name, 'w');
fprintf(fid, '%s\t', colnames{:}); % print colnames (first row)
fprintf(fid, '\n', '');


for iFile = 1:length(my_sFiles)
    
    my_file = my_sFiles{iFile};
    % get subject names
    my_subject_name = bst_fileparts(bst_fileparts(my_file)); % get subj name with double fileparts.
    
    % get condition
    my_start = regexp( my_file, 'data_');
    my_end = regexp(my_file, 'average_');
    my_cond = my_file( (my_start + 5) : (my_end-2));
    
    % get number of average
    nAvg=in_bst_data(my_file, 'nAvg');
    nAvg = nAvg.nAvg; % (extract from struct)
    
    % print subject name
    fprintf(fid, '%s\t', my_subject_name);
    fprintf(fid, '%s\t', my_cond);
    fprintf(fid, '%d', nAvg);
    fprintf(fid, '\n', '');
    
end;

fclose(fid);






