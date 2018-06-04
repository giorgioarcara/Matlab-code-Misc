% STEP3_import_epochs
% run all the script to import epochs

run('NOPOSA_startpath')
%
% NOT WORKING! 
% for some reasons the current script does not work. 
% I had to launch each script separately

%run('STEP3_import_epochs/STEP3_NOPOSA_import_epochs_ASSR.m')
run('STEP3_import_epochs/STEP3_NOPOSA_import_ProseResting.m')
run('STEP3_import_epochs/STEP3_NOPOSA_import_epochs_MMN.m')