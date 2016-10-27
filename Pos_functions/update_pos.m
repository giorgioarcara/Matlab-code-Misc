%% new_Pos = update_pos(Pos, cursor_info)
%
% function create an updated Pos object, with some points excluded. The points 
% are interactively selected with the plot_pos function before).
%
%- Pos: the original Pos file with the points to be deleted
% - cursor_info: the object obtained after using he plot_pos function.
% Containing the points to be removed
% - a string with the output file name (.pos), that will be exported in the
% current directory.
%
% 

function new_Pos = update_pos(Pos, cursor_info)

% get indices from cursor_info
to_exclude_ind = [cursor_info.DataIndex];

new_Pos.points = Pos.points( setdiff(1:length(Pos.points) , to_exclude_ind) );
new_Pos.coord = Pos.coord( (setdiff(1:size(Pos.coord,1) , to_exclude_ind) ), : );









