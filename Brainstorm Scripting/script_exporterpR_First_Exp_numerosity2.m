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

%% GET CURRENT SCRIPT NAME

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end



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
my_sFiles_string='p_'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_data', [], [], ...
    'subjectname', 'All', ...
    'includeintra',  0,...
    'tag',         my_sFiles_string);


my_sFiles = sel_files_bst({my_sFiles_ini.FileName}, 'average');
my_sFiles = sel_files_bst(my_sFiles, 'low');
my_sFiles = sel_files_bst(my_sFiles, 'sj0007');


%% DIVIDE BY CONDITION
Conditions={'p_m_qualche_sg', 'p_m_qualche_pl', 'p_m_alcuni_sg', 'p_m_alcuni_pl', 'p_m_un_sg', 'p_m_un_pl', 'p_s_un_con', 'p_s_un_inc', 'p_s_qualche_con', 'p_s_qualche_inc', 'p_s_alcuni_con', 'p_s_alcuni_inc'};

Condition_grouped=group_by_str_bst(my_sFiles, Conditions);


%% SET ERPR FOLDER

erpR_data_folder = '/Users/giorgioarcara/Documents/Lavori Unipd/Progetto Mass Count/ERP Agreement/Exp numerosity 2 ERP analysis/ExpNumerosity R analysis/Original Data'

cd(erpR_data_folder)

%%
for iGroup = 1:length(Condition_grouped)
    
    % Start a new report
    bst_report('Start', Condition_grouped{iGroup});
    
    
    % Process: export to erpR
    Res = bst_process('CallProcess', 'process_export_erpR', Condition_grouped{iGroup}, [], ...
        'base',       Conditions{iGroup}, ...
        'chars',      10, ... % note that this is overrid by the 'base' argument
        'BadChans',   1);
    
    % Save and display report
    ReportFile = bst_report('Save', Res);
    bst_report('Open', ReportFile);
    bst_report('Export', ReportFile, [export_main_folder, '/', export_folder]);
    
end;

%% BACKUP SCRIPT AND OBJECT WITH DATA

script_name = mfilename('fullpath')

if (length(script_name) == 0)
    error('You must run this script by calling it from the prompt or clicking the Run button!')
end

export_script(script_name, my_sFiles_ini)




