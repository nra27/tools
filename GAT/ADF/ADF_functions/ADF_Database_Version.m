function [D,version,creation_date,modification_date,error_return] = ADF_Database_Version(root_ID,D);
%
% [version,creation_date,modification_date,error_return] = ADF_Database_Verrsion(root_ID)
% Get the Version Number of the ADF Library that Created the ADF Database
% See ADF_USERGUIDE.pdf for details
%
%Get ADF File Version ID.  This is the version number of the ADF library 
%routines which created an ADF database.  Modified ADF databases 
%will take on the version ID of the current ADF library version if 
%it is higher than the version indicated in the file.
%	The format of the version ID is:  "ADF Database Version 000.01"
%
%ADF_Database_Version( Root_ID, version, creation_date, modification_date,
%	error_return )
%input:  const double Root_ID	The ID of the root node in the ADF file.
%output: char *version		A 32-byte character string containing the
%				version ID.
%output: char *creation_date	A 32-byte character string containing the
%				creation date of the file.
%output: char *modification_date	A 32-byte character string containing the
%				last modification date of the file.
%output: int *error_return	Error return

% Set error flag
error_return = -1;

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(root_ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the file header for the root node
[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Format the 'what' string
version = file_header.what(5:end-1);

% Format the creation date
creation_date = file_header.creation_date;

% Format the modification date
modification_date = file_header.modification_date;