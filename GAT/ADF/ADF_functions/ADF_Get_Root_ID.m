function [D,root_ID,error_return] = ADF_Get_Root_ID(ID,D);
%
% [root_ID,error_return] = ADF_Get_Root_ID(ID)
% Get the Root ID for the ADF System
% See ADF_USERGUIDE.pdf for details

error_return = -1;

% Get the file ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Use the file header to get the root-ID
[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Format the root ID
[D,root_ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,file_header.root_node.block,file_header.root_node.offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);