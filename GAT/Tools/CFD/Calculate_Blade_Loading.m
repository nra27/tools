function [Fx,Fr,T] = Calculate_Blade_Loading(surface_data,grid_data,surfaces);
%
% [Fx,Fr,T] = Calculate_Blade_Loading(surface_data,grid_data,surfaces)
%
% A function to calculate the blade loading.  Returning
% Fx - the axial force
% Fr - the radial force
% T - the torque
% Surfaces must be a cell array!

% Check to see if coordinates changed to r-theta
[M,N] = size(grid_data.coordinates);
if N == 3
    grid_data = Set_to_RTheta(grid_data);
end

r = grid_data.coordinates(:,4);
theta = grid_data.coordinates(:,5);

% Find the surfaces
for i = 1:length(surfaces)
	for j = 1:length(surface_data.surface_groups)
 	   	if strcmp(surface_data.surface_groups{j},surfaces(i))
  	      group(i) = j;
		end
	end
	
	P = grid_data.flow(surface_data.group(group(i)).flow_node_numbers,5);
	r = grid_data.coordinates(surface_data.group(group(i)).flow_node_numbers,4);
	theta = grid_data.coordinates(surface_data.group(group(i)).flow_node_numbers,5);
	A = surface_data.group(group(i)).node_areas;
	n = surface_data.group(group(i)).node_normals;
	
	Fx_temp = P.*A.*n(:,1);
	Fy_temp = P.*A.*n(:,2);
	Fz_temp = P.*A.*n(:,3);
	
	Fr_temp = Fy_temp.*cos(theta)+Fz_temp.*sin(theta);
	T_temp = r.*(Fz_temp.*cos(theta)-Fy_temp.*sin(theta));
	
	Fx(i) = sum(Fx_temp);
	Fr(i) = sum(Fy_temp);
	T(i) = sum(T_temp);
end