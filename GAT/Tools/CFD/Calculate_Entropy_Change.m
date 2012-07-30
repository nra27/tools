function [delta_s,delta_m] = Calculate_Entropy_Change(surface_data,grid_data);

% mass weighted inlet entropy
s1 = grid_data.flow(surface_data.group(4).flow_node_numbers,7);
rho1= grid_data.flow(surface_data.group(4).flow_node_numbers,1);
u1= grid_data.flow(surface_data.group(4).flow_node_numbers,2);
area1 = surface_data.group(4).node_areas;
mass_flow_in = sum(rho1.*u1.*area1);

mw_s1 = 1/mass_flow_in*sum(rho1.*u1.*area1.*s1);


% mass weighted outlet entropy
s2= grid_data.flow(surface_data.group(3).flow_node_numbers,7);
rho2= grid_data.flow(surface_data.group(3).flow_node_numbers,1);
u2 = grid_data.flow(surface_data.group(3).flow_node_numbers,2);
area2 = surface_data.group(3).node_areas;
mass_flow_out = sum(rho2.*u2.*area2);

mw_s2 = 1/mass_flow_out*sum(rho2.*u2.*area2.*s2);

delta_s = mw_s2-mw_s1;
delta_m = mass_flow_in-mass_flow_out;

