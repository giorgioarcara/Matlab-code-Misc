%% export_script(script_name, my_sFiles_ini)
%
% This function export the current version of sript used (and data used)
% in a structure of folders. A folder is created 'Scrit_track'
% This folder contains two folders: Objects_used, an Scripts_launched
%     -Objects_used contains the .mat files with the sructure containing the
%      sFiles names, as imported from brainstorm with
%      'process_select_files_data'. The time stamp od the moment the object
%      is created is added to the filenae
%    - Scripts_launched contains the script actually launched with the time stamp included.
% IMPORTANT : this function is meant to be used with the script name object
% created with these lines.
%
%
% script_name = mfilename('fullpath')
%
% if (length(script_name) == 0)
%     error('You must run this script by calling it from the prompt or clicking the Run button!')
% end
%
%
% This ensure that the code is run by aunching the script (the last saved script). Hence
% that the script saved with the function is EXACTLY the one used with the last
% modifications saved. In other words, in this way the function cannot be used
%  copy-pastin the code, but launching a script.
%
% Author: Giorgio Arcara
%
% Version: 18/05/2017

function export_script(script_name, my_sFiles_ini)

curr_script_folder = fileparts(script_name);


save_data_folder = [curr_script_folder, '/Scripts_track/Objects_used/'];
save_script_folder = [curr_script_folder, '/Scripts_track/Scripts_launched/']


if ~exist(save_data_folder)
    mkdir(save_data_folder) % create folder if it does not exist
end;

if ~exist(save_script_folder)
    mkdir(save_script_folder) % create folder if it does not exist
end;

curr_time = datestr(now, 'dd_mm_yyyy_HH_MM_SS');
[~, script_name_nopath] = fileparts(script_name);


% save object for the script run
save([save_data_folder, script_name_nopath, '_', curr_time, '.mat'], 'my_sFiles_ini');

% import script run
myfid=fopen([script_name, '.m']);

k=1;
tline=fgetl(myfid);

while ischar(tline)
    myfile{k}=tline;
    k=k+1;
    tline=fgetl(myfid); % note that I create tline here (at the end) to
    % make the while cycle work properly (otherwise at the last cycle it
    % will not work
end;

% save script
n_of_points=length(myfile);


newfilename = [save_script_folder, script_name_nopath, curr_time, '.m'];

fid=fopen(newfilename, 'w');
for i=1:n_of_points
    fprintf(fid, '%s\n', myfile{i});
end;

fclose(fid);
%%%%%%%% ----------------------------------%%%%%%%%%%%%%
end
