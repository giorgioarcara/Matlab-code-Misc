
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

cd() %prima cambio con la nuova directory.

current_dir=dir();                    
        if strcmp(answer, 'Continue')


files=struct2cell(current_dir);
filenames=files(1,:);
if isempty(strmatch('mp_micromed_versionedefinitiva.ced', filenames))...
	|isempty(strmatch('filter_data.m', filenames))...
    |isempty(strmatch('filtro_notch_FIR.mat', filenames))...
    |isempty(strmatch('filtro_passa_alto_FIR.mat', filenames))
 	errordlg('mancano alcuni file fondamentali per far girare lo script!!')
    break;
end;



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


mkdir(strcat(save_dir,separator,'step1_Filter'))
mkdir(strcat(save_dir,separator,'step2_Epoch'))

if sum(sum(save_dir)==1)
 	errordlg('devi specificare una cartella in cui salvare i file!')
	break;
end;


        
for files=1:size(FileNames,2)
    name=char(FileNames(files))
    name=name(1:(size(name,2)-4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DA QUI COMINCIA LO SCRIPT VERO E PROPRIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% carico il file.
EEG = pop_loadset( 'filename', strcat(name,'.set'));
%effettuo il filtraggio
EEG=pop_chanedit(EEG, 'load',{'mp_micromed_versionedefinitiva.ced' 'filetype' 'autodetect'});
EEG = pop_eegfilt( EEG,[], 100, [100], []); %low-pass, ricontrolla
EEG = pop_resample(EEG, 256);
%per fare funzionare i filtri di seguito devi assicurarti che siano
%presenti NELLA DIRECTORY LOAD_DIR (quella da cui vengono caricati i file)
%tre file creati da Anahita: filtro_passa_alto_FI.mat, filtro_notch_FIR,
%filter_dat.mat. Se vuoi che i filtri vengano disegnati allora devi
%aggiungere come terzo argomento '1' nelle funzioni filter_data.
data_filtered=filter_data(EEG.data,'filtro_notch_FIR');
data_filtered=filter_data(data_filtered,'filtro_passa_alto_FIR');
EEG.data=data_filtered;
EEG.setname=strcat(name,'_filt','.set');
EEG = pop_saveset( EEG,  'filename', strcat(name,'_filt','.set'), 'filepath', strcat(save_dir,separator,'step1_Filter'));
% sembra che in questo passaggio non venga modificato il nome (setname)
% della struttura EEG. Nella GUI di eeglab, infatti, si vede sempre il
% "vecchio" nome.
% il file _filt.set ha anche subito un resampling.
% di seguito rinomino i marker: modificare questa parte coerentemente con i
% dataset!!!
EEG = pop_selectevent( EEG,  'value',1, 'renametype', 'U', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',2, 'renametype', 'D', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',11, 'renametype', 'corrU', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',12, 'renametype', 'corrD', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',21, 'renametype', 'errU', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',22, 'renametype', 'errD', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',31, 'renametype', 'mancaU', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',32, 'renametype', 'mancaD', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',44, 'renametype', 'stima', 'deleteevents', 'off');
EEG = pop_selectevent( EEG,  'value',55, 'renametype', 'monitor', 'deleteevents', 'off');
EEG = pop_epoch( EEG, {'U' 'D'}, [-3  3], 'newname',strcat(name,'_filt','_epoch', '.set') , 'epochinfo', 'yes');
EEG = pop_saveset( EEG,  'filename', strcat(name,'_filt','_epoch','.set'), 'filepath', strcat(save_dir,separator,'step2_Epoch'));
    end;
    % questa else è se si abortisce dopo la selezione della cartella su cui
    % vuoi fare il calcolo.
	else
   	 warndlg('OPERAZIONE CANCELLATA')
   	 end;
end;

