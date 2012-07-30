function [D,error_return] = ADFI_Delete_Sub_Node_Table(file_index,block_offset,size_sub_node_table,D);
%
% [D,error_return] = ADFI_Delete_Sub_Node_Table(file_index,block_offset,size_sub_node_table,D)
%
% Deletes a sub-node table from the file
%
% D - Declaration space
% error_return - Error return
% file_index - The ADF file to use
% block_offset - The block and offset of the sub node table
% size_node_table - Current size of the sub node table (usually node_header.entries_for_sub_nodes).
%                       If zero then no action is performed.
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, FREE_OF_ROOT_NODE,
% ADF_DISK_TAG_ERROR, FREE_OF_FREE_CHUNK_TABLE

error_return = -1;
if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

if size_sub_node_table == 0
    return % Assume nothing to do
end

% Calculate size
num_bytes = D.Tag_Size + D.Tag_Size + D.Disk_Pointer_Size + size_sub_node_table*(D.ADF_Name_Length + D.Disk_Pointer_Size);

[D,error_return] = ADFI_File_Free(file_index,block_offset,num_bytes,D);
if error_return ~= -1
    return
end

% Clear all subnode/disk entries off the priority stack for file
[D,a,error_return] = ADFI_Stack_Control(file_index,0,0,'CLEAR_STK_TYPE','SUBNODE_STK',0,0,D);
[D,a,error_return] = ADFI_Stack_Control(file_index,0,0,'CLEAR_STK_TYPE','DISK_PTR_STK',0,0,D);
if error_return ~= -1
    return
end