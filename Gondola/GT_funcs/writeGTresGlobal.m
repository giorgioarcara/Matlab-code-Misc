%% writeGTresGlobal(GTres, resfields, labfields, outdir)
%
% This function take as input several a GTres struct (as obtained by a
% BCT_analysis.m script) and export the results of a Global variable 
% (i.e., one value per each GTres instance) in a friendly format for statistical analysis
% Data are exported in long format.
%
% INPUT:
% - GTres: a GTres object (a struct with results of GT analysis).
% - resfields: a cell with the names of the fields that should be exported
% - NodeLabels: a cell with the NodeLabels, in the same order of resfields
% data
% - labfields: other fields to be added (typically subject name labels).
%
% Author: Giorgio Arcara
%
% version: 12/1/2018


function writeGTresGlobal(GTres, resfields, labfields, outdir)

%% resfields (numeric results to be exported, one per Subejct).

res_names = fields(GTres);

res_cell=squeeze(struct2cell(GTres));

% find indices corresponding to name
[~, ind, ~] = intersect(res_names, resfields);

restemp = res_cell(ind, :);

res = cell2mat(restemp);
res = res';

%% labfields (numeric results to be exported, one per Subject).

% find indices corresponding to name
[~, ind, ~] = intersect(res_names, labfields);

lab = res_cell(ind, :);

lab = lab';

export_lab = lab;

%% EXPORT FILE FOR NBS
export_file=[outdir 'GT_Globalresults.txt'];

fid = fopen(export_file, 'w');

fprintf(fid, '%s ', resfields{:});
fprintf(fid, '%s ', labfields{:});
fprintf(fid, '\n', '');

for i=1:size(res,1);%
    fprintf(fid, '%d ', res(i,:)); % print only Coordinates
    fprintf(fid, '%s ', export_lab{i, :});
    fprintf(fid, '\n', '');
end;
fclose(fid);



        
