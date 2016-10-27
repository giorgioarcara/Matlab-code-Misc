function Coils_SCS = pol_2_voxels(MRI, Channels)
 
% mean HLI-N (mean of points for HLI-N, that is coil of the nasion)
% retrieve all measurement of HPI-N
HLIN_all = Channels.HeadPoints.Loc( : , strcmpi('HPI-N', ... 
Channels.HeadPoints.Label) );
% average
HLIN =  mean(HLIN_all, 2);
 

% retrieve all measurement of HPI-L that is coil of the 
%Left Preauricular Point, LPA)
HLIL_all = Channels.HeadPoints.Loc( : , strcmpi('HPI-L', ...
Channels.HeadPoints.Label) );

% mean HLI-L 
HLIL = mean(HLIL_all, 2);
 
% retrieve all measurement of HPI-R
HLIR_all = Channels.HeadPoints.Loc( : , strcmpi('HPI-R', ...
 Channels.HeadPoints.Label) );

% mean HLI-R
HLIR = mean(HLIR_all, 2);
 
% note the transposition. Hence, the columns are the x-y-z of each coil (as
% required by cs_convert)
Coils_SCS  = [HLIN, HLIL, HLIR]';
 
Coils_voxels= round ( cs_convert(MRI, 'SCS', 'voxel', Coils_SCS) );
% adjust reference according to CTF system coordinates, by subtracting 256 to the x 
% (discovered on CTF  software for dipole fitting after a trial-and-error procedure);
% the voxel numbers are simply inverted.
 
Coils_voxels(:, 2:3)= 256 - Coils_voxels(: ,2:3);
 
fprintf('Points converted from SCS coordinates to voxels:\n\n')
fprintf(['Nasion = ', num2str(Coils_voxels(1,:)), '\n'])
fprintf(['Left Ear = ', num2str(Coils_voxels(2,:)), '\n'])
fprintf(['Right Ear = ', num2str(Coils_voxels(3,:)), '\n'])