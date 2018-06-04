a = [11, 12; 21, 22]
triu(a)
a(triu(a)>0)


DataMat = plv;

AllNamesCell = allcomb(DataMat.RefRowNames, DataMat.RowNames)
%AllNamesCell = reshape(RowCell, length(DataMat.RefRowNames), length(DataMat.RowNames))

indices_mat = ones(length(DataMat.RefRowNames), length(DataMat.RowNames));
indices_sel = tril(indices_mat); % remove duplicate by getting only lower diag matrix
indices = logical( indices_sel(:) );

% get relevant names
RelNames =  AllNamesCell(indices,:);

NewNames=cell(size(RelNames,1), 1);
% Combine with name as in bst.
for iname = 1:size(RelNames, 1)
    % note! that i paste the names in reverse order, to match the results
    % with those from bst plots
    NewNames{iname}=[RelNames{iname, 2}, '_x_', RelNames{iname, 1}];
end;

R = bst_memory('GetConnectMatrix', DataMat);

