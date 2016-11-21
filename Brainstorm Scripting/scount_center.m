% esporta la corteccia su matlab come mycortex (la corteccia da "anat").

% un Atlas ? composto da vari campi.
% parto dall'atlas di cui voglio calcolare il centro.
% Lo duplico e al nome aggiungo - center.
% Quindi sostituisco ai campi "Vertices" il centro solo

% devo ciclare per tutte le scout dell'Atlas
%

% IMPORTANTE: se vuoi usarlo per la TF devi avere creato l'head model
% con l'atlas esistente. Altrimenti dal menu a tendina non ti comparir? il
% nuovo atlas.


original_atlas=2

n_atlases=length(mycortex.Atlas);
% duplicate the Atlas add as last atlas
mycortex.Atlas(n_atlases+1)=mycortex.Atlas(original_atlas);
mycortex.Atlas(n_atlases+1).Name=[mycortex.Atlas(n_atlases+1).Name ' - centroid'];



for s=1:length(mycortex.Atlas(original_atlas).Scouts);

    myscout_info=mycortex.Atlas(original_atlas).Scouts(s);
    myscout=myscout_info.Vertices;
    mysurface=mycortex.Vertices;

    plot3(mysurface(:,1), mysurface(:,2), mysurface(:,3), '.');
    hold on
    plot3(mysurface(myscout,1), mysurface(myscout,2), mysurface(myscout,3), 'o')

    % DA QUI DEVI TROVARE UN MODO PER OPERAZIONALIZZARE IL PUNTO "CENTRALE DI
    % UNA SUPERFICIE".

    % https://en.wikipedia.org/wiki/Centroid
    scout_3d=[mysurface(myscout,1), mysurface(myscout,2), mysurface(myscout,3)]; % define scout in 3d
    centroid=mean(scout_3d, 1);  % calculate centroid

    % calculate distance from centroid of each point in scouts.
    Eucl_dist_from_centroid=size(myscout,1);
    for (i=1:size(scout_3d,1));
        Eucl_dist_from_centroid(i)= sqrt((scout_3d(i,1)- centroid(:,1))^2 + (scout_3d(i,2)-centroid(:,2))^2 + (scout_3d(i,3)-centroid(:,3))^2);
    end;

    [val  ind]=min(Eucl_dist_from_centroid);

    scout_center=myscout(ind);

    plot3(mysurface(scout_center,1), mysurface(scout_center,2), mysurface(scout_center ,3), '*', 'markersize', 60)
    hold off
    
    mycortex.Atlas(n_atlases+1).Scouts(s).Vertices = scout_center ;

end;

new_atlas = mycortex.Atlas(n_atlases+1);

% FINITO QUESTO CLICCA SUL SOGGETTO (scheda anat) e re-importa la
% corteccia. % quindi mettila come default. In alternaativa potresti
% esportare solo la scout, ma pare dovresti farlo una scout alla volta.
% ho fatto qualche prova sulle GUI.

