% GTcontvar(GTrescell, resfield)
%
% This function takes as input a GTrescell object (cell containing GTres object) and compute the average of the
% matrices separately for cell (you can select subsample).
%
% INPUT
% - GTres: the GTres struct with the results
% - resfield: the name of the field that will be takein into account
%
% NOTE: the function some all the values and then divide by the numebrs
%       so missing values can lead to wrong resuls 
%
%
% Author: Giorgio Arcara
%
% version: 12/01/2018
%


function GTthresh_res = GTcontvar(GTres, resfield, contvarfield, contvarvalues);

% transform cont_var to string (for usage of other function)

GTthresh_res = struct();
GTthresh_res.(threshfield) = contvarvalues;
GTthresh_res.(resfield) = [];

for iThresh = 1:length(contvarvalues);
        
    GTres_sel = GTsel(GTres, threshfield, num2str(cont_var(iThresh)), 1);
    
    try
    GTres_sel_ave = GTaverage(GTres_sel, {resfield});
    
    GTthresh_res.(resfield) = [GTthresh_res.(resfield); GTres_sel_ave.(resfield)]; % update incrementally
    catch
        
    end;
        
end;
     
end



