%% write_pos(new_Pos, filename)
% function to write to file a Pos object. As imported with import_pos 
% and/or modified with update_pos.

function write_pos(new_Pos, filename)

n_of_points=length(new_Pos.points);

fid=fopen(filename, 'w');
fprintf(fid, '%s', num2str(n_of_points));
fprintf(fid, '\n', '');
for i=1:n_of_points
    fprintf(fid, '%s ', new_Pos.points{i});
    fprintf(fid, '%d ', new_Pos.coord(i,:));
    fprintf(fid, '\n', '');
end;

fclose(fid);

