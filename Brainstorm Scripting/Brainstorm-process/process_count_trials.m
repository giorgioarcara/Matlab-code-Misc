function varargout = process_count_trials( varargin )
% process_count_trials: count trials in a study.
%
% USAGE:     sProcess = process_count_trials('GetDescription')
%                       process_count_trials('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2016, version 0.2

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'Count trials';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Giorgio';
sProcess.Index       = 1021;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'data', 'results', 'timefreq', 'matrix'};
sProcess.OutputTypes = {'data', 'results', 'timefreq', 'matrix'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options
% Instructions
sProcess.options.Instructions.Comment='Count Trials in a brainstorm study';
sProcess.options.Instructions.Type='label';
% Separator
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = '';
% === RAGET

sProcess.options.include.Comment = 'Trials Names to include (label1,label2)';
sProcess.options.include.Type    = 'text';
sProcess.options.include.Value   = '';

sProcess.options.exclude.Comment = 'string to exclude (label1,label2)';
sProcess.options.exclude.Type    = 'text';
sProcess.options.exclude.Value   = '';

% Substitute with Nan (explanation)
sProcess.options.Text.Comment = ['<B>WARNING</B>: Be careful in specifiying the labels: <BR>' ...
    'all blank spaces are taken into account. <BR>'];
sProcess.options.Text.Type    = 'label';

sProcess.options.ExcludeBad.Comment = ['Exclude Bad Trials from the count' ];
sProcess.options.ExcludeBad.Type    = 'checkbox';
sProcess.options.ExcludeBad.Value   = 1;




end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = {sInputs.FileName};

Trials_lab_temp = sProcess.options.include.Value;
Trials_lab = strsplit(Trials_lab_temp, ','); % create a cell with all events labels

% I don't do the same with exclude strings, cause I want the exclude strings are
% always taken into account. I replace "," with "|" if necessary.
exclude_string = sProcess.options.exclude.Value;
exclude_string = regexprep(exclude_string, ',', '|');

ExcludeBad = sProcess.options.ExcludeBad.Value;

% determine study names
% CRUCIAL PART!!!
% In this part I retrieve only the studies associated with a group of trials, so avoinding
% duplicates.
sStudies = bst_get('Study', unique([sInputs.iStudy]));



% initialize emtpy object (files x labels)
TrialsCount = zeros(length(sStudies), length(Trials_lab));
RowNames = cell(1, length(sStudies));

for iStudy = 1:length(sStudies)
    
    % select current study
    sStudy = sStudies(iStudy);
    
    % retrieve bad trials
    sStudy_BadTrials=[sStudy.Data(:).BadTrial];
    
    % retrieve bad trials indices
    BadTrials_indices=find(sStudy_BadTrials);
    
    
    DataComments = {sStudy.Data.Comment};
    
    % loop over all labels to determine include strings
    for iLabel = 1:length(Trials_lab)
        
        include_string = Trials_lab{iLabel};
        
        % include check
        include_check=regexp(DataComments, include_string);
        selFiles_indices=find(~cellfun(@isempty, include_check));
        
        % exclude check
        if ~isempty(exclude_string)
            exclude_check=regexp(DataComments, exclude_string);
            selFiles_indices=find(~cellfun(@isempty, include_check) & cellfun(@isempty, exclude_check));
        end;
        
        if ExcludeBad
            selFiles_indices = setdiff(selFiles_indices, BadTrials_indices);
        end;
        
        curr_label_count = length(selFiles_indices);
        
        
        TrialsCount(iStudy, iLabel)=curr_label_count;
        RowNames{iStudy} = sStudy.Name;
    end;
    
end;

TrialsTable = array2table(TrialsCount);

% adjust variable names to be suited to be table columns
temp_var_names = strcat('tr_', Trials_lab);
var_names = regexprep(temp_var_names, ' ', '_');
TrialsTable.Properties.VariableNames = var_names;
TrialsTable.Properties.RowNames = RowNames;
% export to workspace
assignin('base', 'TrialsTable', TrialsTable);
writetable(TrialsTable, 'TrialsTable.txt','delimiter', '\t', 'WriteRowNames',true);

end



