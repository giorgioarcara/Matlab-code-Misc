% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end

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


%% SELECT  TRIALS
% 
mysFiles={'Second_Corr_Fast'}

  for iCondition=1:length(mysFiles)
    % make the first selection with bst process
    sFiles = bst_process('CallProcess', 'process_select_files_data', [], [], ...
        'subjectname', 'All', ...
        'includeintra',  0,...
        'tag',         mysFiles{1});


    my_sel_sFiles=sel_files_bst({ sFiles(:).FileName }, '.', 'average');

    % create object with name of condition 
    eval([mysFiles{1},'=my_sel_sFiles;'])

end;




%% SEPARATE FILES FOR SUBJECT (and check for correctness)
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(Second_Corr_Fast, SubjectNames);

%% SEPARATE FILES BY RUN
runs={'_01_','_02_', '_03_'} 
Subj_run={}


for iSubj=1:length(Subj_grouped)
    
    Subj_run{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, runs) % IMPORTANT: notice I enter in the cell {}
    
end;

%% CORRECTION FOR SUBJECT MH005
% Subject 05, has run _01_, _03_ and _04
Subj_run{5}{2}=Subj_run{5}{3} % put run 3 in cell 2
other_run=sel_files_bst(Second_Corr_Fast, '(MH005/)([\w]+)(_04_)'); % \w match for all alphanumeric characters

Subj_run{5}{3}=other_run;

%% TIME FREQUENCY ANALYSIS (SEPARATE FOR RUN).








