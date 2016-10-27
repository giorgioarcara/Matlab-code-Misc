%% Pos = import_pos(filename)
% function to import a .pos file. As obtained by Polhemous.
%
% Author: Giorgio Arcara
%

function Pos = import_pos(filename)

% step 1
% determine number of lines

myfid=fopen(filename);

% fgetl get each line one at time
% the first line of the .pos contains the number of subsequent lines
% with the first call to fgetl, I get the total number of lines.

tline=fgetl(myfid);

num_of_lines=str2num(tline);

%initialize an empty matrix
Pos.points=cell(num_of_lines,1);
Pos.coord=zeros(num_of_lines, 3);

k=1;
tline=fgetl(myfid);
while ischar(tline)
    curr_line=strsplit(tline);
    Pos.points(k)=curr_line(1);
    Pos.coord(k, 1)=str2num(curr_line{2});
    Pos.coord(k, 2)=str2num(curr_line{3});
    Pos.coord(k, 3)=str2num(curr_line{4});
    k=k+1;
    tline=fgetl(myfid); % note that I create tline here (at the end) to
    % make the while cycle work properly (otherwise at the last cycle it
    % will not work
end;






