
% 1) select a file and extract_scout_time series with PCA. (flip sources with opposite sign (as this is automatically
% done when making scout PCA from bst_connectivity).


sFiles = {...
    'link|CT/CT_ArcaraMapping_20160127_03_band/results_MN_MEG_KERNEL_170227_1427.mat|CT/CT_ArcaraMapping_20160127_03_band/data_block002.mat'};

% Start a new report
bst_report('Start', sFiles);

% Process: Scouts time series: bankssts L bankssts R
sScout = bst_process('CallProcess', 'process_extract_scout', sFiles, [], ...
    'timewindow',     [5, 9.999166667], ...
    'scouts',         {'Desikan-Killiany', {'bankssts L', 'bankssts R'}}, ...
    'scoutfunc',      3, ...  % PCA
    'isflip',         1, ...
    'isnorm',         0, ...
    'concatenate',    1, ...
    'save',           1, ...
    'addrowcomment',  1, ...
    'addfilecomment', 1);


% 2) export the restults in matlab 
mysScout = in_bst_data(sScout.FileName);

H = zeros(size(mysScout.Value));
for i=1:size(mysScout.Value,1);
    H(i,:) = abs(hilbert(mysScout.Value(i,:)));
end;

mysScout.H=H;

%check if envelope is correct
figure 
subplot(2,1,1)
plot(mysScout.Value(1,:));
hold
plot(mysScout.H(1,:));
subplot(2,1,2)
plot(mysScout.Value(2,:));
hold
plot(mysScout.H(2,:));




%% save as matlab file so I can load it later during function call

save ('mysScout.mat', 'mysScout')


%% ------- IMPORTANT -------------
% run the following code after putting a break in bst_connectivity, lines
% 277


bst_report('Start', sFiles);

% Process: Correlation NxN
sCon = bst_process('CallProcess', 'process_corr1n', sFiles, [], ...
    'timewindow', [5, 9.999166667], ...
    'scouts',     {'Desikan-Killiany', {'bankssts L', 'bankssts R'}}, ...
    'scoutfunc',  3, ...  % PCA
    'scouttime',  1, ...  % Before
    'scalarprod', 0, ...
    'outputmode', 1);  % Save individual results (one file per input file)

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);


%% check if the input (the PCA) is the same, as the one performed above, in the call
% to extract scout time series
load('mysScout.mat')

figure
subplot(2,1,1)
plot(mysScout.Value(1,:))
hold
plot(sInputA.Data(1,:),'o')

subplot(2,1,2)
plot(mysScout.Value(2,:))
hold
plot(sInputA.Data(2,:),'o')

% NOTE! the value are not exactly the same. Due to difference in
% approximation
all(sInputA.Data == mysScout.Value)
 sInputA.Data(1,1:10) - mysScout.Value(1,1:10)
 % but rounded they are equal
 all(round(sInputA.Data, 7) == round(mysScout.Value, 7))

%% RESULTS (manual)
[Rman, pValuesman] = bst_corrn(mysScout.H, mysScout.H)

%% SEND THIS AFTER DECOMMENTING THE ADDED CODE BY G

load('mysScout.mat')

[R, pValues] = bst_corrn_G(sInputA.Data, sInputB.Data, OPTIONS.RemoveMean); 

