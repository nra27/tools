function [] = Camberline_Extract(camber_line_root_node)


grid_file = 'HPB.grid.1.adf'
flow_file = 'HPB.flow.adf'

[surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file)

% Find the blade nodes ready to plot
blade_nodes = surface_data.group(5).flow_node_numbers;
xyz = flow_data.coordinates;

% plot the blade tip only
plot3(xyz(blade_nodes(15000:end),1),xyz(blade_nodes(15000:end),2),xyz(blade_nodes(15000:end),3),'.r')
axis off
axis equal
hold on

% plot the camber line
n = blade_nodes(16537);
plot3(xyz(n,1),xyz(n,2),xyz(n,3),'.g')
plot3(xyz(n:n+48,1),xyz(n:n+48,2),xyz(n:n+48,3),'.k')

for i = 1:48, 
    n = blade_nodes(16537) + i*2401;
    plot3(xyz(n:n+48,1),xyz(n:n+48,2),xyz(n:n+48,3),'.k')
    hold on
    mat(i,1:49) = (n:n+48);
    camber_line.x(i,1:49) = xyz(n:n+48,1);
    camber_line.y(i,1:49) = xyz(n:n+48,2);
    camber_line.z(i,1:49) = xyz(n:n+48,3);
end

% 'density'    'u_velocity'    'v_velocity'    'w_velocity'    'pressure'    'spallart'    'heat_flux'

for i =1:48,
    for j = 1:49,
        camber_line.flow(i,j,:) = flow_data.flow(mat(i,j),:);
    end
end

figure
contourf(camber_line.x,camber_line.z,camber_line.flow(:,:,1),13)
axis off
axis equal





