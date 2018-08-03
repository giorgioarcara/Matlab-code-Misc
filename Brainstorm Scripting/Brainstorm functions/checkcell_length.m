%% checkcell_length(cell, lengths)
% This functions make a check on the number of elements of a cell.
% In particular it checks if the cell has some specified length,
% recursively.
% The 'levels' argument can be used with a matrix, specifying the expected
% number of element (i.e., length) for each level.
% For example if lengths = [15, 2], the function check if 'cell' is
% composed by 15 elements, and if each of this elements include 2
% elemeents.
%
% Author: Giorgio Arcara
%
% Version: 12/11/2016

function [message] = checkcell_length(myCell, levels)

stop = false
iLevel = 2
k = 1
TopLevel = myCell;

while stop == false
    
    curr_data = TopLevel{k}
    
    while iLevel<length(levels)
        
        while iObj < length(curr_data)
                 
            length_check = length(curr_data)==levels(iLevel);
            
            if ~length_check
                error('problem')
            end;
            
            
        end;
        
    end
    
end;

end





