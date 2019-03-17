%% USER INPUT

BrainstromDB_folder = '/Users/giorgioarcara/Documents/Brainstorm_db/';
OriginalProtocolName = 'PROVA_BARI';


NewProtocolName = 'PROVA_BARI2';

% restrict anat
include_anat_string = 'PROVA2';  % leave a dot to select everything
exclude_anat_string = '';

% restrict subject
include_data_string = 'PROVA2';
exclude_data_string = '';

% restrict study
include_study_string = '@raw';
exclude_study_string = '';

% restrict file (currently nothing).
include_file_string = '';
exclude_file_string = '';




% current version. Copy only Raw
% future version, you can select the subject names or some folders.


%% COMPUTATIONS

ordb_dir = [BrainstromDB_folder, OriginalProtocolName];
newdb_dir = [BrainstromDB_folder, NewProtocolName];

% create new protocol
mkdir([BrainstromDB_folder, NewProtocolName]);

or_anat = [BrainstromDB_folder, OriginalProtocolName, '/anat/'];
or_data = [BrainstromDB_folder, OriginalProtocolName, '/data/'];

new_anat = [BrainstromDB_folder, NewProtocolName, '/anat/'];
new_data = [BrainstromDB_folder, NewProtocolName, '/data/'];

mkdir(new_anat);
mkdir(new_data);



%% ANAT:  copy (as it is). Chaning the * you should be able to restrict.
all_anat_dir = dir([ordb_dir, '/anat/*']);
all_anat_files = {all_anat_dir(3:end).name}; % the 3 excludes '.', and '..'

% select the files
include_anat_string =[include_anat_string, '|@default']; % add default
incl_File=regexpi(all_anat_files, include_anat_string); %

if (strcmpi(exclude_anat_string, '')) % case only select by inclusion
    selFiles_indices=find(~cellfun(@isempty, incl_File));
    
else % case in which there is both inclusion and exclusion
    
    excl_File=regexp(all_anat_files, exclude_anat_string);
    selFiles_indices=find(~cellfun(@isempty, incl_File) & cellfun(@isempty, excl_File));
    % select fineal file
end

% select here
all_anat_files=all_anat_files(selFiles_indices);


%%% ======= COPY ANAT HERE

for iAnat = 1:length(all_anat_files)
    copyfile([or_anat, all_anat_files{iAnat}], [new_anat, all_anat_files{iAnat}]);
end;

%% DATA PART


%loop with all relevant files
all_data_dir = dir([ordb_dir, '/data/*']);
all_data_files = {all_data_dir(3:end).name}; % the 3 excludes '.', and '..'

% select the Subjects
include_data_string = [include_data_string, '|@inter']; % add inter to avoid problems if present
incl_File=regexpi(all_data_files, include_data_string);
%
if (strcmpi(exclude_data_string, '')) % case only select by inclusion
    selFiles_indices=find(~cellfun(@isempty, incl_File));
else % case in which there is both inclusion and exclusion
    excl_File=regexp(all_data_files, exclude_data_string);
    selFiles_indices=find(~cellfun(@isempty, incl_File) & cellfun(@isempty, excl_File));
    % select fineal file
end

% select here
all_data_files=all_data_files(selFiles_indices);

%%% ======= COPY DATA HERE
for iSubj=1:length(all_data_files);
    
    %loop with all relevant files
    all_study_dir = dir([ordb_dir, '/data/', all_data_files{iSubj}, '/*']);
    all_study_files = {all_study_dir(3:end).name}; % the 3 excludes '.', and '..'
    
    % select the study
    include_study_string = [include_study_string, '|@intra|@default']; % add intra and default.
    incl_File=regexpi(all_study_files, include_study_string); %
    if (strcmpi(exclude_study_string, '')) % case only select by inclusion
        selFiles_indices=find(~cellfun(@isempty, incl_File));
    else % case in which there is both inclusion and exclusion
        excl_File=regexp(all_study_files, exclude_study_string);
        selFiles_indices=find(~cellfun(@isempty, incl_File) & cellfun(@isempty, excl_File));
        % select fineal file
    end
    
    all_study_files=all_study_files(selFiles_indices);
    
    
    for iStudy = 1:length(all_study_files)
        
        %loop with all relevant files
        all_files_dir = dir([ordb_dir, '/data/', all_data_files{iSubj}, '/', all_study_files{iStudy}]);
        all_files_files = {all_files_dir(3:end).name}; % the 3 excludes '.', and '..'
        
        
        new_study = [new_data, all_data_files{iSubj}, '/', all_study_files{iStudy} ];
        mkdir(new_study)
        
        
        % select the file
        include_file_string = [include_file_string, '|channel|brainstorm'];
        incl_File=regexpi(all_files_files, include_file_string); %
        if (strcmpi(exclude_file_string, '')) % case only select by inclusion
            selFiles_indices=find(~cellfun(@isempty, incl_File));
        else % case in which there is both inclusion and exclusion
            excl_File=regexp(all_study_files, exclude_file_string);
            selFiles_indices=find(~cellfun(@isempty, incl_File) & cellfun(@isempty, excl_File));
            % select fineal file
        end
        
        all_files_files=all_files_files(selFiles_indices);
        
        
        for iFile = 1:length(all_files_files)
            
            curr_file = all_files_files{iFile};
            copyfile([or_data, all_data_files{iSubj}, '/', all_study_files{iStudy}, '/', curr_file ], [new_data, all_data_files{iSubj}, '/', all_study_files{iStudy}, '/', curr_file ]);
        end;
        
        
    end;
    
    
    
    
    
end;
