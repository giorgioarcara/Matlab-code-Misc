% launch brainstorm, with no gui (but only if is not already running)
if ~brainstorm('status')
    brainstorm %nogui
end

%% SET PROTOCOL
ProtocolName = 'SISSA';


% get the protocol index, knowing the name
iProtocol = bst_get('Protocol', ProtocolName);

% set the current protocol
gui_brainstorm('SetCurrentProtocol', iProtocol);

% check info
ProtocolInfo=bst_get('ProtocolInfo')

% get the subject list
my_subjects = bst_get('ProtocolSubjects')



%% SUBJECT LOOP

%% GET SUBJECT SURFACE

iSubj=1
% look for the surface named 'tess_cortex_pial_low.mat'
% in the following code I 1) make a regexpi, 2) apply a cellfun with
% logical query for non empty cells, 3) use find to retrieve the indices.

% TO LOAD INDIVIDUAL CORTEX (DOES NOT WORK IF DEFAULT IS SET)
%iSurface=find(~cellfun(@isempty, regexpi({my_subjects.Subject(iSubj).Surface.FileName}, 'tess_cortex_pial_low.mat')));
%or_cortex= load([ProtocolInfo.SUBJECTS, '/', my_subjects.Subject(iSubj).Surface(iSurface).FileName]);

% LOAD DEFAULT CORTEX
or_cortex = load([ProtocolInfo.SUBJECTS, '/', '@default_subject/tess_cortex_pial_low.mat']);
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

%% GET THE NEW GENERATED ATLAS and store in a centroids x 3 (x,y,z) mat
% be sure you selected the correct Atlas
newAtlas = mycortex.Atlas(n_atlases+1);
nScouts = length(newAtlas.Scouts);

Coord = zeros(nScouts, 3);

for iScout=1:nScouts
    Coord(iScout,:) = mycortex.Vertices(newAtlas.Scouts(iScout).Vertices, :);
end;
 
% plot all Coord
%plot3(Coord(:,1), Coord(:,2), Coord(: ,3), '*', 'markersize', 1)

%% check
n = 50
% check label
newAtlas.Scouts(50).Label

figure
% plot all brain
plot3(mysurface(:,1), mysurface(:,2), mysurface(:,3), '.');
hold on
% plot scout
plot3(Coord(n,1), Coord(n,2), Coord(n ,3), '*', 'markersize', 50)
hold off



%% LOAD MRI TO CONVERT

% I EXPORTED MANUALLY MRI FROM BRAINSTORM
CoordMNI = cs_convert(MRI, 'scs', 'mni', Coord);

%% SAVE (Some hard-coding here)
cd('/Users/giorgioarcara/Documents/Statistica e Metodologia New/Graph Theory')

save('Coord.mat', 'Coord', 'CoordMNI', 'newAtlas');




