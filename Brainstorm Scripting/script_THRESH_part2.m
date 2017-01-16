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



%for iSubj=1:length(SubjectNames)
    iSubj=1
    %% duplicate for each SplitHalf
    %for iSplitHalf=1:length(SH)
    iSplitHalf=1
    
        
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
    
    % generate ALL possibile threshosld
    
    % TEST
    test_sorted=sort(curr_test);
    
    % the following code make all possibile threshold in a single check by
    % comparing the data, (replicated length(data) times) for the possible
    % threshold (with each value, replicated length(data) times).
    curr_test_rep=repmat(curr_test, length(curr_test), 1);
    test_sorted_rep=repmat(test_sorted,  1, length(test_sorted))';
    test_sorted_rep=test_sorted_rep(:); % code taken from https://it.mathworks.com/matlabcentral/answers/46898-repeat-element-of-a-vector-n-times-without-loop    
    
    
    curr_test_filt_vec=curr_test_rep>test_sorted_rep;
    curr_test_filt_mat=reshape(curr_test_filt_vec, length(curr_test), length(curr_test));
    
    % RETEST
    retest_sorted=sort(curr_retest);

    curr_retest_rep=repmat(curr_retest, length(curr_retest), 1);
    retest_sorted_rep=repmat(retest_sorted,  1, length(retest_sorted))';
    retest_sorted_rep=retest_sorted_rep(:); % code taken from https://it.mathworks.com/matlabcentral/answers/46898-repeat-element-of-a-vector-n-times-without-loop    
    
        
    curr_retest_filt_vec=curr_retest_rep>retest_sorted_rep;
    curr_retest_filt_mat=reshape(curr_retest_filt_vec, length(curr_retest), length(curr_retest));
    
    % the following objects are not necessary, but help me to think about
    % the problem.
    TPR_test=zeros(length(curr_test_mat), length(curr_test_mat));
    FPR_test=zeros(length(curr_test_mat), length(curr_test_mat));
    
    TPR_retest=zeros(length(curr_retest_mat), length(curr_retest_mat));
    FPR_retest=zeros(length(curr_retest_mat), length(curr_test_mat));
   
    AUC_test=zeros(1, length(TPR_test));
    AUC_retest=zeros(1, length(TPR_retest));
    
    
   for istep=1:length(curr_test)
            
  
            %  use notation of Stevens et al. 2014 (p. 314, Fig 1).
            % A12 = voxel active in both test and retest
            % A2 = false positive: voxel active in retest not active in test
            % A1 = false negative: voxel active in test not active in retest
            % I12 = true negative: voxel not active in test and retest.

            
            % TPR = A1,2/[A1,2 + A1]
            % FPR = A2/[A2 + I1,2]
            
            
            % TEST
            curr_test_filt=repmat(curr_test_filt_mat(istep,:), 1, length(curr_test_filt_mat))';
            
            A12=sum((curr_test_filt+curr_retest_filt_vec)==2); % activation in both T1 and T2
            %% NON VA BENE: prima di fare la somma dovrei mettere in forma matriciale, assicurandomi che l'ordine sia giusto.
            
            A1=sum((curr_test_filt-curr_retest_filt_vec)==1); % false negative
            A2=sum((curr_retest_filt_vec-curr_test_filt)==1); % false positive
            I12= length(curr_test_filt) - sum( (curr_test_filt + curr_retest_filt_vec) > 0 ) ; %
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

        


