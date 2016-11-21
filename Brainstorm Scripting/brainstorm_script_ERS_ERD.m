% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end


%% SET EXPORT FOLDER FOR REPORTS
export_folder='/Users/giorgioarcara/Documents/Lavori San Camillo/MEGHEM analisi marzo 2016/MEGHEM_analysis_reports/Scout_ERS_ERD'


%% SET PROTOCOL
ProtocolName = 'Meghem_analisi_3';

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
my_sFiles_string={'First_Corr_'}

  for iCondition=1:length(mysFiles_string)
    % make the first selection with bst process
    my_sFiles_ini = bst_process('CallProcess', 'process_select_files_timefreq', [], [], ...
        'subjectname', 'All', ...
        'includeintra',  0,...
        'tag',         my_sFiles_string{iCondition});


    my_sel_sFiles=sel_files_bst({ my_sFiles_ini(:).FileName }, '.', 'average');


end;




%% SEPARATE FILES FOR SUBJECT 
SubjectNames={my_subjects.Subject(2:end).Name}; % NOTE! the 2-end, to exclude the intra trials

Subj_grouped=group_by_str_bst(my_sel_sFiles, SubjectNames);

%% SEPARATE FILES BY RUN
runs={'_01_','_02_', '_03_'} 
Subj_run={};


for iSubj=1:length(Subj_grouped)
    
    Subj_run{iSubj}=group_by_str_bst(Subj_grouped{iSubj}, runs); % IMPORTANT: notice I enter in the cell {}
    
end;

%%% CORRECTION FOR SUBJECT MH005
% Subject 05, has run _01_, _03_ and _04
Subj_run{5}{2}=Subj_run{5}{3} % put run 3 in cell 2
other_run=sel_files_bst(my_sel_sFiles, '(MH005/)([\w]+)(_04_)'); % \w match for all alphanumeric characters

Subj_run{5}{3}=other_run;


%% SEPARATE FILES BY CONDITION
Conditions={'_Fast18','_Slow18'} 
Subj_run_Condition={}

for iSubj=1:length(Subj_grouped)
    for irun=1:length(runs)
    Subj_run_Condition{iSubj}{irun}=group_by_str_bst(Subj_run{iSubj}{irun}, Conditions); % IMPORTANT: notice I enter in the cell {}   
    end;
end;



%% RETRIEVE SOURCE FILES


%% TIME-FREQUENCY ANALYSIS SCOUT LEVEL (SEPARATE FOR RUN).
for iSubj=2:length(SubjectNames)
    for irun=1:length(runs)
        for iCond=1:length(Conditions)
        curr_files=Subj_run_Condition{iSubj}{irun}{iCond};
        
        %% RETRIEVE SOURCE (LINK) FILES
        % retrieve condition path
        curr_study=bst_get('StudyWithCondition', bst_fileparts(curr_files{1}));
        
        % exclude with the following steps the empty filenames, in the
        % ResultFile, otherwise cannot use intersect
        no_empty_DataFile_ind=find(~cellfun(@isempty, {curr_study.Result.DataFile}));
        no_empty_Resultfile=curr_study.Result(no_empty_DataFile_ind);
        
        % find intersection between curr-files (the data to be processed)
        % and the non-empty Resultfile names
        [a ind_curr_files ind_no_empty_Resultfile]=intersect(curr_files, {no_empty_Resultfile.DataFile});
        
        % retrieve link_files
        link_files={no_empty_Resultfile(ind_no_empty_Resultfile).FileName};        
        
        
                % Start a new report
        bst_report('Start', link_files);

        % Process: Time-frequency (Morlet wavelets)
        Res = bst_process('CallProcess', 'process_timefreq', link_files, [], ...
            'clusters',  {'Destrieux - centroid', {'G_Ins_lg_and_S_cent_ins L', 'G_Ins_lg_and_S_cent_ins R', 'G_and_S_cingul-Ant L', 'G_and_S_cingul-Ant R', 'G_and_S_cingul-Mid-Ant L', 'G_and_S_cingul-Mid-Ant R', 'G_and_S_cingul-Mid-Post L', 'G_and_S_cingul-Mid-Post R', 'G_and_S_frontomargin L', 'G_and_S_frontomargin R', 'G_and_S_occipital_inf L', 'G_and_S_occipital_inf R', 'G_and_S_paracentral L', 'G_and_S_paracentral R', 'G_and_S_subcentral L', 'G_and_S_subcentral R', 'G_and_S_transv_frontopol L', 'G_and_S_transv_frontopol R', 'G_cingul-Post-dorsal L', 'G_cingul-Post-dorsal R', 'G_cingul-Post-ventral L', 'G_cingul-Post-ventral R', 'G_cuneus L', 'G_cuneus R', 'G_front_inf-Opercular L', 'G_front_inf-Opercular R', 'G_front_inf-Orbital L', 'G_front_inf-Orbital R', 'G_front_inf-Triangul L', 'G_front_inf-Triangul R', 'G_front_middle L', 'G_front_middle R', 'G_front_sup L', 'G_front_sup R', 'G_insular_short L', 'G_insular_short R', 'G_oc-temp_lat-fusifor L', 'G_oc-temp_lat-fusifor R', 'G_oc-temp_med-Lingual L', 'G_oc-temp_med-Lingual R', 'G_oc-temp_med-Parahip L', 'G_oc-temp_med-Parahip R', 'G_occipital_middle L', 'G_occipital_middle R', 'G_occipital_sup L', 'G_occipital_sup R', 'G_orbital L', 'G_orbital R', 'G_pariet_inf-Angular L', 'G_pariet_inf-Angular R', 'G_pariet_inf-Supramar L', 'G_pariet_inf-Supramar R', 'G_parietal_sup L', 'G_parietal_sup R', 'G_postcentral L', 'G_postcentral R', 'G_precentral L', 'G_precentral R', 'G_precuneus L', 'G_precuneus R', 'G_rectus L', 'G_rectus R', 'G_subcallosal L', 'G_subcallosal R', 'G_temp_sup-G_T_transv L', 'G_temp_sup-G_T_transv R', 'G_temp_sup-Lateral L', 'G_temp_sup-Lateral R', 'G_temp_sup-Plan_polar L', 'G_temp_sup-Plan_polar R', 'G_temp_sup-Plan_tempo L', 'G_temp_sup-Plan_tempo R', 'G_temporal_inf L', 'G_temporal_inf R', 'G_temporal_middle L', 'G_temporal_middle R', 'Lat_Fis-ant-Horizont L', 'Lat_Fis-ant-Horizont R', 'Lat_Fis-ant-Vertical L', 'Lat_Fis-ant-Vertical R', 'Lat_Fis-post L', 'Lat_Fis-post R', 'Pole_occipital L', 'Pole_occipital R', 'Pole_temporal L', 'Pole_temporal R', 'S_calcarine L', 'S_calcarine R', 'S_central L', 'S_central R', 'S_cingul-Marginalis L', 'S_cingul-Marginalis R', 'S_circular_insula_ant L', 'S_circular_insula_ant R', 'S_circular_insula_inf L', 'S_circular_insula_inf R', 'S_circular_insula_sup L', 'S_circular_insula_sup R', 'S_collat_transv_ant L', 'S_collat_transv_ant R', 'S_collat_transv_post L', 'S_collat_transv_post R', 'S_front_inf L', 'S_front_inf R', 'S_front_middle L', 'S_front_middle R', 'S_front_sup L', 'S_front_sup R', 'S_interm_prim-Jensen L', 'S_interm_prim-Jensen R', 'S_intrapariet_and_P_trans L', 'S_intrapariet_and_P_trans R', 'S_oc-temp_lat L', 'S_oc-temp_lat R', 'S_oc-temp_med_and_Lingual L', 'S_oc-temp_med_and_Lingual R', 'S_oc_middle_and_Lunatus L', 'S_oc_middle_and_Lunatus R', 'S_oc_sup_and_transversal L', 'S_oc_sup_and_transversal R', 'S_occipital_ant L', 'S_occipital_ant R', 'S_orbital-H_Shaped L', 'S_orbital-H_Shaped R', 'S_orbital_lateral L', 'S_orbital_lateral R', 'S_orbital_med-olfact L', 'S_orbital_med-olfact R', 'S_parieto_occipital L', 'S_parieto_occipital R', 'S_pericallosal L', 'S_pericallosal R', 'S_postcentral L', 'S_postcentral R', 'S_precentral-inf-part L', 'S_precentral-inf-part R', 'S_precentral-sup-part L', 'S_precentral-sup-part R', 'S_suborbital L', 'S_suborbital R', 'S_subparietal L', 'S_subparietal R', 'S_temporal_inf L', 'S_temporal_inf R', 'S_temporal_sup L', 'S_temporal_sup R', 'S_temporal_transverse L', 'S_temporal_transverse R'}}, ...
            'scoutfunc', 1, ...  % Mean
            'edit',      struct(...
                 'Comment',         'Scouts,Avg,Power,1-150Hz', ...
                 'TimeBands',       [], ...
                 'Freqs',           [1, 2, 3.1, 4.2, 5.4, 6.7, 8, 9.5, 11, 12.6, 14.3, 16.1, 18.1, 20.1, 22.3, 24.6, 27, 29.6, 32.4, 35.3, 38.4, 41.6, 45.1, 48.8, 52.7, 56.9, 61.3, 66, 70.9, 76.2, 81.8, 87.7, 94, 100.6, 107.7, 115.2, 123.1, 131.6, 140.5, 150], ...
                 'MorletFc',        1, ...
                 'MorletFwhmTc',    3, ...
                 'ClusterFuncTime', 'after', ...
                 'Measure',         'power', ...
                 'Output',          'average', ...
                 'RemoveEvoked',    0, ...
                 'SaveKernel',      0), ...
            'normalize', 'none');  % None: Save non-standardized time-frequency maps
        
       % Process: Add tag: Prova
        Res = bst_process('CallProcess', 'process_add_tag', Res, [], ...
            'tag',  [mysFiles{1}, Conditions{iCond}]   , ...
            'output', 1);  % Add to comment

        % Save and export report
        ReportFile = bst_report('Save', Res);
        bst_report('Export', ReportFile,  export_folder);
        
        end;
    end;
end,
        %bst_report('Open', ReportFile);

        
        
        
        
        







