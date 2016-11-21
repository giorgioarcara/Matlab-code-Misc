% il re-reference va fatto dopo l'artifact rejection.
% altrimenti vengono aggiunte a tutti gli elettrodi le distorsioni che ci sono 
% in A2. E' lo stesso discorso che vale per la baseline correction.
% MANCANO I FILE PER L'EPOCAGGIO!!!!
% - filtro su continuo (per evitare problemi distorsioni filtro su epocato)
% - epocaggio
% - ICA 
% - re-reference (se ci sono artefatti su A2 si ripercuotono su tutti gli elettrodi)
% - baseline correction (Se ci sono artefatti oculari possono influenzare la bre baseline
% - Artifact rejection, etc.

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
if ~isempty(regexp(load_dir, '/'))
    separator='/';
end;

mkdir(strcat(save_dir,separator,'step7_Final_no4455'))


if sum(sum(save_dir)==1)
 	errordlg('devi specificare una cartella in cui salvare i file!')
	break;
end;



        
for files=1:size(FileNames,2)
    name=char(FileNames(files))
    name=name(1:(size(name,2)-4));
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DA QUI COMINCIA LO SCRIPT VERO E PROPRIO%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% carico il file.
EEG = pop_loadset( 'filename', strcat(name,'.set'));
EEG = pop_selectevent( EEG, 'type',{'monitor', 'stima'},'deleteevents','off','deleteepochs','on','invertepochs','on');
%nota che essendo la selezione prima del riepocaggio, si tolgono i trial
%con monitor e stima entro un bel po' dal trial
EEG = pop_epoch( EEG, {  'D'  'U'  }, [-0.21 1.2], 'epochinfo', 'yes');
EEG = pop_selectevent( EEG, 'type',{'errU', 'errD'},'deleteevents','off','deleteepochs','on','invertepochs','on');
EEG = linked(EEG, 30, 32);
EEG.icawinv=EEG.icawinv([1:29 30 31],:);
EEG.icasphere=EEG.icasphere([1:29 30 31],[1:29 30 31]);
EEG.icaweights=EEG.icaweights(:,[1:29 30 31]);
EEG.icachansind=EEG.icachansind(:,[1:29 30 31]);
EEG = pop_rmbase( EEG, [-200  0]);
EEG = pop_eegthresh(EEG,1,[1:31] ,-100,100,-0.2,1.2,0,1);
%EEG = pop_autorej(EEG, 'nogui','on','threshold',100,'eegplot','off');
%restringo la finestra delle epoche già selezionate per preparare.
%rimuovo le epoche con valori oltre una threshold.
EEG = pop_saveset( EEG,  'filename', strcat(name,'_riepoch_corr_re-ref_bc.set'), 'filepath', strcat(save_dir,separator,'step7_Final_no4455'));
%importante!!!! qui devi eventualmente cambiare i nomi del nuovo mastoide
%(secondo argomento) e degli elettrodi su cui non fare il re-ref (terzo
%argomento).
    end;
    % questa else è se si abortisce dopo la selezione della cartella su cui
    % vuoi fare il calcolo.
	else
   	 warndlg('OPERAZIONE CANCELLATA')
   	 end;
end;
