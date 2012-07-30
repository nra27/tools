function D = Write_Awal_Data(filename,Twall,D);
%
% D = Write_Awt_Data(filename,Twall,D)
% function to write the Adiabatic wall temperatures over the Qdot data
% in the specified adf file

% Open Adf file
[D,root.ID,error_return] = ADF_Database_Open(filename,'OLD','NATIVE',D);

% Create the Adiabatic Wall Temperature node
[D,awt.ID,error_return] = ADF_Create(root.ID,'adiabatic wall temperature',D);

% Write the Data Types
[D,error_return] = ADF_Put_Dimension_Information(awt.ID,'R8',2,[1 length(Twall)],D);

% Write the data to the node
[D,error_return] = ADF_Write_All_Data(awt.ID,Twall,D);

% Close the database
[D,error_return] = ADF_Database_Close(root.ID,D);