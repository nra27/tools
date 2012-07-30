function Rescale_Heat_Flux(file_root,base_temp,target_temp);
%
% Rescale_Heat_Flux(file_root,base_temp,target_temp)
%
% Function to calculate the wall heat flux for a given wall
% temperature from the adiabatic wall temperature and a set
% wall condition.

% Define the filenames from file_root and wall_temps

adia_file = ['../adia/' file_root '.flow.adia.adf'];
base_file = ['../bc_' num2str(base_temp) '_wf/' file_root '.flow.' num2str(base_temp) '.adf'];
target_file = [file_root '.flow.' num2str(target_temp) '.adf'];

% Initialise ADF variables
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);


% Read the Qdot data in for the files
[D,AWT] = Read_Qdot_Data(adia_file,D);
[D,Qdot_base] = Read_Qdot_Data(base_file,D);

% Calculate the target heat flux
Qdot_target = Qdot_base.*(AWT-target_temp)./(AWT-base_temp);

% Write the data
D = Write_Qdot_Data(target_file,Qdot_target,D);