function Reverse_Periodic(filename);
% Reverse_Periodic(filename)
%
% A function to reverse the set periodic angle in a hydra grid file.
% A periodic angle of +5 degrees with become -5 degrees.

% Initialise ADF variables
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open ADF database 
[D,root.ID,error_return] = ADF_Database_Open(filename,'OLD','NATIVE',D);

% Move to the Periodic Angle node
[D,per_ang.ID,error_return] = ADF_Get_Node_ID(root.ID,'periodic_angle',D);

% Read the data
[D,ang,error_return] = ADF_Read_All_Data(per_ang.ID,D);

% Write the miror
text = ['The periodic angle has been changed to ' num2str(-ang/pi*180) ' degrees'];
disp(text)

[D,error_return] = ADF_Write_All_Data(per_ang.ID,-ang,D);

% Close the ADF database
[D,error_return] = ADF_Database_Close(root.ID,D);