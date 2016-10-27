%% plot_pos(Pos)
% function to plot a .pos file as imported by the import_pos function
% After opening the plot select the points with alt + click. 
% Then right click -> export cursor data to workspace.

% Author: Giorgio Arcara

function plot_pos_2(Pos)
%fh=figure;
h=plot3(Pos.coord(:,1), Pos.coord(:,2), Pos.coord(:,3), 'o');
set(h,'MarkerEdgeColor','none','MarkerFaceColor','b')
dcm=datacursormode;
datacursormode on
set(dcm, 'updatefcn', @myFunction);
end

% create a personalized datatip function
function output_txt = NaN
% ~            Currently not used (empty)
% event_obj    Object containing event data structure
% output_txt   Data cursor text
end