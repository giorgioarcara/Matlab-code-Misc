% Script generated by Brainstorm (29-Sep-2017)
%% THE AIM of this script is to back import in raw files the bad trials (as determined in trial phase)
% this is done to import later the epochs time-locked to the second
% stimulus. I'm not performing a complete stript as this is just an
% adjustment for a single subject (the trial rejection was not performed in the analysis,
% probably forgotten (and I notice it).


sFiles = {...
    'sj0007/@rawsj0007_scale_bandpass/data_0raw_sj0007_scale_bandpass.mat'};

RawFiles = {...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_qualche_inc_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_qualche_con_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_alcuni_inc_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_alcuni_con_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_un_inc_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_s_un_con_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_alcuni_sg_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_alcuni_pl_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_qualche_sg_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_qualche_pl_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_un_sg_BadTrials.mat', ...
    '/Users/giorgioarcara/Documents/MATLAB/p_m_un_pl_BadTrials.mat'};

% Start a new report
bst_report('Start', RawFiles);


for iRaw=1:length(RawFiles);
    
    % Process: Import from file
    sFiles = bst_process('CallProcess', 'process_evt_import', sFiles, [], ...
        'evtfile', {RawFiles{iRaw}, 'ARRAY-TIMES'}, ...
        'evtname', 'BAD_trial');
end

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);

