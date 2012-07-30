function [D,dim_vals,error_return] = ADF_Get_Dimension_Values(ID,D);
%
% [dim_vals,error_return] = ADF_Get_Dimension_Values(ID)
% Get the Values of the Node Dimensions
% See ADF_USERGUIDE.pdf for details
%
%Get Dimension Values.  Return the dimension values for a node.  Values 
%will be in the range of 1 to 100,000.  Values will only be returned 
%for the number of dimensions defined in the node.  If the number 
%of dimensions for the node is zero, an error is returned.
%
%ADF_Get_Dimension_Values( ID, dim_vals, error_return )
%input:  const double ID		The ID of the node to use.
%output: int dim_vals[]		Array for returned dimension values.
%output: int *error_return	Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Check for zero dimensions
if node.number_of_dimensions == 0
    error_return = 27;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Check for too large dimensions
if node.number_of_dimensions > D.ADF_Max_Dimensions
    error_return = 28;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Copy the dimension information
dim_vals = node.dimension_values;