function [D,error_return] = ADF_Database_Delete(filename,D);
%
% error_return = ADF_Database_Delete(filename)
% Delete a File
% See ADF_USERGUIDE.pdf for details
%
%Delete an existing database.  This will delete one or more ADF files 
%which are linked together under file top ADF file named "filename".
%
%ADF_Database_Delete( filename, error_return )
%input:  char *filename		Filename of the ADF database to delete.
%output: int *error_return	Error return.

[D,error_return] = ADFI_Check_String_Length(filename,D.ADF_Filename_Length,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

disp('Subroutine ADF Database Delete is not yet implemented...');
error_return = 23;
[D,error_return] = Check_ADF_Abort(error_return,D);