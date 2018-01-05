function varargout = process_export_conn_mat( varargin )
% PROCESS_ADD_TAG: Add a comment tag.
%
% USAGE:     sProcess = process_export_conn_mat('GetDescription')
%                       process_export_conn_mat('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 27/12/2017,

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'export connectivity matrix in .mat format';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'File';
sProcess.Index       = 1022;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'matrix', 'timefreq'};
sProcess.OutputTypes = {'matrix', 'timefreq'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options

% === BASE
sProcess.options.base.Comment = 'Base';
sProcess.options.base.Type    = 'text';
sProcess.options.base.Value   = '';

% === TARGET
sProcess.options.chars.Comment = 'Number of characters of Condition';
sProcess.options.chars.Type    = 'value';
sProcess.options.chars.Value   = {10, '', 0}; % the second number indicates the numbers after decimall separator.

% === CHARS EXPLANATION
sProcess.options.charstext.Comment = ['This value is overridden if the Base argument <BR>' ...
    'is not empty' ];
sProcess.options.charstext.Type    = 'label';

end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = {sInputs.FileName};

for i = 1:length(sInputs)
    
    sInput=sInputs(i); % get current file
    
    %% DEFINE BASE
    % if a base value is supplied, specify base
    if ~strcmpi(sProcess.options.base.Value, '')
        
        myCondName=sProcess.options.base.Value
        
    else % otherwise use number of characters
        
        % get condition name (it will be the 'base' in erpR terms)
        % the end will be the minimum between the actual length and the
        % number supplied with Condition numbers
        
        end_myCondName=min([length(sInput.Comment), sProcess.options.chars.Value{1}])
        
        myCondName = sInput.Comment(1: end_myCondName); % get the length of Condition name from options
        
    end;
    
    % get Subject Name
    Curr_Subj_Name=sInput.SubjectName;
    
    % get connectivity Data
    conn_data = in_bst_data(sInput.FileName);
    
    % get connectivity matrix (rearranged correcttly)
    R = bst_memory('GetConnectMatrix', conn_data);
    
    % get row Names
    col_names = conn_data.RowNames;
    
    
    
    % DEFINE EXPORT NAME (combination of condition and subject).
    export_name=strcat(myCondName, '_', Curr_Subj_Name, '.mat');
    % small correction of export name (':' can give problems)
    export_name=strrep(export_name, ':', '_');
    
    % FIRST LINE COMMENT define the comment to be put in the file
    % (in the first line)-
    
    % save connectivity matrix
    Conn.mat = R;
    % save name of label
    Conn.Label = col_names
    
    save(export_name, Conn);
    
end;

end



