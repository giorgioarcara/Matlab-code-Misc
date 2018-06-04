% Script to add END_BAD events.

% THe script ADD an END_BAD event to the files. Starting from the end of
% the recordings and going backward n seconds. Useful to avoid effect of zero-padding on subsequent PSD.


% Input files
% Input files
sFiles = {...
    'CT/@rawCT_ArcaraMapping_20160127_03/data_0raw_CT_ArcaraMapping_20160127_03.mat'};


for iFile=1:length(sFiles);
    
    % select curr_file
    curr_raw_file=sFiles{iFile};
      
    % the following parameter set the duration of the bad segments from the
    % end.
    End_dur=3; % in seconds
    
    % load the data
    sRaw=in_bst_data(curr_raw_file);
    
    % retrieve final time (end of recordings)
    End_time=sRaw.Time(end);
    
    % determine time and sample according to End_dur
    End_time_1=End_time-End_dur;
    End_time_1_ind=dsearchn(sRaw.Time', End_time_1);
    End_time_1_exact=sRaw.Time(End_time_1_ind);
    
    
    % Add new bad event %
    % !!! NOTE: at the first step the index is (end +1) cause a new
    % event is created and added to the struct. Tehn is just (end)
    sRaw.F.events(end+1).label ='End_BAD2';
    sRaw.F.events(end).color = [1 0.6000 0];
    sRaw.F.events(end).epochs = 1;
    sRaw.F.events(end).times = [ End_time_1_exact; End_time ];
    sRaw.F.events(end).samples = [End_time_1_ind; length(sRaw.Time)];
    sRaw.F.events(end).select = 1;
    
    
    bst_save(file_fullpath(curr_raw_file), sRaw, 'v6', 1);
end;



