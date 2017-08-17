function varargout = process_export_erpR( varargin )
% PROCESS_ADD_TAG: Add a comment tag.
%
% USAGE:     sProcess = process_export_erpR('GetDescription')
%                       process_export_erpR('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 8/5/2017, version 0.6

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'export to erpR';
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

% Separatore
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = ' ';

% Substitute with NaN
sProcess.options.BadChans.Comment = 'Substitute Bad Channels with NaN';
sProcess.options.BadChans.Type    = 'checkbox';
sProcess.options.BadChans.Value   = 1;

% Substitute with Nan (explanation)
sProcess.options.Text.Comment = ['<B>Note</B>: Don''t uncheck this box, <BR>' ...
    'unless you know exactly what you are doing. <BR>' ];
sProcess.options.Text.Type    = 'label';
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
    
    % get Channel Data
    ChannelData=in_bst_data(sInput.ChannelFile);
    ChannelCell=struct2cell(ChannelData.Channel);
    ChannelLabels=ChannelCell(1, :);
    
    % get number of average data, to understand if this is a single
    % trial or averaged data. the function is meant to be used with
    % erpR (and with average data).
    
    my_nAvg = in_bst_data(sInput.FileName, 'nAvg');
    my_nAvg_num= my_nAvg.nAvg; % my_nAvg is a struct. Get the number
    
    %% case: Data
    if strcmp(sInput.FileType, 'data');
        
        DataMat = in_bst_data(sInput.FileName, 'F', 'Time');
        % note: the ChannelFlag is automatically retrieved.
        
        %get Bad Channels labels
        myBadChans=ChannelLabels(DataMat.ChannelFlag==-1)
        
        if sProcess.options.BadChans.Value
            DataMat.F(DataMat.ChannelFlag==-1,:)=NaN;
        end
        
        
        % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
        myData=DataMat.F';
        
    end
    
    %% case: TimeFreq (recordings)
    if strcmp(sInput.FileType, 'timefreq')
        
        DataMat = in_bst_data(sInput.FileName, 'TF', 'Time', 'RowNames', 'DataType');
        
        %% case recordings or data 
        % (I think that now are 'data' due to an update and 'recordings' is deprecated)
        if strcmp(DataMat.DataType, 'recordings')|strcmp(DataMat.DataType, 'data') ;
            
            % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
            % myData=DataMat.TF';
            
            % GET BAD CHANNELS
            
            % case one single trial (TF) (not recommended for erpR).
            if my_nAvg_num==1
                % Notice that to retrieve the ChannelFlag I have to access the DataFile (not
                % Filename). The "parent" of the TF file is the DataFile (i.e.
                % the recording file file (this is clear from the GUI in brainstorm) and the chanflag is stored there.
                % WARNING! This is true if the TF file is NOT an average.
                
                ChanData = in_bst_data(sInput.DataFile, 'ChannelFlag');
                
                % get Bad Channels labels
                myBadChans=ChannelLabels(ChanData.ChannelFlag==-1)
                
                if sProcess.options.BadChans.Value
                    DataMat.TF(ChanData.ChannelFlag==-1,:)=NaN;
                end
                
            end;
            
            % case Avg
            if my_nAvg_num > 1
                % retrieve Bad channels as the channels not present in the current file
                % but present in the Subject channelFile
                myBadChans=setdiff(ChannelLabels, DataMat.RowNames);
                
                if (length(myBadChans) > 0)
                    
                    % re-create TF object inserting NaN when badchan.
                    tempDataMat=NaN(length(ChannelLabels), size(DataMat.TF,2));
                    
                    %retrive channel indices
                    %% add if statment, to correct in case uniforming channels funciton was used.
                    if any(cell2mat(regexp(DataMat.RowNames, '@'))) % first check if there is the symbol "@" in the data
                        
                        electrodes=cell(1, length(DataMat.RowNames) );
                        for iEl=1:length(DataMat.RowNames)
                            strings = strsplit(DataMat.RowNames{iEl});
                            elstr = strings{1};
                            electrodes{iEl}=elstr;
                        end;
                        
                        % in this case recalculate the bad chans, based on
                        % adjusted labels
                        myBadChans=setdiff(ChannelLabels, electrodes);
                        
                        
                    else
                        electrodes=DataMat.RowNames % this is the normal case.
                    end;
                    
                    
                    [~, Ichans] = intersect(ChannelLabels, electrodes, 'stable')
                    
                    tempDataMat(Ichans,:) = DataMat.TF;
                    
                    %% transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
                    myData = tempDataMat';
                    
                else
                    % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
                    myData = DataMat.TF';
                end
                
            end;
        end;
        
        
        %% case TF scout or data (i.e., after extraction)
        if strcmp(DataMat.DataType, 'scout');
            
            if length(size(DataMat.TF))==3;
                % notice the odd way to use errors
                bst_report('Error', sProcess, sInput, ['The current version of erpR export cannot work on multiple frequencies. <BR>'...
                    'Please extract the values of a single frequency (or band) before']);
            end;
            
            myData = DataMat.TF';
            ChannelLabels=DataMat.RowNames;
            % create dummy object for bad channels. Notice it
            % is empty
            myBadChans=[];
        end;
        
        
    end;
    
    %% CASE MATRIX
    % Note: this is meant to be used with matrix (for example extracted
    % sources). If you extract source it is better if you contacatenate on
    % the "2 DIMENSION". In this way you will keep the normal names of
    % scouts. If you concatenate on the first dimension, the name of the
    % file is addeed to the scout name (and this create a mess in the colnames).
    
    %% case: Data
    if strcmp(sInput.FileType, 'matrix');
        
        DataMat = in_bst_data(sInput.FileName, 'Value', 'Time', 'Description');
        % note: the ChannelFlag is automatically retrieved.
        
        % Define Channel labels
        ChannelLabels=DataMat.Description;
        
        
        %set Bad Channels labels to empty.
        % in matrix files, Bad Channels has no meaning (no fixed number
        % of sensor/channels are assumed).
        myBadChans=[];
        
        % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
        myData=DataMat.Value';
        
    end
    

    
    
    % initialize empty string for n_trial_name, the name associated with the trial number. 
    % Basically nothing will be added if the data are average (that is the
    % normal condition with erpR).
    
    n_trial_name='';
    
    % add a warning, in case the function is used with single trials.
    % the number of trial will be added to the name.
    
    if (my_nAvg_num==1)
        bst_report('Warning', sProcess, sInput, ['This process is meant to be used with Averaged data. <BR>' ...
            'This is a single trial']);
        
        trial_comment = sInput.Comment;
        % following lines extract the number from the comment string in
        % bst. Not particularly elegant, but should work
        % (better solve with a single regexp call)
            
        try
            n_trial_name_temp1 = strsplit(trial_comment, '(#');
            n_trial_name_temp2 = strsplit( n_trial_name_temp1{2}, ')' );
            n_trial_name = ['_', n_trial_name_temp2{1}];
        catch
        end;
        
    end;
    
    
       
    % DEFINE EXPORT NAME (combination of condition and subject).
    export_name=strcat(myCondName, '_', Curr_Subj_Name, n_trial_name, '.txt');
    % small correction of export name (':' can give problems)
    export_name=strrep(export_name, ':', '_');
    
    
    
    % FIRST LINE COMMENT define the comment to be put in the file
    % (in the first line)-
    
    myComment =  Curr_Subj_Name;
    
    fid = fopen(export_name, 'w');
    fprintf(fid, '%s ', myComment); % print comment (first row)
    if length(myBadChans)>0
        fprintf(fid, '%s', 'BAD CHANS: ');
        fprintf(fid, '%s; ', myBadChans{:});
    end;
    fprintf(fid, '\n', '');
    fprintf(fid, '%s\t', ChannelLabels{:}); % print channel labels (second row)
    fprintf(fid, '\n', '');
    for i=1:size(myData,1);%     % print data (transposed, in order to use the erpR format)
        fprintf(fid, '%d\t', myData(i,:));
        fprintf(fid, '\n', '');
    end;
    fclose(fid);
    
    
end;

end



