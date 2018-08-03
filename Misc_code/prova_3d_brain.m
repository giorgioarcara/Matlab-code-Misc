%% generate figure (depends on having https://github.com/edden-gerber/ecog_fmri_visualization_matlab in your MATLAB path)
load('demo_data');
brain_fig = plot_mesh_brain(brain_data.pial_right);
brain_data = get(gca, 'Children'); 

%% extract brain data from figure

% handle vertices
x_data = brain_data(2).Vertices(:,1);
y_data = brain_data(2).Vertices(:,2);
z_data = brain_data(2).Vertices(:,3);

% specify how vertices connect to form the faces
i_data = brain_data(2).Faces(:,1)-1; 
j_data = brain_data(2).Faces(:,2)-1;
k_data = brain_data(2).Faces(:,3)-1;

%% construct plotly figure
brain_plotly_fig = plotlyfig('visible', 'off', 'strip', false, 'world_readable', true); 
brain_plotly_data.x = x_data;
brain_plotly_data.y = y_data;
brain_plotly_data.z = z_data;
brain_plotly_data.i = i_data;
brain_plotly_data.j = j_data;
brain_plotly_data.k = k_data;
brain_plotly_data.type = 'mesh3d'; 
brain_plotly_data.intensity = x_data;
brain_plotly_data.colorscale = 'Electric';

%% add a second trace for 3D scatter points
points_of_interest = [100, 1000, 10000]; 
scatter_plotly_data.x = x_data(points_of_interest); 
scatter_plotly_data.y = y_data(points_of_interest); 
scatter_plotly_data.z = z_data(points_of_interest);
scatter_plotly_data.marker.size=20;
scatter_plotly_data.marker.color='yellow'; 
scatter_plotly_data.marker.opacity='0.4';
scatter_plotly_data.mode = 'markers';
scatter_plotly_data.type= 'scatter3d'; 

% add data
brain_plotly_fig.data = {brain_plotly_data, scatter_plotly_data};

%% adjust the layout
brain_plotly_fig.layout.scene.xaxis.dtick = 30; 
brain_plotly_fig.layout.scene.yaxis.dtick = 30; 
brain_plotly_fig.layout.scene.zaxis.dtick = 30; 

%% send to plotly (may take ~5 mins depending on network)
brain_plotly_fig.plotly; 