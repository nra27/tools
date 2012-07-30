function Set_Periodic(filename,angle);
% Reverse_Periodic(filename,angle)
%
% A function to set the periodic angle in a hydra grid file.

% Initialise ADF variables
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open ADF database 
[D,root.ID,error_return] = ADF_Database_Open(filename,'OLD','NATIVE',D);

% Move to the Periodic Angle node
[D,per_ang.ID,error_return] = ADF_Get_Node_ID(root.ID,'periodic_angle',D);

% Write the Periodic Angle
[D,error_return] = ADF_Write_All_Data(per_ang.ID,angle,D);

% Close the ADF database
[D,error_return] = ADF_Database_Close(root.ID,D);