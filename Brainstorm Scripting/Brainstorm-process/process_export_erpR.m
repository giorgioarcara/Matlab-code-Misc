function varargout = process_export_erpR( varargin )
% PROCESS_ADD_TAG: Add a comment tag.
%
% USAGE:     sProcess = process_export_erpR('GetDescription')
%                       process_export_erpR('Run', sProcess, sInputs)

% @=============================================================================
%
% Authors: Giorgio Arcara, 26/06/2021, version 0.992

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'export to erpR';
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
sProcess.Description = 'https://sites.google.com/site/giorgioarcara/erpr';
% Definition of the options

% Decription of the files
sProcess.options.ProcessDescr.Comment = ['The process will export according to the option selected.<BR>' ...
    'If not blank, Options 2 overrides Option 1.<BR><BR>'];
sProcess.options.ProcessDescr.Type    = 'label';


% === OUTPUT NAME OPTION 1 number from condition
% Substitute with Nan (explanation)
sProcess.options.charsTitle.Comment = ['<B>OPTION 1: generate from Condition Name'];
sProcess.options.charsTitle.Type    = 'label';

sProcess.options.chars.Comment = 'Number of characters of Condition';
sProcess.options.chars.Type    = 'value';
sProcess.options.chars.Value   = {10, '', 0}; % the second number indicates the numbers after decimall separator.

sProcess.options.tag.Comment = 'add tag to auto generated base';
sProcess.options.tag.Type    = 'text';
sProcess.options.tag.Value   = ''; %


% Separatore
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = ' ';


% === OUTPUT NAME OPTION 2 BASE

% Substitute with Nan (explanation)
sProcess.options.BaseTitle.Comment = ['<B>OPTION 2: Specify erpR ''base'' </B>'];
sProcess.options.BaseTitle.Type    = 'label';

sProcess.options.base.Comment = 'Base';
sProcess.options.base.Type    = 'text';
sProcess.options.base.Value   = '';

% Separatore
sProcess.options.separator3.Type = 'separator';
sProcess.options.separator3.Comment = ' ';

sProcess.options.FileInfo.Comment = 'add file info (in first line of file)';
sProcess.options.FileInfo.Type    = 'text';
sProcess.options.FileInfo.Value   = '';

% Separatore
sProcess.options.separator4.Type = 'separator';
sProcess.options.separator4.Comment = ' ';

% Determine. Numbers

sProcess.options.Num.Comment = ['Determine erpR ''number'' from Brainstorm Subject Name' ];
sProcess.options.Num.Type    = 'checkbox';
sProcess.options.Num.Value   = 1;

% Separatore
sProcess.options.separator2.Type = 'separator';
sProcess.options.separator2.Comment = ' ';


sProcess.options.TrialTime.Comment = ['Add absolute time info in first line (!! Only single Trial)' ];
sProcess.options.TrialTime.Type    = 'checkbox';
sProcess.options.TrialTime.Value   = 0;

sProcess.options.ScoutName.Comment = ['Fix Scout names (!! check this only if you are using scouts)' ]; % this is incessary for those cases in which the Scout Name is modified adding the file name
sProcess.options.ScoutName.Type    = 'checkbox';
sProcess.options.ScoutName.Value   = 1;


% Separatore
sProcess.options.separator3.Type = 'separator';
sProcess.options.separator3.Comment = ' ';

% add vector with frequencies
sProcess.options.FreqVec.Comment = 'Add vector with Frequencies (check this only for PSD or FT)';
sProcess.options.FreqVec.Type    = 'checkbox';
sProcess.options.FreqVec.Value   = 1;

% Substitute with NaN
sProcess.options.TFave.Comment = 'Average TimeFreq data (check you are using avereage of TF)';
sProcess.options.TFave.Type    = 'checkbox';
sProcess.options.TFave.Value   = 0;

sProcess.options.StudyName.Comment = 'Add study name to export name';
sProcess.options.StudyName.Type    = 'checkbox';
sProcess.options.StudyName.Value   = 0;


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
        
        myCondName=sProcess.options.base.Value;
        
        
    else % otherwise use number of characters
        
        % get condition name (it will be the 'base' in erpR terms)
        % the end will be the minimum between the actual length and the
        % number supplied with Condition numbers
        
        end_myCondName=min([length(sInput.Comment), sProcess.options.chars.Value{1}]);
        
        myCondName = sInput.Comment(1: end_myCondName); % get the length of Condition name from options
        
        % and add tag if present
        myCondName = [myCondName, sProcess.options.tag.Value];
        
    end;
    
    
    %% DEFINE NUMBER
    % get Subject Name (if checkbox is checked)
    if sProcess.options.Num.Value
        Curr_Subj_Name=strcat('_', sInput.SubjectName);
    else
        Curr_Subj_Name='';
    end
    
    %% GET STARTING TIME (IF CHECKBOX TRUE)
    
    if sProcess.options.TrialTime.Value
        Trial_Time = get_starting_time_trial(sInput.FileName);
    end;
    %
    
    %% DEFINE EXPORT NAME (combination of condition and subject).
    %export_name=strcat(myCondName, Curr_Subj_Name, '.txt');
    
    % small correction of export name (':' can give problems)
    %export_name=strrep(export_name, ':', '_');
    
    % get number of average data, to understand if this is a single
    % trial or averaged data. the function is meant to be used with
    % erpR (and with average data).
    
    my_nAvg = in_bst_data(sInput.FileName, 'nAvg');
    my_nAvg_num= my_nAvg.nAvg; % my_nAvg is a struct. Get the number
    
    %% case: Data (Recordings)
    if strcmp(sInput.FileType, 'data');
        
        DataMat = in_bst_data(sInput.FileName, 'F', 'Time');
        % note: the ChannelFlag is automatically retrieved.
        
        ChannelData=in_bst_data(sInput.ChannelFile);
        Channel_ind = strcmp('Name', fields(ChannelData.Channel));
        ChannelCell=struct2cell(ChannelData.Channel);
        
        ChannelLabels=ChannelCell(Channel_ind, :);
        
        %get Bad Channels labels
        myBadChans=ChannelLabels(DataMat.ChannelFlag==-1);
        
        if sProcess.options.BadChans.Value
            DataMat.F(DataMat.ChannelFlag==-1,:)=NaN;
        end
        
        
        % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
        myData=DataMat.F';
        
    end
    
    %% case: TimeFreq (recordings)
    if strcmp(sInput.FileType, 'timefreq')
        
        DataMat = in_bst_data(sInput.FileName, 'TF', 'Time', 'RowNames', 'DataType', 'Method', 'Freqs');
        
        % squeeze in case there is a singleton dimension
        DataMat.TF = squeeze(DataMat.TF);
        
        %% case recordings or data
        % (I think that now are 'data' due to an update and 'recordings' is deprecated)
        if strcmp(DataMat.DataType, 'recordings')|strcmp(DataMat.DataType, 'data') &  sProcess.options.TFave.Value==0;
            
            % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
            % myData=DataMat.TF';
            
            % GET CHANNEL DATA
            ChannelData=in_bst_data(sInput.ChannelFile);
            Channel_ind = strcmp('Name', fields(ChannelData.Channel));
            ChannelCell=struct2cell(ChannelData.Channel);
            
            ChannelLabels=ChannelCell(Channel_ind, :);
            
            
            % GET BAD CHANNELS
            
            % case one single trial (TF) (not recommended for erpR).
            if my_nAvg_num==1
                % Notice that to retrieve the ChannelFlag I have to access the DataFile (not
                % Filename). The "parent" of the TF file is the DataFile (i.e.
                % the recording file file (this is clear from the GUI in brainstorm) and the chanflag is stored there.
                % WARNING! This is true if the TF file is NOT an average.
                
                ChanData = in_bst_data(sInput.DataFile, 'ChannelFlag');
                
                % get Bad Channels labels
                myBadChans=ChannelLabels(ChanData.ChannelFlag==-1);
                
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
                    
                    %
                    
                    tempDataMat(Ichans,:) = squeeze(DataMat.TF);
                    
                    %% transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
                    myData = tempDataMat';
                    
                else
                    % transpose data for erpR (in erpR is timepoints x channels, in bst channels x timepoints)
                    % for both single trial cases and average case
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
        
        % case psd and ft add frequency vector (only for psd and ft)
        if (strcmp(DataMat.Method, 'psd')|strcmp(DataMat.Method, 'ft')|sProcess.options.TFave.Value==1)
            
            
            % case in which you want to disregard time (cause average is used).
            if(sProcess.options.TFave.Value==1)
                DataMat.TF=DataMat.TF(:,1,:); % this is to take only the first timepoint in the case of PSD
            end
            
            
            myData = squeeze(DataMat.TF)';
            
            
            ChannelLabels=DataMat.RowNames; %overwrite preceding calculated ChannelLabels
            
            % insert Frequency vector as first column (only for psd and tf).
            
            
            if sProcess.options.FreqVec.Value
                
                
                % fix channel name for psd
                if sProcess.options.ScoutName.Value
                    ChanLab_ind =  regexp(ChannelLabels, '\.|@.'); % i use the \. cause it is the first symbol before the added name (it happens sometimes after extraction). @ is in the case of Group analysis.
                    for iChan = 1:length(ChannelLabels)
                        or_lab = ChannelLabels{iChan};
                        ChannelLabels{iChan} = or_lab(1: (ChanLab_ind{iChan}(1)-1) ); % the -1 is to avoid that the "." will be included in the name
                    end;
                end;
                
                % the next few lines are necessary to make this function
                % works in two cases with PSDon channels and with PSDon
                % sources. This is because ChannelLabels object has
                % different dimensions in the two cases (a row vector or a
                % col vector). The check of size use the appropriate
                % orientation to combine with the Colname 'Freq1' to be
                % added in the export file.
                if size(ChannelLabels, 1) == 1
                    ChannelLabels = ['Freqs', ChannelLabels];
                elseif size(ChannelLabels,2) == 1
                    ChannelLabels = ['Freqs', ChannelLabels'];
                end;
                
                myData=[DataMat.Freqs' myData]; % add Freqs as first column
                
                myBadChans=[];
                %set Bad Channels labels to be empty.
                % in matrix files, Bad Channels has no meaning (no fixed number
                % of sensor/channels are assumed)
                
                
                
                
            end;
            
        end;
        
        
        
    end;
    
    %% CASE MATRIX
    
    %% case: Data
    if strcmp(sInput.FileType, 'matrix');
        
        DataMat = in_bst_data(sInput.FileName, 'Value', 'Time', 'Description');
        % note: the ChannelFlag is automatically retrieved.
        
        % Define Channel labels
        ChannelLabels=DataMat.Description;
        
        if sProcess.options.ScoutName.Value
            ChanLab_ind =  regexp(ChannelLabels, '\.|@.'); % i use the \. cause it is the first symbol before the added name (it happens sometimes after extraction). @ is in the case of Group analysis
            for iChan = 1:length(ChannelLabels)
                or_lab = ChannelLabels{iChan};
                ChannelLabels{iChan} = or_lab(1: (ChanLab_ind{iChan}(1)-1) ); % the -1 is to avoid that the "." will be included in the name
            end;
        end;
        
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
    
    % DEPRECATED: add a warning, in case the function is used with single trials.
    % the number of trial will be added to the name.
    if (my_nAvg_num==1)
        bst_report('Warning', sProcess, sInput, ['You exported a single trial (not an average)']);
        
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
    
    
    %% DEFINE EXPORT NAME (combination of condition and subject).
    export_name=strcat(myCondName, '_', Curr_Subj_Name, n_trial_name, '.txt');
    % small correction of export name (':' can give problems)
    export_name=strrep(export_name, ':', '_');
    export_name=strrep(export_name, '/', '_');
    
    if sProcess.options.StudyName.Value
        
        export_name = [sInput.Condition, '_', export_name];
        
    end;
    
    
    
    % FIRST LINE COMMENT define the comment to be put in the file
    % (in the first line)-
    
    myComment =  Curr_Subj_Name;
    
    % in the case there is no Number in the first line (the Comment) the
    % whole file name is written again (necessary to avoid problems with
    % fprintf.
    
    if isempty(myComment)
        myComment = export_name
    end;
    
    
    %% add trial time if checked
    
    if sProcess.options.TrialTime.Value
        myComment = [myComment, '; Time = ', num2str(Trial_Time)];
    end;
    
    
    fid = fopen(export_name, 'w');
    fprintf(fid, '%s ', myComment); % print comment (first row)
    if length(myBadChans)>0
        fprintf(fid, '%s', 'BAD CHANS: ');
        fprintf(fid, '%s; ', myBadChans{:});
    end;
    fprintf(fid, '%s', sProcess.options.FileInfo.Value);
    fprintf(fid, '\n', '');
    fprintf(fid, '%s\t', ChannelLabels{:}); % print channel labels (second row)
    fprintf(fid, '\n', '');
    for i=1:size(myData,1);%     % print data (transposed, in order to use the erpR format)
        fprintf(fid, '%d\t', myData(i,:));
        fprintf(fid, '\n', '');
    end;
    fclose(fid);
    
    
end;

%% function get_starting_time_trial(bst_trial_file)
% This function takes as input the name of a bst trial and return the
% absoulte time in the experiment. It is useful to sort trials.
%
%
% EXAMPLE:
% filename = 'Subject01/sj0011_high_resample/data_S_20_trial002.mat'
%
% Author: Giorgio Arcara
%
% Version: 14/01/2018
%
    function trial_ini_t = get_starting_time_trial(bst_trial_file)
        trial_history = in_bst_data(bst_trial_file, 'History');
        trial_history = trial_history.History;
        
        % find cell row with import_time
        t = regexp(trial_history(:,2), 'import_time');
        % retrieve index
        ind = find(~cellfun(@isempty, t));
        % retrieve value
        trial_t = eval(trial_history{ind, 3});
        % retrieve only starting time (absolute).
        trial_ini_t = trial_t(1);
        %% NOTE: you can write this number as first line of the .txt as (to order in a second moment the trial in R).
    end;
    
end





