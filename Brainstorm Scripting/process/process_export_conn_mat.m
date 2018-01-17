function varargout = process_export_conn_mat( varargin )
% process_export_conn_mat: export a connectivity matrix to be used with GT
% utilities
%
% USAGE:     sProcess = process_export_conn_mat('GetDescription')
%                       process_export_conn_mat('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 
%
% Version: 13/01/2018,

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


% Decription of the files
sProcess.options.ProcessDescr.Comment = ['The process will export a .mat with the connectivity.<BR>'...
    'The .mat file name should be made by the combination of a base + Subject ID. <BR>' ...
    'The ''base'' can be specified from two ways: from BST Comment or from user input.<BR>' ...
    'These two ways can be combined'];

sProcess.options.ProcessDescr.Type    = 'label';

% Separatore
sProcess.options.separator1.Type = 'separator';
sProcess.options.separator1.Comment = ' ';


% === OUTPUT NAME OPTION 1 number from condition
% Substitute with Nan (explanation)
sProcess.options.charsTitle.Comment = ['<B> OPTION 1: generate from BST Comment'];
sProcess.options.charsTitle.Type    = 'label';

sProcess.options.chars.Comment = 'Number of characters';
sProcess.options.chars.Type    = 'value';
sProcess.options.chars.Value   = {10, '', 0}; % the second number indicates the numbers after decimall separator.

% Separatore
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = ' ';

% === OUTPUT NAME OPTION 2 BASE

% Substitute with Nan (explanation)
sProcess.options.BaseTitle.Comment = ['<B> OPTION 2: Specify a label </B>'];
sProcess.options.BaseTitle.Type    = 'label';

sProcess.options.base.Comment = 'Base';
sProcess.options.base.Type    = 'text';
sProcess.options.base.Value   = '';

sProcess.options.BaseOver.Comment = ['determine base only from supplied label'];
sProcess.options.BaseOver.Type    = 'checkbox';
sProcess.options.BaseOver.Value   = 1;

% Separatore
sProcess.options.separator3.Type = 'separator';
sProcess.options.separator3.Comment = ' ';

% Determine. Numbers
sProcess.options.Num.Comment = ['Determine ''Subject ID'' from Brainstorm Subject Name' ];
sProcess.options.Num.Type    = 'checkbox';
sProcess.options.Num.Value   = 1;


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
    if sProcess.options.BaseOver.Value
        
        myCondName=sProcess.options.base.Value;
        
    else % otherwise use number of characters
        
        % get condition name (it will be the 'base' in erpR terms)
        % the end will be the minimum between the actual length and the
        % number supplied with Condition numbers
        
        % determine the maximum possible length (to avoid out of bounds
        % subscript).
        
        end_myCondName= min([length(sInput.Comment), sProcess.options.chars.Value{1}]);
        
        myCondName = [sProcess.options.base.Value, sInput.Comment(1: end_myCondName)]; 
        
    end; 
    
    % get Subject Name
    Curr_Subj_Name=sInput.SubjectName;
    
    %% DEFINE NUMBER
    % get Subject Name (if checkbox is checked)
    if sProcess.options.Num.Value
        Curr_Subj_Name=strcat('_', sInput.SubjectName);
    else
        Curr_Subj_Name='';
    end
    
   
    
    % get connectivity Data
    conn_data = in_bst_data(sInput.FileName);
    
    % get connectivity matrix (rearranged correcttly)
    R = bst_memory('GetConnectMatrix', conn_data);
   
    
        %% ADJUST IF FUNCTION APPLIED AFTER
     
    if (size(R, 1) ~= size(R,2))
        
        % adjust RowNames
        sp = regexp(conn_data.RowNames, '\.', 'split');        % loop over RowNames to rename
        sp = vertcat(sp{:});
        % solution taken from here:
        %https://stackoverflow.com/questions/27850230/apply-strsplit-to-column-of-strings-cellstr

        newRowNames = sp(:, 1);
        
        % keep track of original RowNames
        conn_data.orRowNames = conn_data.RowNames;
        conn_data.RowNames = newRowNames;
        
        % create empty new matrix
        newR = zeros(size(R,1));
        
        for iScout = 1:length(conn_data.RefRowNames);
            curr_row_scout = conn_data.RefRowNames{iScout};
            for kScout = 1:length(conn_data.RefRowNames)
                curr_col_scout = conn_data.RefRowNames{kScout};
                curr_col_ind = strcmp(curr_col_scout, newRowNames)'; % note the '. To have the right shape
                
                newR(iScout,kScout) = mean(R(iScout, curr_col_ind));
                
            end;
        end;
        
       R = newR; % substitute R 
       fprintf('GT Warning: Data were not stored in NxN. Fixed\n');
    end;
       
    
    % FIRST LINE COMMENT define the comment to be put in the file
    % (in the first line)-
    
    % save connectivity matrix
    Conn = conn_data;
    
    Conn.conn_mat = R;
    % save name of label
    
    Conn.type = 'GTmat';
    

  
    
    %% DEFINE EXPORT NAME (combination of condition and subject).
    export_name=strcat(myCondName, '_', Curr_Subj_Name, '.mat');
    % small correction of export name (':' can give problems)
    export_name=strrep(export_name, ':', ''); % get rid of semicolon
    export_name=strrep(export_name, ' ', '_'); % get rid of spaces

    
    save(export_name, 'Conn');
    
end;

end



