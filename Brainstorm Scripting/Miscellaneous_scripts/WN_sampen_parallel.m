% WN sample entropy
% Set up the Brainstorm files
BrainstormPath = '/storages/LDATA55/Arcara/brainstorm3';
addpath(genpath(BrainstormPath));
BrainstormDbDir = '/storages/LDATA55/';
% Start Brainstorm
if ~brainstorm('status')WN
    brainstorm server
end
bst_set('BrainstormDbDir',BrainstormDbDir)
% Select the correct protocol
ProtocolName = 'WN_Entropy'; % Enter the name of your protocol
%sProtocol.Comment = ProtocolName;
%sProtocol.SUBJECTS = [home 'anat'];
%sProtocol.STUDIES = [home 'data'];
%db_edit_protocol('load',sProtocol);
% Get the protocol index
iProtocol = bst_get('Protocol', ProtocolName);
if isempty(iProtocol)
    error(['Unknown protocol: ' ProtocolName]);
end
% Select the current procotol
gui_brainstorm('SetCurrentProtocol', iProtocol);

%%%%%%%%%%%%%
ProtocolInfo=bst_get('ProtocolInfo');
my_subjects = bst_get('ProtocolSubjects');

%jh=1
iSubject=bst_get('Subject',jh);
iConditions=bst_get('ConditionsForSubject', iSubject.FileName);

Freqs = {[0 0] [2 4], [5 7], [8 12] [13 29] [30 60]};
Freqs_labels = {'broadband', 'delta', 'theta', 'alpha', 'beta', 'gamma'};

%% insert script here

for iFreq = 1:length(Freqs);
    
    % Process: Run Matlab command
    
    sens_files  = bst_process('CallProcess', 'process_select_files_data', [], [], ...
        'subjectname',   iSubject.Name, ...
        'condition',     [], ...
        'tag',           [], ...
        'includebad',    0, ...
        'includeintra',  0, ... % include intra as I select average of runs
        'includecommon', 0);
    
    % only if it is not broadband, filter the data
    if (Freqs{iFreq}(1)~=0 & Freqs{iFreq}(2)~=0)
        
        filt_files = bst_process('CallProcess', 'process_bandpass', sens_files, [], ...
            'sensortypes', 'MEG', ...
            'highpass',    Freqs{iFreq}(1), ...
            'lowpass',     Freqs{iFreq}(2), ...
            'tranband',    0, ...
            'attenuation', 'strict', ...  % 60dB
            'ver',         '2019', ...  % 2019
            'mirror',      0, ...
            'overwrite',   0);
        
        source_files  = bst_process('CallProcess', 'process_select_files_results', [], [], ...
            'subjectname',   iSubject.Name, ...
            'condition',     [], ...
            'tag',           [], ...
            'includebad',    0, ...
            'includeintra',  0, ... % include intra as I select average of runs
            'includecommon', 0);
        
        % Procaess: Select parent names with tag: band
        source_files = bst_process('CallProcess', 'process_select_tag', source_files, [], ...
            'tag',    'band', ...
            'search', 3, ...  % Search the names of the parent file
            'select', 1);  % Select only the files with the tag
        
    else
        
        % case broadband (no filter is necessary)
        source_files  = bst_process('CallProcess', 'process_select_files_results', [], [], ...
            'subjectname',   iSubject.Name, ...
            'condition',     [], ...
            'tag',           [], ...
            'includebad',    0, ...
            'includeintra',  0, ... % include intra as I select average of runs
            'includecommon', 0);
             
        
    end;
    
     bst_report('Start', source_files);

    
    SE_res = bst_process('CallProcess', 'process_matlab_eval', source_files, [], ...
        'matlab',    ['% Available variables: Data, TimeVector' 10 '' 10 'newData=[];' 10 'for iVertex = 1:size(Data,1)'' 10' 10 '    std_vertex = (Data(iVertex,:) - mean(Data(iVertex,:)) )/std(Data(iVertex,:)); % standardize' 10 '    newData(iVertex,:) = sampen(std_vertex, 2, 0.15, ''chebychev'');' 10 'end' 10 'Data = [newData, newData];' 10 'TimeVector = [TimeVector(1), TimeVector(end)];' 10 '' 10 '' 10 ''], ...
        'overwrite', 0);
    
    % Process: Average: By trial group (folder average)
    Ave_res = bst_process('CallProcess', 'process_average', SE_res, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'scalenormalized', 0);
    
    % Process: Add tag: differential_TF_mismatch_adj_short_zscore
    Res = bst_process('CallProcess', 'process_add_tag', Ave_res, [], ...
        'tag',           ['sampen_', Freqs_labels{iFreq}], ...
        'output',        1);  % Add to file name
    
    % Process: Add tag: differential_TF_mismatch_adj_short_zscore
    Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
        'tag',           ['sampen_', Freqs_labels{iFreq}], ...
        'output',        2);  % Add to file name
    
    % delete temporary files
    % Process: Delete selected files
    Del_files = bst_process('CallProcess', 'process_delete', SE_res, [], ...
        'target', 1);  % Delete selected files
    
        % only if it is not broadband, filter the data
    if (Freqs{iFreq}(1)~=0 & Freqs{iFreq}(2)~=0)
           Del_filt_files = bst_process('CallProcess', 'process_delete', filt_files, [], ...
        'target', 1);  % Delete selected files
    end;
        
    
    % Save and display report
    ReportFile = bst_report('Save', source_files);
    bst_report('Open', ReportFile);
    % bst_report('Export', ReportFile, ExportDir);
    toc
    
end;


% Available variables: Data, TimeVector
% code used in run matlab process
% newData=[];
% for iVertex = 1:size(Data,1)' 10
%     std_vertex = (Data(iVertex,:) - mean(Data(iVertex,:)) )/std(Data(iVertex,:)); % standardize
%     newData(iVertex,:) = sampen(std_vertex, 2, 0.15, 'chebychev');
% end
% Data = [newData, newData];
% TimeVector = [TimeVector(1), TimeVector(end)];
%

