function varargout = process_extract_conn( varargin )
% PROCESS_ADD_TAG: Add a comment tag.
%
% USAGE:     sProcess = process_export_conn('GetDescription')
%                       process_export_conn('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 3/08/2018,

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'extract connectivity matrix';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Giorgio';
sProcess.Index       = 1022;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'matrix', 'timefreq'};
sProcess.OutputTypes = {'matrix', 'timefreq'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options

% === FREQS
sProcess.options.Freqs.Comment = 'Freqs (indices)';
sProcess.options.Freqs.Type    = 'value';
sProcess.options.Freqs.Value   = {1, '', 0};

% === SEEDS
sProcess.options.Seeds.Comment = 'Seeds (indices)';
sProcess.options.Seeds.Type    = 'value';
sProcess.options.Seeds.Value   = {1, '', 0}; % the second number indicates the numbers after decimall separator.

% === CHARS EXPLANATION
sProcess.options.charstext.Comment = ['Set indices to <B>0</B> ' ...
    'to extract all Frequencies or Seeds' ];
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

% get values if they exists
Freqs = sProcess.options.Freqs.Value{1};
Seeds = sProcess.options.Seeds.Value{1};

% otherwise use all Freqs and Seeds (below).

for iInput = 1:length(sInputs)
    
    
    
    
    sInput=sInputs(iInput); % get current file
    
    Data = in_bst_data(sInput.FileName);
    
    if (Freqs == 0)
        % get all Freqs length
        Freqs = 1:size(Data.Freqs, 1)
        
    end;
    
    if (Seeds == 0)
        % get all seeds length
        Seeds = 1:length(Data.RefRowNames)
        
    end;
    
    % loop over seeds and Freqs
    
    for iSeed = 1:length(Seeds)
        
        for iFreq = 1:length(Freqs)
            
            % create dummy object
            NewData.Atlas = [];
            NewData.ColormapType = [];
            NewData.Comment = ['Extracted ', Data.Comment, '| ', Data.RefRowNames{iSeed}, '| ',strjoin([Data.Freqs(iFreq,:)], ' ') ];
            NewData.DataFile = Data.DataFile;
            NewData.DataType = 'results';
            NewData.GridAtlas = [];
            NewData.GridLoc = [];
            NewData.GridOrient = [];
            NewData.HeadModelFile = Data.HeadModelFile;
            NewData.HeadModelType = Data.HeadModelType;
            NewData.History = Data.History;
            NewData.ColormapType=[];
            
            
            % retrieve indices of Vertices
            % (in the Con File there is a single veector replicated for all
            % vertices). E.g. with a brain of 1000 vertices and 3 seeds, you have
            % a vector with 3000 values
            n_vertices = length(Data.RowNames);
            % with this code I select correctly (e.g., when seed = 1 from
            % 1:1000, when seed = 2 from 1001:2000, etc.
            % Seed_indices = (1:length(Data.RowNames)) + ( (Seed-1) * n_vertices);
            
            N_Seeds = length(Data.RefRowNames)
            
            % NOTE: I empirically discovered that data from different seeds are
            % arranged like this Seed1_vertex1, Seed2_vertex1, Seed3_vertex1,
            % Seed1_vertex2, Seed2_vertex2, ... and so on.
            
            NewData.TF = Data.TF(iSeed : N_Seeds : end, iFreq);
            
            
            NewData.TFmask = [];
            NewData.Std = [];
            NewData.Time = Data.Time;
            NewData.TimeBands = Data.TimeBands;
            NewData.Freqs = Data.Freqs(iFreq,:);
            NewData.RefRowNames = Data.RefRowNames(iSeed);
            NewData.RowNames = Data.RowNames;
            NewData.Measure = Data.Measure;
            NewData.Method = Data.Method;
            NewData.DataFile = Data.DataFile;
            NewData.SurfaceFile = Data.SurfaceFile;
            NewData.GridLoc = Data.GridLoc;
            NewData.GridAtlas = Data.GridAtlas;
            NewData.Atlas = Data.Atlas;
            NewData.HeadModelFile = Data.HeadModelFile;
            NewData.HeadModelType = Data.HeadModelType;
            NewData.nAvg = Data.nAvg;
            NewData.ColormapType = Data.ColormapType;
            NewData.DisplayUnits = Data.DisplayUnits;
            NewData.Options = Data.Options; % GIORGIO I keep the original info here
            NewData.History = Data.History;
            
            
            % get path from current input
            path =  bst_fileparts(file_fullpath(sInput.FileName));
            
            % save in the correct path
            t = datetime('now');
            curr_time = datestr(t, 'yyMMdd_HHmm');
            save([path, '/timefreq_connect1_plv_ex_s', num2str(iSeed), '_f', num2str(iFreq), '_', curr_time, '.mat'], '-struct', 'NewData');
            
            
            
        end;
        
    end
    
    
end

db_reload_studies(sInputs(iInput).iStudy)


end