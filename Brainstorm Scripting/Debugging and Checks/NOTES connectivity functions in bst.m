%% What's happening in correlations


% Process: Correlation NxN
sFiles = bst_process('CallProcess', 'process_corr1n', sFiles, [], ...
    'timewindow', [0, 4.999166667], ...
    'scouts',     {'Desikan-Killiany', {'bankssts L', 'bankssts R'}}, ...
    'scoutfunc',  3, ...  % PCA
    'scouttime',  1, ...  % Before
    'scalarprod', 0, ...
    'outputmode', 1);  % Save individual results (one file per input file)

%% process_corr1n
% is the first process called (see above) .
%this function mostly doesn't do anything except calling bst_connectivity

%% bst_connectivity
% this function perform all the possibile operations related to
% connectivity

% line 667 process_average_rows

%% process_average_rows
% a crucial function, that make the aggreagate of nodes in scout.
% a crucial function called is
    %% bst_scout_value.m
    %there there is a functions PCAfirstMode. That apparently take
    % the first component of a PCA (fast performed).

%% bst_corrn
% the function which performs the correlation.called bt
% process_connectivity (line 277)


% How to check your script is correct (modification in bst_corrn);

% 1) select a file and extract_scout_time series with PCA. (flip sources with opposite sign (as this is automatically
% done when making scout PCA from bst_connectivity).
% 2) export the restults in matlab 
%  3) calculate envelope as abs(hilbert()) of the data (loop over rows will be necessary).
%  4) save both hilbert and orginal PCAed values in a file .mat, to be loaded after


% 5) call process_connectivity on the same file  again that your data are the same with those called in line 277.
% commenting at line 277 of bst_connectivity. load your results.mat and
% check is the same of sInputA, sInput B.
%

% 6) try to call manually the bst_corrn on the results.mat file (the
% hilbert tranasformed). And compare with the R values obtained in the line
% 277 AFTER APPLYING YOUR MODIFICATION THAT CALCULATE THE HILBERT.

 
