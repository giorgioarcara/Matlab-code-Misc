
% set protocol "tDCS_MEG_Neural_Plasticity"

OverlayFile = 'NewSubject01_A/TDCSS011_ISRASSR_20170301_02_resample/results_concat_170403_1640.mat'



SurfaceFile = '@default_subject/tess_cortex_pial_low.mat'


[hFig iDS iFig] = view_surface_data(SurfaceFile, OverlayFile, 'MEG')


hFig.Position % edit the size of the figure

hFig.Position = [500 500 500 200] % edit the size of the figure (not clear how)


% use figure_3d_g, looking for modifications in the code searching for
% lines with "GIORGIO" written in them.
% 'personal' is a view specified (currently by hard-coding) in figure_3d_g


figure_3d_g('SetStandardView', hFig, 'Personal')


% get rid of colorbar

hColorbar = findobj(hFig, '-depth', 1, 'Tag', 'Colorbar'); 
delete(hColorbar)




