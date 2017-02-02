% launch brainstorm, with no gui (but only if is not already running)
clear

if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/';
export_folder1='butterfly_ver2'

if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
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


%% ADD SPECIFIC TAG TO ALL FILES CREATED
my_tag='_ver2';

%% SELECT  TRIALS
%
my_sFiles_string='First_Corr_'

% Process: Select timefreq files in: */Freqbands
my_sFiles_ini= bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
    'subjectname',   'All', ...
    'condition',     [], ...
    'tag',           my_sFiles_string, ...
    'includebad',    0, ...
    'includeintra',  1, ...
    'includecommon', 0);


my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '_ver2');
my_sel_sFiles=sel_files_bst(my_sel_sFiles, 'ersd');


%% SEPARATE FILES BY CONDITION
Conditions={'Fast18','Slow18'} ;

Conditions_grouped=group_by_str_bst(my_sel_sFiles, Conditions);

my_scouts={'G_temporal_middle R', 'G_temporal_middle L', 'G_front_middle L',...
    'G_front_middle R', 'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', ...
    'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R'};


ind=1
%loop over conditions
for iCond=1:length(Conditions);
    % loop over scouts
    for iScout=1:length(my_scouts)
        % Start a new report
        
        bst_report('Start', Conditions_grouped{iCond});
        
        % Process: Extract values: [-2.000s,3.700s] 5-7Hz G_temporal_middle R
        Res = bst_process('CallProcess', 'process_extract_values', Conditions_grouped{iCond}, [], ...
            'timewindow', [-2, 3.7], ...
            'freqrange',  [5, 7], ...
            'rows',       my_scouts{iScout}, ...
            'isabs',      0, ...
            'avgtime',    0, ...
            'avgrow',     0, ...
            'avgfreq',    0, ...
            'matchrows',  0, ...
            'dim',        1, ...  % Concatenate signals (dimension 1)
            'Comment',    '');
        
        
        %% !!! WARNING: I had to add an increasing indices, because of a bug in brainstorm
        % (the ROI were overwritten).
        % Process: Add tag to name.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  ['_', Conditions{iCond}, my_tag, num2str(ind)] , ...
            'output', 2);  % Add to name
        
        % Process: Add tag to comment.
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  ['_', Conditions{iCond}, my_tag] , ...
            'output', 1);  % Add to comment
        
        ind=ind+1
        
        % Save and display report
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile, [export_main_folder, '/' export_folder1]);
    end;
end;




