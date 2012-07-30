function [D,sub_node_table,error_return] = ADFI_Read_Sub_Node_Table(file_index,block_offset,D);
%
% [D,sub_node_table,error_return] = ADFI_Read_Sub_Node_Table(file_index,block_offset,D)
%
% At this point, reading of the ENTIRE table is required
%
% D - Declaration space
% sub_node_table - Array of SN entries
% error_return - Error return
% file_index - The file index
% block_offset - Block and offset in the file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Get tag and length
[D,tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D);
if error_return ~= -1
    return
end

% Calculate the number of children in the sub-node table
number_of_children = ((end_of_chunk_tag.block - block_offset.block)*D.Disk_Block_Size + (end_of_chunk_tag.offset - block_offset.offset))/(D.Disk_Pointer_Size + D.ADF_Name_Length);

current_child.block = block_offset.block;
current_child.offset = block_offset.offset + D.Tag_Size + D.Disk_Pointer_Size;
[D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
if error_return ~= -1
    return
end

% Read and convert the variable-length table into memory
for i = 1:number_of_children
    [D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
    if error_return ~= -1
        return
    end
    
    [D,sub_node_table(i).child_name,error_return] = ADFI_Read_File(file_index,current_child.block,current_child.offset,0,D.ADF_Name_Length,D);
    if error_return ~= -1
        return
    end
    
    current_child.offset = current_child.offset + D.ADF_Name_Length;
    [D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
    if error_return ~= -1
        return
    end
    
    [D,sub_node_table(i).child_location,error_return] = ADFI_Read_Disk_Pointer_frm_Disk(file_index,current_child.block,current_child.offset,D);
    if error_return ~= -1
        return
    end
    
    current_child.offset = current_child.offset + D.Disk_Pointer_Size;
end