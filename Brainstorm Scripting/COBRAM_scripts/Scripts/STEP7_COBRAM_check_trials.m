

% define subject names from first n letters of file name

n = 5


% get row names
Rnames = EventsTable.Properties.RowNames;

% initialize empty cell
Subject_names = cell(1, size(Rnames, 1));

for iRowNames=1:size(Rnames, 1)
    Subject_names{iRowNames} = Rnames{iRowNames}(1:n);
end

Subject_names = unique(Subject_names);

SummaryEventsMat = zeros(length(Subject_names), size(EventsTable,2));

for iSubj=1:length(Subject_names);
    Subj_indices = find(~cellfun(@isempty, regexpi(Rnames, Subject_names{iSubj})));
    curr_subj = table2array( EventsTable(Subj_indices , :));
    SummaryEventsMat(iSubj,:) = sum(curr_subj); % calculate sum
end

SummaryEventsTable = array2table(SummaryEventsMat);
SummaryEventsTable.Properties.RowNames = Subject_names;
SummaryEventsTable.Properties.VariableNames = EventsTable.Properties.VariableNames;