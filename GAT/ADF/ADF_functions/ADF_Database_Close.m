function [D,error_return] = ADF_Database_Close(root_ID,D);
%
% error_return = ADF_Database_Close(root_ID)#
% Close a Database
% See ADF_USERGUIDE.pdf for details
%
%Close an opened database.  If the ADF database spans multiple files, 
%then all files used will also be closed.  If an ADF file which is 
%linked to by this database is also opened through another 
%database, only the opened file stream associated with this database 
%will be closed. 
%
%ADF_Database_Close( Root_ID, error_return )
%input:  const double Root_ID	Root-ID of the ADF database.
%output: int *error_return	Error return.

error_return = -1;

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(root_ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Close the ADF file (which may close other sub-files)
[D,error_return] = ADFI_Close_File(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);