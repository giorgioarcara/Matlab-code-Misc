%% INITIALIZE GRAPH THEORY ANALYSIS SCRIPTS

script_name = mfilename('fullpath');
curr_script_folder = fileparts(script_name);


% open analysis and add path
addpath(genpath([curr_script_folder]));

fprintf('--- Gondola toolbox initialized ---\n');
fprintf('Require: BCT toolbox\n');


ascii_art=['                                              &                              \n', ...
'                                             *&&&&                             \n', ...
'                                      *    /&&&&&                              \n', ...
'                                     &&&&&&&&&&&&&                            \n', ...
'                                        *&&&&&&&&&&                            \n', ...
'                                          &&&&&&&&&                            \n', ...
'                                           .&&&&&&             *               \n', ...
'&&                                          &&&&&&&#          .&               \n', ...
'&&&                                         &&&&&& .&&( &      .&              \n', ...
'&&&(                                        #&&&&&    *&&#     &&,             \n', ...
' *&                                        &&&&&     ,&#&&(&&&&              \n', ...
'&.&&                                         &&&&&   &&&&&&&&&&&               \n', ...
'(&&&&&&                    ..*/(##&       ,/#&&&&&&&&&&&&&&&&&&&,            \n', ...
'  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&    .&&&          \n', ...
'  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&(         .&&&       \n', ...
'  ,&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&.               &&&&    \n', ...
'     .(&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#(.                         #&&&& \n'];


fprintf(ascii_art);