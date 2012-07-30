function [D,link_path_length,error_return] = ADF_Is_Link(ID,D);
%
% [link_path_length,error_return] = ADF_Is_Link(ID)
% See if the Node is a Link
% See ADF_USERGUIDE.pdf for details
%
%Test if a Node is a link.  If the actual data-type of the node is "LK" 
%(created with ADF_Link), return the link path length.  Otherwise, 
%return 0.
%
%ADF_Is_Link( ID, link_path_length, error_return )
%input:  const double ID		The ID of the node to use.
%output: int *link_path_length	0 if the node is NOT a link.  If the 
%	node is a link, the length of the path string is returned.
%output: int *error_return	Error return.

error_return = -1;

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get node_header for the node
[D,node_header,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if strcmp(node_header.data_type,'LK')
    link_path_length = node_header.dimension_values(1);
else
    link_path_length = 0;
end