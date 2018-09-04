% GTmerge(GTstruct1, GTstruct2)
%
% This function merge two GTres struct. It assumes that the structs have
% the same number of elements that refers to the same observations.
% The fields of the second struct will be added to the first
%
%
% INPUT
% - GTstruct1: the first GT struct to be merged
% - GTstruct2: the second GT struct to be merged
%
%
%
% Author: Giorgio Arcara
%
% version: 18/08/2018
%
%

function GTstruct = GTmerge(GTstruct1, GTstruct2);

if nargin < 2
    error('2 inputs are mandatory')
end

if (length(GTstruct1) ~= length(GTstruct2))
    error('The two structs must have the same dimension');
end;

FieldNames = fieldnames(GTstruct2);

% initialize output
GTstruct=GTstruct1;

for iField = 1:length(FieldNames)
    
    GTstruct.(FieldNames{iField}) = GTstruct2.(FieldNames{iField});
    
end



