%%
% this script works on a bst protocol in which pre-processing has been
% performed and script_THRESH_part1 was run
% aim of this script is to calculat AUC curves for several combinations

% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end



%% SET EXPORT FOLDER FOR REPORTS
export_main_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/Prove_threshold';
export_folder1='Split-Half';


if ~exist([export_main_folder, '/' export_folder1])
    mkdir([export_main_folder, '/' export_folder1]) % create folder if it does not exist
end;



%% SET PROTOCOL
ProtocolName = 'Prove_thresh';

% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')


%% SELECT  TRIALS
%
my_sFiles_string={'_runave'}

subject_sel='CT'

% make the first selection with bst process
my_sFiles_ini = bst_process('CallProcess', 'process_select_files_results', [], [], ...
    'subjectname', subject_sel, ...
    'includeintra',  1,...
    'tag',         my_sFiles_string{1});

% exclude trial with average
%my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');
my_sel_sFiles={my_sFiles_ini.FileName};

%% SEPARATE FILES FOR SUBJECT
SubjectNames={my_subjects.Subject.Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);


%% SEPARATE FILES BY SPLIT-HALF;
SH={'_SH_1', '_SH_2', };
Subj_SH={};

for iSubj=1:length(Subj_grouped)
    for iSH=1:length(SH)
        Subj_SH{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, SH); % IMPORTANT: notice I enter in the cell {}
    end;
end;

%% SEPARATE FILES BY TEST/RETEST
Conditions={'_test', '_retest'};
Subj_SH_testretest={};


for iSubj=1:length(Subj_grouped)
    for iSH=1:length(SH)
        Subj_SH_testretest{iSubj}{iSH}=group_by_str_bst(Subj_SH{iSubj}{iSH}, Conditions); % IMPORTANT: notice I enter in the cell {}
    end;     
end;



for iSubj=1:length(SubjectNames)
    for iSplitHalf=1:length(SH)
        
    %% CALCULATE MEAN IN WINDOW OF INTEREST %TO BE MOVED IN SCRIPT_THRESH PART 1

    % Start a new report
    bst_report('Start', Subj_SH_testretest{iSubj}{iSplitHalf}{1});
    
    % Process: Average time: [2.500s], abs
    Res_test = bst_process('CallProcess', 'process_average_time', Subj_SH_testretest{iSubj}{iSplitHalf}{1}, [], ...
        'timewindow', [0.4, 0.6], ...
        'isstd',      0, ...
        'overwrite',  0, ...
        'source_abs', 1);
    
        % Process: Average time: [2.500s], abs
    Res_retest = bst_process('CallProcess', 'process_average_time', Subj_SH_testretest{iSubj}{iSplitHalf}{2}, [], ...
        'timewindow', [0.4, 0.6], ...
        'isstd',      0, ...
        'overwrite',  0, ...
        'source_abs', 1);
    
    %% LOAD DATA E CALCULATE AUC CURVES
    curr_test_s=in_bst_data(Res_test.FileName, 'ImageGridAmp'); % get the struct
    curr_test=curr_test_s.ImageGridAmp(:,1); % select only first column. It is duplicated.
    
    curr_retest_s=in_bst_data(Res_retest.FileName, 'ImageGridAmp'); % get the struct
    curr_retest=curr_retest_s.ImageGridAmp(:,1); % select only first column. It is duplicated.
    
    %% GENERATE STEPS FOR AUC CURVES
    %  the output of this procedure will yeld four 2-d matrix. One for test
    %  and one for retest.
    % the matrices will have the following dimensions
    % - TPR values for TEST varying t1 threshold (m) x varying t2 threshold (n).
    % - FPR values for TEST varying t1 threshold (m) x varying t2 threshold (n).
    % - TPR values for RETEST varying t2 threshold (m) x varying t1 threshold (n).
    % - FPR values for RETEST varying t2 threshold (m) x varying t1 threshold (n).
    
    %% generate ALL possibile threshosld (THIS IS VERY LONG!!)
    % but is it really necessary? Do you really need 8000 possibile
    % threshold? To think about it!
    
    test_steps=sort(curr_test);
    retest_steps=sort(curr_retest);
    
    % generate 100 threshold among the observed values
    %curr_test_sorted=sort(curr_test) ;
    %test_steps=curr_test_sorted(1: round(length(curr_test_sorted)/100) : end);
    
    %curr_retest_sorted=sort(curr_retest) ;
    %retest_steps=curr_retest_sorted(1: round(length(curr_retest_sorted)/100) : end);
    
    % generate 100 equispaced threshold (suboptimal)
    %test_steps=linspace(min(curr_test), max(curr_test), 100);
    %retest_steps=linspace(min(curr_retest),  max(curr_retest), 100);
    
    TPR_test=zeros(length(test_steps), length(retest_steps));
    FPR_test=zeros(length(test_steps), length(retest_steps));
    
    TPR_retest=zeros(length(retest_steps), length(test_steps));
    FPR_retest=zeros(length(retest_steps), length(test_steps));
   
    AUC_test=zeros(1, length(TPR_test));
    AUC_retest=zeros(1, length(TPR_retest));
    
    
   for istep_test=1:length(test_steps)
        
        % filter with threhsold the test
        curr_test_filt=curr_test>test_steps(istep_test);
        
        for istep_retest=1:length(retest_steps)
                   
            
            % filter with threshold the retest
            curr_retest_filt=curr_retest>retest_steps(istep_retest);
            
            
            tic
            a=meshgrid(curr_test, curr_retest);
            toc
            %  use notation of Stevens et al. 2014 (p. 314, Fig 1).
            % A12 = voxel active in both test and retest
            % A2 = false positive: voxel active in retest not active in test
            % A1 = false negative: voxel active in test not active in retest
            % I12 = true negative: voxel not active in test and retest.
            
            % TPR = A1,2/[A1,2 + A1]
            % FPR = A2/[A2 + I1,2]
            A12=sum((curr_test_filt+curr_retest_filt)==2); % activation in both T1 and T2
            A1=sum((curr_test_filt-curr_retest_filt)==1); % false negative
            A2=sum((curr_retest_filt-curr_test_filt)==1); % false positive
            I12= length(curr_test_filt) - sum( (curr_test_filt + curr_retest_filt) > 0 ) ; %
            % TRUE NEGATIVE: voxels not active in test and retest. note: the second operand is the voxel active either in test or in retest (i use > 0 to transform in 0-1)
            % I operationalize the true negative as total number of voxels
            % minus voxels active either in test or in retest (or in both).
            
            TPR_test_i = A12./(A12 + A1);
            FPR_test_i = A2./(A2 + I12);
            
            TPR_retest_i = A12./(A12 + A2);
            FPR_retest_i = A1./(A1 + I12); % NOTE! here the results could be NaN if denominator is zero.
            
            TPR_test(istep_test, istep_retest)=TPR_test_i;
            FPR_test(istep_test, istep_retest)=FPR_test_i;
            
            TPR_retest(istep_retest, istep_test)=TPR_retest_i;
            FPR_retest(istep_retest, istep_test)=FPR_retest_i;          
        end;
            
    end;
    
    %% AUC CALCULATION
    % calculate AUC for test (varying t1 threshold) and retest (varying t2
    % threhold)
    AUC_test=zeros(1, length(TPR_test));
    AUC_retest=zeros(1, length(TPR_retest));
    
    for iAUC=1:length(AUC_test);
        AUC_test(iAUC)=trapz(FPR_test(:,iAUC), TPR_test(:, iAUC));
        AUC_retest(iAUC)=trapz(FPR_retest(:,iAUC), TPR_retest(:, iAUC));
    end;
    
    %% THRESHOLD OPTIMIZATION
    
   
        
        


    
    

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
    % bst_report('Export', ReportFile, ExportDir);

        


