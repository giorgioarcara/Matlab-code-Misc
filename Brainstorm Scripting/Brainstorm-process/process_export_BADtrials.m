function varargout = process_export_erpR( varargin )
% PROCESS_ADD_TAG: Add a comment tag.
%
% USAGE:     sProcess = process_export_erpR('GetDescription')
%                       process_export_erpR('Run', sProcess, sInputs)

% @=============================================================================
% 
% Authors: Giorgio Arcara, 2016, version 0.2

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'export BAD trials';
    sProcess.FileTag     = '';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'File';
    sProcess.Index       = 1021;
    %sProcess.Description = 'http://neuroimage.usc.edu/brainstorm/SelectFiles#How_to_control_the_output_file_names';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'results', 'timefreq', 'matrix'};
    sProcess.OutputTypes = {'data', 'results', 'timefreq', 'matrix'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
    % Definition of the options
    % Instructions
    sProcess.options.Instructions.Comment='To export bad trials in .mat file';
    sProcess.options.Instructions.Type='label';
    % Separator
    sProcess.options.separator2.Type = 'separator';
    sProcess.options.separator2.Comment = '';
    % === RAGET
    sProcess.options.include.Comment = 'include text';
    sProcess.options.include.Type    = 'text';
    sProcess.options.include.Value   = ''; % the second number indicates the numbers after decimall separator.
    
    sProcess.options.exclude.Comment = 'exclude text';
    sProcess.options.exclude.Type    = 'text';
    sProcess.options.exclude.Value   = ''; 
    
    
end



%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end
% the comment is apparently a mandatory part of a brainstorm process. 

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
    
     OutputFiles = {sInputs.FileName};
     
     include_string = sProcess.options.include.Value;
     exclude_string = sProcess.options.exclude.Value;

     
     % determine study names 
     % CRUCIAL PART!!! 
     % in questa parte recupero solo gli study, evitando quindi eventuali
     % duplicati.
     sStudies = bst_get('Study', unique([sInputs.iStudy]));


      for s = 1:length(sStudies)
          
          % select current study
          sStudy = sStudies(s);
          
          % retrieve bad trials
          sStudy_BadTrials=[sStudy.Data(:).BadTrial];
          
          % retrieve bad trials indices
          BadTrials_indices=find(sStudy_BadTrials);
            
          % create empty matrix to store results
          BadTrials_timeinRAW=zeros(size(BadTrials_indices));
          
          %cicla su questi indici per recuperare il nome del file
          for i=1:length(BadTrials_indices);
              
              curr_trial=sStudy.Data(BadTrials_indices(i)).FileName;
              
              % get comment (to exclude/include)
              curr_trial_comment=sStudy.Data(BadTrials_indices(i)).Comment;
              
              % CHECK if the trial should be considered
              include_check=regexp(curr_trial_comment, include_string);
              
              exclude_check=regexp(curr_trial_comment, exclude_string);
              
              if isempty(include_check)
                  include_check=1; % if it is empty, include everything
              end;
              
              if isempty(exclude_check)
                  exclude_check=0; % if it empty, don't exclude anything
              end;
              
              % check if both the checks are ok. 
              if include_check & ~ exclude_check 
                  good_trial = 1;
              end
              
              % do the computations only if the trial is acceptable
              if good_trial
                  
                  curr_epoch=in_bst_data(curr_trial);
                  
                  
                  % adesso puoi calcolare il tempo esatto da copiare nel raw in questo
                  % modo
                  
                  %baseline
                  epoch_offset=curr_epoch.Time(1);
                  
                  % inizio e fine epoca in tempo sul tracciato raw.
                  %nota l'eval, perch? in realt? il contenuto ? testo
                  
                  epoch_times=eval(curr_epoch.History{3,3});
                  
                  % creo un evento (che chiamer? BAD), e lo metto un secondo dopo l'evento di
                  % riferimento. Che ? l'evento su cui ? stata costruita l'epoca.
                  
                  event_bad_time=epoch_times(1)+(-epoch_offset)+1;
                  
                  BadTrials_timeinRAW(i)=event_bad_time;
              end;
              
          end;
          
          % creo oggetto fake nel caso di nessun bad trials.
          % Per essere sicuro che comunque ho considerato quel file, nel caso in
          % cui non siano presenti bad trials, creo comunque un oggetto e gli
          % metto un tempo che fuori dai limiti del tracciato globale.
          % Se avessi avuto un evento vuoto sarebbe stato un problema per lo
          % script.
          
          if (length(BadTrials_timeinRAW)==0)
              BadTrials_timeinRAW=0
          end;
        
       % get Subject Name
       Curr_Study_Name=sStudy.Name; 
       
       save(strcat(Curr_Study_Name,'_BadTrials.mat'), 'BadTrials_timeinRAW')

          
       end;
    
end



