%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREAZIONE DIRECTORY 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nome_nuova_cartella1='nuova Cartella'

%se aggiungi nuove cartella, ricordati di aggiungere anche una riga
%corrispondente dopo la riga 54.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




[FileNames,load_dir] = uigetfile({'*'},'Seleziona i files', 'Multiselect', 'on')

if ischar(FileNames);
   temp={};
   temp{1}=FileNames;
   FileNames=temp% se si specifica solo un file allora la classe sarˆ char e lo script non va.
   clear temp
end;
   

if FileNames{1}~=0

	answer = questdlg({'Lo script verrˆ eseguito su tutti' ;'i file selezionati '; 'VUOI CONTINUARE?'}, ...
                         'ATTENZIONE!!!', ...
                         'Continue', 'Cancel', 'Cancel');
                   

cd() %prima cambio con la nuova directory.

current_dir=dir();                    
        if strcmp(answer, 'Continue')


files=struct2cell(current_dir);
filenames=files(1,:);



[save_dir] = uigetdir(load_dir,'Seleziona la directory dove creerai le nuove cartelle');


%queste righe servono per far si che la separazione valga sia per mac che
%per PC!!!
separator='\';
if ~isempty(regexp(load_dir, '/'))
    separator='/';
end;

mkdir(strcat(save_dir,separator, nome_nuova_cartella1))
%mkdir(strcat(save_dir,separator, nome_nuova_cartella2))

if sum(sum(save_dir)==1)
 	errordlg('devi specificare una cartella in cui salvare i file!')
	break;
end;


        
for files=1:size(FileNames,2)
    name=char(FileNames(files))
    name=name(1:(size(name,2)-4));
    
    %% name=FileNames(files)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG = pop_loadset(strcat(name,'.set'), load_dir);


%% AGGIUNGI IL TUO CODICE QUI


EEG = pop_saveset( EEG,  'filename', strcat('A_', name,'.set'), 'filepath', strcat(save_dir,separator,nome_nuova_cartella1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;   
end;
end;