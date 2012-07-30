function [D,name,error_return] = ADF_Get_Name(ID,D);
%
% [name,error_return] = ADF_Get_Name(ID)
% Get the Name Node
% See ADF_USERGUIDE.pdf for details

error_return = -1;

% Get the file, block and offset from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the node header
[D,node,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

name = node.name;