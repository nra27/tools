function [D,data_type,error_return] = ADF_Get_Data_Type(ID,D);
%
% [data_type,error_return] = ADF_Get_Data_Type(ID)
% Get the String in a Node's Data Type Field
% See ADF_USERGUIDE.pdf for details
%
%Get Data Type.  Return the 32 character string in a node's data-type field.
%In C, the name will be null terminated after the last non-blank character.
%A maximum of 33 characters may be used (32 for the name plus 1 for the null).
%
%ADF_Get_Data_Type( ID, data_type, error_return )
%input:  const double ID		The ID of the node to use.
%output: char *data_type		The 32-character data-type of the node.
%output: int *error_return	Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

data_type = node.data_type;