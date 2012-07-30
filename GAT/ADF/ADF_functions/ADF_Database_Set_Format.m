function [D,error_return] = ADF_Database_Set_Format(root_ID,format,D)
%
% error_return = ADF_Database_Set_Format(root_ID,format)
% Set the Data Format
% See ADF_USERGUIDE.pdf for details
%
%Set the data format used in an existing database.
%	Note:  Use with extreme caution.  Needed only 
%	for data conversion utilities and NOT intended 
%	for the general user!!!
%
%ADF_Database_Set_Format( Root_ID, format, error_return )
%input:  const double Root_ID	The root_ID if the ADF file.
%input:  const char *format	See format for ADFDOPN.
%output: int *error_return	Error return.

error_return = ADFI_Check_String_Length(format,D.ADF_Format_Length,error_return);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(root_ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get file_header for the node
[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,machine_format,format_to_use,os_to_use,error_return] = ADFI_Figure_Machine_Format(format,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

file_header.numeric_format = format_to_use;
file_header.os_size = os_to_use;

% Get modification date to be updates with the header
[D,file_header.modification_data] = ADFI_Get_Current_Date(D);

% Now write the header out...
[D,error_return] = ADFI_Write_File_Header(file_index,file_header,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,error_return] = ADFI_Remember_File_Format(file_index,format_to_use,os_to_use,D);
[D,error_return] = Check_ADF_Abort(error_return,D);