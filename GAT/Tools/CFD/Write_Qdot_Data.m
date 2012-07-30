function [D,error_return] = Write_Qdot_Data(filename,Qdot,D);
%
% D = Write_Awt_Data(filename,Twall,D)
% function to write the Qdot data in the specified adf file

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = p_ref^1.5/rho_ref^0.5;

% Open Adf file
[D,root.ID,error_return] = ADF_Database_Open(filename,'OLD','NATIVE',D);

% Move to wall heat flux node
[D,whf.ID,error_return] = ADF_Get_Node_ID(root.ID,'wall heat flux',D);

% Scale
Qdot = Qdot/q_ref;

% Write Adiabatic wall temperature scalled by heat-flux
[D,error_return] = ADF_Write_All_Data(whf.ID,Qdot,D);

% Close the database
[D,error_return] = ADF_Database_Close(root.ID,D);