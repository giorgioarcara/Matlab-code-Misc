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