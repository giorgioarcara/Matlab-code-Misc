function varargout = process_delete_headmodels_sources( varargin )
% PROCESS_export_EVENTS: delete all headmodels and sources (including kernels) of a study.
%
% USAGE:     sProcess = process_delete_headmodels_sources('GetDescription')
%                       process_delete_headmodels_sources('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 2018, version 0.1

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'delete headmodels and/or sources';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Giorgio';
sProcess.Index       = 1021;
%sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'raw', 'data', 'results', 'timefreq', 'matrix'};
sProcess.OutputTypes = {'raw', 'data', 'results', 'timefreq', 'matrix'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
%sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options
% Instructions
sProcess.options.Instructions.Comment='Delete all head models or source files';
sProcess.options.Instructions.Type='label';

% Delete head models
sProcess.options.deletehead.Comment = 'Delete Head models';
sProcess.options.deletehead.Type    = 'checkbox';
sProcess.options.deletehead.Value   = 0;

% Delete kernels models
sProcess.options.deletsources.Comment = 'Delete Sources (including Kernels)';
sProcess.options.deletsources.Type    = 'checkbox';
sProcess.options.deletsources.Value   = 0;

end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process.

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

OutputFiles = [];

if (~sProcess.options.deletehead.Value) & (~sProcess.options.deletsources.Value)
    error('You did not select anything!');
end;

% determine study names
% CRUCIAL PART!!!
sStudies = bst_get('Study', unique([sInputs.iStudy]));

% initialize objects containing iStudy (indices)
iStudies = zeros(length(sStudies), 1);

for iInput = 1:length(sStudies)
    
    
    curr_iStudy = sInputs(iInput).iStudy;
    iStudies(iInput) = curr_iStudy; % store the iStudy for reload at the end
    
    curr_sStudy = bst_get('Study', curr_iStudy);
    
    headmodel_files = {};
    kernel_files = {};
    
    % delete headmodels
    if sProcess.options.deletehead.Value
        headmodel_files = {curr_sStudy.HeadModel.FileName};
    end;
    
    % delete kernels (and links
    if sProcess.options.deletsources.Value
        kernel_files = {curr_sStudy.Result.FileName};
    end;
    
    all_files = {kernel_files{:}, headmodel_files{:}};
    
    if isempty(all_files)
        bst_report('Warning', sProcess, sInputs, ['There is no headmodel or sources for this study']);
    else
    % add full path
    all_files = file_fullpath(all_files);
    
    cellfun(@delete, all_files);
    
    end;
       
    
end;

db_reload_studies(iStudies);

end



