% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS


%% SET PROTOCOL
ProtocolName = 'Meghem_analisi_3';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')
% get original file names


%% SELECT  TRIALS
% 
my_sFiles_string={'First_Corr_'}

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string{1}, ...
    'IncludeBad', 1);


% get name and perform some selection
my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');

% get Input Structure
my_sInputs = bst_process('GetInputStruct', my_sel_sFiles);

% extract Filenams
FileNames={my_sInputs.FileName};


%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(FileNames, SubjectNames);

%% SEPARATE FILES BY RUN
runs={'_01_','_02_', '_03_'} 
Subj_run={};


for iSubj=1:length(Subj_grouped)
    
    Subj_run{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, runs); % IMPORTANT: notice I enter in the cell {}
    
end;

%%% CORRECTION FOR SUBJECT MH005
% Subject 05, has run _01_, _03_ and _04
Subj_run{5}{2}=Subj_run{5}{3} % put run 3 in cell 2
other_run=sel_files_bst(my_sel_sFiles, '(MH005/)([\w]+)(_04_)'); % \w match for all alphanumeric characters

Subj_run{5}{3}=other_run;



%% CREATE EMPTY CELL FOR TIMES AND FOR INDICES 
% create empty cell for subject
Subj_run_times=cell(1, length(Subj_run));

for s=1:length(Subj_run_times)
    Subj_run_times{s}=cell(1, length(runs));
end;

Subj_run_indices=Subj_run_times;

%% RETRIEVE TRIALS TIME INFO

for iSubj=1:length(Subj_run);
    for irun=1:length(runs);
    
    % initialize a matrix: number of trials
    curr_run=Subj_run{iSubj}{irun};
    data_epoch_ini_time=zeros(length(curr_run), 1);
    
    % loop over trial of the current run, to retrieve the time.
    for iTrial=1:length(curr_run);
        trial=in_bst_data(curr_run{iTrial}, 'History', 'Time');
        trial_time=eval(trial.History{3, 3});
        trial_offset=trial.Time(1);
        % this is the beginning of the subjects in time
        data_epoch_ini_time(iTrial)=trial_time(1)+(-trial_offset);
    end;
    
   Subj_run_times{iSubj}{irun}=data_epoch_ini_time;
   end;

end;


%% CONVERT TIMES IN INDICES PER RUN
for iSubj=1:length(Subj_run);
        for irun=1:length(runs);
            [~, ~, indices]=unique(Subj_run_times{iSubj}{irun}); 
            % note the use of unique. 
            % this indices retrieve the ordinal position of the trials.
            % for example [3, 15 indicates that the first trial in the list is the Third trial
            % presented in the experiment, the second trial in the list was the
            % number 15 presented in the experiment, and so on.
            % Taken From here http://stackoverflow.com/questions/18746759/assign-rank-to-numbers-in-a-vector. 
            % the use of sort() is different.
            Subj_run_indices{iSubj}{irun}=indices;
        end;
end;


% save Subj_run_times, Subj_run_indices, Subj_run

Subj_run_ordered=cell(1, length(Subj_run));
for iSubj=1:length(Subj_run);
    for irun=1:length(runs);
        % the following use of sort retrive from the indices the
        % corresponding mapping to trials run
        % for example [35, 4,  indicates that the first trial to be put is
        % the number 35, the second is the number 4.
        % with this info, I can re-order the fileNames according to the
        % actual presentation
        [~, curr_indices]=sort(Subj_run_indices{iSubj}{irun}); % notice the use of sort.
        Subj_run_ordered{iSubj}{irun}=Subj_run{iSubj}{irun}(curr_indices);
    end;
end;

% save all relevant files
cd('/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_easy_vs_hard')
save('Subj_run.mat', 'Subj_run', 'Subj_run_times', 'Subj_run_indices', 'Subj_run_ordered')


