% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end

%% SET PROTOCOL
ProtocolName = 'MEGHEM_analisi_3';


% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')



%% SUBJECT LOOP
for iSubj=2:length(my_subjects.Subject);

    %% GET SUBJECT SURFACE

    % look for the surface named 'tess_cortex_pial_low.mat'
    % in the following code I 1) make a regexpi, 2) apply a cellfun with
    % logical query for non empty cells, 3) use find to retrieve the indices.
    iSurface=find(~cellfun(@isempty, regexpi({my_subjects.Subject(iSubj).Surface.FileName}, 'tess_cortex_pial_low.mat')));

    or_cortex= load([ProtocolInfo.SUBJECTS, '/', my_subjects.Subject(iSubj).Surface(iSurface).FileName]);

    mycortex=or_cortex;
    %% SCOUT CENTER
    % IMPORTANTE: se vuoi usarlo per la TF devi avere creato l'head model
    % con l'atlas esistente. Altrimenti dal menu a tendina non ti comparir? il
    % nuovo atlas.


    original_atlas=find(~cellfun(@isempty, regexpi({mycortex.Atlas.Name}, 'Destrieux')));

    n_atlases=length(mycortex.Atlas);
    % duplicate the Atlas add as last atlas
    mycortex.Atlas(n_atlases+1)=mycortex.Atlas(original_atlas);
    mycortex.Atlas(n_atlases+1).Name=[mycortex.Atlas(n_atlases+1).Name ' - centroid'];



    for s=1:length(mycortex.Atlas(original_atlas).Scouts);

        myscout_info=mycortex.Atlas(original_atlas).Scouts(s);
        myscout=myscout_info.Vertices;
        mysurface=mycortex.Vertices;

        % DISABLED - Plot with all scouts
        %plot3(mysurface(:,1), mysurface(:,2), mysurface(:,3), '.');
        %hold on
        %plot3(mysurface(myscout,1), mysurface(myscout,2), mysurface(myscout,3), 'o')

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

        % DISABLED plot with check with a scout
        %plot3(mysurface(scout_center,1), mysurface(scout_center,2), mysurface(scout_center ,3), '*', 'markersize', 60)
        %hold off

        mycortex.Atlas(n_atlases+1).Scouts(s).Vertices = scout_center ;

    end;

    %new_atlas = mycortex.Atlas(n_atlases+1);

    % WARNING - OVERWRITE existing atlas.
    save([ProtocolInfo.SUBJECTS, '/', my_subjects.Subject(iSubj).Surface(iSurface).FileName], '-struct', 'mycortex');

end;
