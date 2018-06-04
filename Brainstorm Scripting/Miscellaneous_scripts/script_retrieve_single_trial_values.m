% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
%export_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/Scout_Power';


%% SET PROTOCOL
ProtocolName = 'Prova';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol given the index
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info (not necessary)
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')
% get original file names


%% SELECT  TRIALS
% 
my_string={'FreqBands'}


% make the first selection with bst process NECESSARY because it exclue bad
% trials
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname', my_subjectnames{1}, ...
    'includeintra',  0,...
    'tag',         my_string{1}, ...
    'IncludeBad', 1);


%% GROUP BY CONDITION
my_group_strings={'COR', 'INC'}
grouped_Cond = group_by_str_bst({my_sFiles_ini.FileName}, my_group_strings)



% loop over trials and store the values in a single matrix.
for i=1:length(my_sFiles_ini)
    my_sTrial = in_bst_data(my_sFiles_ini(i).FileName, 'TF');
    my_trial=my_sTrial.TF(:,1); % get only the first column, the second is redundant.
    
    % initialize matrix only at first trial
    if i==1
        all_trials=zeros(size(my_trial, 1), length(my_sFiles_ini)); % create a matrix nchanneles x trials.
    end;
    
    all_trials(:, i)=my_trial;
      
end;

        
    

