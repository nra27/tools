function [D,error_return] = ADF_Database_Garbage_Collection(ID,D);
%
% error_return = ADF_Database_Garbage_Collection(ID)
% Flush the Data to Disk
% See ADF_USERGUIDE.pdf for details
%
%Garbage Collection.  This capability will most likely be implemented 
%internally and will not be user-callable.
%
%ADF_Database_Garbage_Collection( ID, error_return )
%input:  const double ID		The ID of a node in the ADF file in which 
%				to do garbage collection.
%output: int *error_return	Error return.

disp('Subroutine ADF_Database_Garbage_Collection is not yet implemented...');

error_return = 23;
[D,error_return] = Check_ADF_Abort(error_return,D);