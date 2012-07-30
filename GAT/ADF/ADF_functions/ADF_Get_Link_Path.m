function [file,name_in_file,error_return] = ADF_Get_Link_Path(ID)
%
% [file,name_in_file,error_return] = ADF_Get_Link_Path(ID)
% Get the Path Information From a Link
% See ADF_USERGUIDE.pdf for details
%
%Get path information from a link.  If the node is a link-node, return 
%the path information.  Else, return an error.  If the link is in the same
%file, then the filename returned is zero length.
%
%ADF_Get_Link_Path( ID, file, name_in_file, error_return )
%input:  const double ID		The ID of the node to use.
%output: char *file	        The returned filename
%output: char *name_in_file	The returned name of node.
%output: int *error_return	Error return

error_return = -1;

% Get the file, block and offset numbers from the ID
[D,file_index,block_offset.block,block_offset.offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
[D,error_return] = Check_ADF_Error(error_return,D);

% Get node_header for the node
[D,node_header,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D);
[D,error_return] = Check_ADF_Error(error_return,D);

if strcmp(node_header.data_type,'LK') ~= 1
    error_return = 51;
    [D,error_return] = Check_ADF_Error(error_return,D);
end

% Get tokenized datatype
[D,file_bytes,machine_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node_header.data_type.D);
[D,error_return] = Check_ADF_Error(error_return,D);

total_bytes = file_bytes*node_header.dimension_values(1);
[D,link_data,error_return] = ADFI_Read_Data_Chunk(file_index,node_header.data_chunks,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,D);
[D,error_return] = Check_ADF_Error(error_return,D);

file = '';
name_in_file = '';

% Look for file/link delimiter
lenfilename = findstr(link_data,D.Link_Separator(file_index));

if lenfilename == 1 % No filename
    name_in_file = link_data(2:end);
    
elseif lenfilename > 1 & lenfilename == length(link_data)
    file = link_data % No link?
    
else
    file = link_data(1:lenfilename-1);
    name_in_file = link_data(lenfilename+1:end);
end    