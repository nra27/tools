function [D,num_ids,ids,error_return] = ADFI_Get_Direct_Children_IDs(file_index,node_block_offset,D);
%
% [D,num_ids,ids,error_return] = ADFI_Get_Direct_Children_IDs(file_index,node_block_offset,D)
%
% Get children ids of a node.  Return the ids of children nodes directly associated with a parent
% node (no lins are followed).  The ids of the children are NOT guaranteed to be returned in any
% particular order.  If it is desired to follow potential links for the node ID, then
% call ADFI_Chase_Link() and pass the resultant link ID to this function.
% NOTE: link nodes do not have direct children.
%
% D - Declaration space
% num_ids - The number of ids returned
% ids - An allocated array of ids (free this space).
% error_return - Error return
% file_index - The index of the ADF file
% node_block_offset - The block and offset within the file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, MEMORY_ALLOCATION_FAILED, FILE_INDEX_OUT_OF_RANGE,
% BLOCK_OFFSET_OUT_OF_RANGE, ADF_FILE_NOT_OPENED, ADF_DISK_TAG_ERROR,
% ADF_MEMORY_TAG_ERROR

error_return = -1;

num_ids = 0;
ids = 0;

[D,node,error_return] = ADFI_Read_Node_Header(file_index,node_block_offset,D);
if error_return ~= -1
    return
end

% Check for zero children, return if zero
if node.num_sub_nodes == 0
    return
end

% Point to the first child
sub_node_block_offset.block = node.sub_node_table.block;
sub_node_block_offset.offset = node.sub_node_table.offset + (D.Tag_Size + D.Disk_Pointer_Size);

% Return the ids for all the children
num_ids = node.num_sub_nodes;
for i = 1:num_ids
    [D,sub_node_block_offset] = ADFI_Adjust_Disk_Pointer(sub_node_block_offset,D);
    if error_return ~= -1
        return
    end
    
    % Read one sub_node table entry
    [D,sub_node_table_entry,error_return] = ADFI_Read_Sub_Node_Table_Entry(file_index,sub_node_block_offset,D);
    if error_return ~= -1
        return
    end
    
    % Get the ID from the sub_node_table
    [D,ids(i),error_return] = ADFI_File_Block_Offset_2_ID(file_index,sub_node_table_entry.child_location.block,sub_node_table_entry.child_location.offset,D);
    if error_return ~= -1
        return
    end
    
    % Increment the disk-pointer
    sub_node_block_offset.offset = sub_node_block_offset.offset + (D.ADF_Name_Length + D.Disk_Pointer_Size);
end