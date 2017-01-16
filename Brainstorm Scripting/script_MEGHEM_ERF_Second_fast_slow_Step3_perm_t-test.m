% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder='Perm_t-test';


if ~exist([export_main_folder, '/' export_folder])
    mkdir([export_main_folder, '/' export_folder]) % create folder if it does not exist
end;



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
my_sFiles_string='Second_Corr'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname', 'Group_analysis', ...
    'includeintra',  1,...
    'tag',         my_sFiles_string);


%% DIVIDE BY CONDITION
Conditions={'Fast18', 'Slow18'};

Condition_grouped=group_by_str_bst( {my_sFiles_ini.FileName}, Conditions);
Condition_grouped{1}=sort_by_fragment(Condition_grouped{1}, 'MH0..');
Condition_grouped{2}=sort_by_fragment(Condition_grouped{2}, 'MH0..');

% Start a new report
bst_report('Start', Condition_grouped{1});


%% DEFINE INTERVALS TO BE ANALIZED
intervals={[0.1 0.2], [0.2 0.3], [0.3 0.4]}


for i=1:length(intervals)
    
    for iCond=1:length(Conditions);
        for iSubj=1:length(SubjectNames);
             
            %% IN this loop I extract values separately for each subject
            % this is necessary cause extract values try always to
            % concatenate time or subjects. Only using just on subject at
            % the time I obtain what I want. a
            % Process: Extract values: [-300ms,600ms] 5-7Hz
            curr_file = bst_process('CallProcess', 'process_extract_values', Condition_grouped{iCond}{iSubj}, [], ...
                'timewindow', [-0.3, 0.6], ...
                'freqrange',  [Freqs{iFreq}(1), Freqs{iFreq}(2)], ...
                'rows',       '', ...
                'isabs',      0, ...
                'avgtime',    0, ...
                'avgrow',     0, ...
                'avgfreq',    0, ...
                'matchrows',  0, ...
                'dim',        2, ...  % Concatenate time (dimension 2)
                'Comment',    '');
            
            % Process: Add tag to name.
            curr_file = bst_process('CallProcess', 'process_add_tag', curr_file, [], ...
                'tag',  [SubjectNames{iSubj}, '_', my_sFiles_string, '_', Conditions{iCond}] , ...
                'output', 2);  % Add to name
            
            % create a cell with n Condition elements. Each one contain the
            % struct related to a condition
                extract_all_files{iCond}(iSubj)=curr_file;
        end;
    end;
            
   % Process: FT t-test paired cluster [100ms,200ms]          H0:(A=B), H1:(A<>B)
Res = bst_process('CallProcess', 'process_ft_sourcestatistics', extract_all_files{1}, extract_all_files{2}, ...
    'timewindow',     [0.1, 0.2], ...
    'scoutsel',       {}, ...
    'scoutfunc',      1, ...  % Mean
    'isabs',          0, ...
    'avgtime',        1, ...
    'randomizations', 1000, ...
    'statistictype',  2, ...  % Paired t-test
    'tail',           'two', ...  % Two-tailed
    'correctiontype', 2, ...  % cluster
    'minnbchan',      0, ...
    'clusteralpha',   0.05);
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    bst_report('Export', ReportFile, [export_main_folder, export_folder]);
end;


