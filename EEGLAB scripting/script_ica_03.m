%%% SCRIPT ICA 
% il re-reference va fatto dopo l'artifact rejection.
% altrimenti vengono aggiunte a tutti gli elettrodi le distorsioni che ci sono 
% in A2. E' lo stesso discorso che vale per la baseline correction.

% - filtro su continuo (per evitare problemi distorsioni filtro su epocato)
% passa basso a 100 Hz (FIR ordine: 100)
% ri-campionamento 256 Hz
% filtro passa alto e filtro notch (in successione: 49-51)
% - epocaggio
% - ICA & artifact rejection (PAUSA)
% - re-reference (se ci sono artefatti su A2 si ripercuotono su tutti gli elettrodi)
% - baseline correction (Se ci sono artefatti oculari possono influenzare la pre baseline
% - seleziona epoche corrette.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SELEZIONE DIRECTORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in questa parte viene selezionata la directory
% e viene chiesta conferma ricordando che il ciclo verrà eseguito su tutti
% i files.

[FileNames,load_dir] = uigetfile({'*.set'},'Seleziona i files', 'Multiselect', 'on')

if ischar(FileNames);
   temp={};
   temp{1}=FileNames;
   FileNames=temp% se si specifica solo un file allora la classe sarà char e lo script non va.
   clear temp
end;
   

if FileNames{1}~=0

	answer = questdlg({'Lo script verrà eseguito su tutti' ;'i file selezionati '; 'VUOI CONTINUARE?'}, ...
                         'ATTENZIONE!!!', ...
                         'Continue', 'Cancel', 'Cancel');

cd(load_dir) %prima cambio con la nuova directory.

current_dir=dir();                    
        if strcmp(answer, 'Continue')




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%strcat() verrà usato per combinare nomi di stringhe e dalla variabile
%name creare eventualemtne nuovi dataset intermedi
%mkdir('prova') verrà usato per creare nuove cartella (per soggetto??)




[save_dir] = uigetdir(load_dir,'Seleziona la directory dove creerai le nuove cartelle');

%queste righe servono per far si che la separazione valga sia per mac che
%per PC!!!
separator='\';
if ~isempty(regexp(load_dir, '/'));
    separator='/'
end;

%%%% ATTENZIONE: la specificazione della directory va corretta se lo script
%%%% gira su Mac. In quel caso devi sostituire \ con /.
mkdir(strcat(save_dir,separator,'step3_ICA'))


if sum(sum(save_dir)==1)
 	errordlg('devi specificare una cartella in cui salvare i file!')
	break;
end;

        
for files=1:size(FileNames,2)
    name=char(FileNames(files))
    name=name(1:(size(name,2)-4));

EEG = pop_loadset( 'filename', strcat(name,'.set'));
EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
EEG.setname=strcat(name,'_ICA','.set');
EEG = pop_saveset( EEG,  'filename', strcat(name,'_ICA', '.set'), 'filepath', strcat(save_dir,separator,'step3_ICA'));
  
        end;
    % questa else è se si abortisce dopo la selezione della cartella su cui
    % vuoi fare il calcolo.
	else
   	 warndlg('OPERAZIONE CANCELLATA')
   	 end;
end;

