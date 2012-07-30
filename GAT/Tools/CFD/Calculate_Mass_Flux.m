function mass_flux = Calculate_Mass_Flux(surface_data,grid_data,surface);
%
% mass_flux = Calculate_Mass_Flux(surface_data,grid_data,surface)
%
% A function to calculate the mass flux crossing the output
% plane of as computational domain.  Give the name of the outlet
% surface.

% Set group
for i = 1:length(surface_data.surface_groups)
    if strcmp(surface_data.surface_groups{i},surface)
        group = i;
    end
end

rho = grid_data.flow(surface_data.group(group).flow_node_numbers,1);
u = grid_data.flow(surface_data.group(group).flow_node_numbers,2);
area = surface_data.group(group).node_areas;

mass_flux = sum(rho.*u.*area);