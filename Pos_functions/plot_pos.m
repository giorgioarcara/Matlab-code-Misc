%% plot_pos(Pos)
% function to plot a .pos file as imported by the import_pos function
% After opening the plot select the points with alt + click. 
% Then right click -> export cursor data to workspace.
% cursor (default = 0), don't report any info in the data tip.
% if set to 1, a tip with x, y,z and index is reported

% Author: Giorgio Arcara
% data: 21/10/2016

function plot_pos(Pos, cursor)
%fh=figure;
if nargin < 2
    cursor = 0;
end;
h=plot3(Pos.coord(:,1), Pos.coord(:,2), Pos.coord(:,3), 'o');
set(h,'MarkerEdgeColor','none','MarkerFaceColor','b')
dcm=datacursormode;
datacursormode on
if cursor
    set(dcm, 'updatefcn', @myFunction);
else
    set(dcm, 'updatefcn', @myFunction2);
end;

end
%% plot_pos(Pos)
% function to plot a .pos file as imported by the import_pos function
% After opening the plot select the points with alt + click. 
% Then right click -> export cursor data to workspace.

% Author: Giorgio Arcara

function plot_pos(Pos)
%fh=figure;
h=plot3(Pos.coord(:,1), Pos.coord(:,2), Pos.coord(:,3), 'o');
set(h,'MarkerEdgeColor','none','MarkerFaceColor','b')
dcm=datacursormode;
datacursormode on
set(dcm, 'updatefcn', @myFunction);
end

% create a personalized datatip function
function output_txt = myFunction(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

% Import x and y
x = get(get(event_obj,'Target'),'XData');
y = get(get(event_obj,'Target'),'YData');

% Find index
index_x = find(x == pos(1));
index_y = find(y == pos(2));
index = intersect(index_x,index_y);

% Set output text
output_txt = {['X: ',num2str(pos(1),4)], ...
              ['Y: ',num2str(pos(2),4)], ...
              ['Z: ',num2str(pos(3),4)], ...
              ['Index: ', num2str(index)]};
end

function output_txt = myFunction2(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% Set output text
output_txt = {['']};
end
