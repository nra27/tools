function [D,num_dims,error_return] = ADF_Get_Number_of_Dimensions(ID,D);
%
% [num_dims,error_return] = ADF_Get_Number_of_Dimensions(ID)
% Get the Number of Node Dimensions
% See ADF_USERGUIDE.pdf for details
%
%Get Number of Dimensions.  Return the number of data dimensions 
%used in a node.  Valid values are from 0 to 12.
%
%ADF_Get_Number_of_Dimensions( ID, num_dims, error_return)
%input:  const double ID		The ID of the node to use.
%output: int *num_dims		The returned number of dimensions.
%output: int *error_return	Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Return the number of dimensions
num_dims = node.number_of_dimensions;