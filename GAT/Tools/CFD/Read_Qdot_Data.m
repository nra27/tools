function [D,Qdot,error_return] = Read_Qdot_Data(filename,D);
%
% [D,Qdot] = Read_Qdot_Data(filename,D)
% function to read the Wall Heat Transfer data from a specified adf file

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = p_ref^1.5/rho_ref^0.5;

% Open ADF database 
[D,root.ID,error_return] = ADF_Database_Open(filename,'READ_ONLY','NATIVE',D);

% Move to the Wall Heat Transfer node
[D,wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(root.ID,'wall heat flux',D);

% Read the data
[D,Qdot,error_return] = ADF_Read_All_Data(wall_heat_flux.ID,D);

% Scale
Qdot = Qdot.*q_ref;

% Close the ADF database
[D,error_return] = ADF_Database_Close(root.ID,D);