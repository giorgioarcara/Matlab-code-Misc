% step 1) recupera il numero del trial
% step 2) considera gli indici rispetto al numero del trial
% step 3) crea selezione di bin


Trial_names = {'ciaociao_108).mat', 'miaomiao_109).mat', 'baubau_1).mat', 'rachelina_4).mat', 'giorgillo_20).mat'};



%% STEP1

% trova inizio e fine della stringa di interesse
% \d+ indica un numero di qualsiasi cifre. ).mat indica che la stringa di
% interesse deve finire per ).mat

[StartInd EndInd] = regexp(Trial_names, '\d+).mat');

% inizializzo oggeto con trials
Trials = zeros(1, length(Trial_names));
for iTrial = 1:length(Trials);
    temp = Trial_names{iTrial}(StartInd{iTrial}:EndInd{iTrial}); % recupero il nome
    temp2 = regexprep(temp, ').mat', ''); % tolgo la parte che non mi interessa
    Trials(iTrial) = str2num(temp2);   % trasformo in numero
end;

%% STEP 2
[~, Trials_ind] = sort(Trials);
% Trials ind ? adesso (in ordine) il numero dei trial


%% STEP 3
bin_size = 2; % qui andr? messo 40
bin_starts = 1:bin_size:length(Trial_names); % determino i trial iniziali dei bin

% determino numero di bins
my_bins_n = ceil(length(Trial_names)/bin_size);
Trials_binned = cell(1, my_bins_n);
for iBin = 1:my_bins_n
    
    % evita eccezione con end.
    if (bin_start(iBin)+(bin_size -1)) <= length(Trial_names)
        curr_trials_indices = Trials_ind( bin_start(iBin): (bin_start(iBin)+(bin_size -1))); % aumenta in base al bin size
                Trials_binned{iBin} = Trial_names(curr_trials_indices);
    else
        curr_trials_indices = Trials_ind( bin_start(iBin): end); % se siamo fuori vai semplicemente fino alla fine
        Trials_binned{iBin} = Trial_names(curr_trials_indices);
    end;
end
    

% da adesso cicla per i trials binned con i soliti codici
    
    
    
    
    
    % step 4) manda script vecchi su selezione