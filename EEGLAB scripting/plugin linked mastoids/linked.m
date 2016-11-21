function [EEG] = linked(EEG, new_mast, gchans) 
eyemat = eye(size(EEG.data,1));
eyemat(:,new_mast)=-0.5;
eyemat(new_mast,new_mast)=0;
if ~isempty(gchans)
	eyemat(gchans,new_mast)=0;
end;
EEGresh=reshape(EEG.data, size(EEG.data,1), (size(EEG.data,2)*size(EEG.data,3)));
EEGtemp=eyemat*EEGresh;
EEGreresh=reshape(EEGresh,size(EEG.data,1), size(EEG.data,2), size(EEG.data,3));
% le righe seguenti servono per rimuovere A2 perchè non ha più senso
EEG.data=EEGreresh;
EEG.data=EEGtemp([[1:1:new_mast-1] [new_mast+1:1:EEG.nbchan]],:);
EEG.nbchan = EEG.nbchan-1; 
%dico che c'è un canale in meno
EEG.chanlocs=EEG.chanlocs([[1:1:new_mast-1] [new_mast+1:1:end]]);