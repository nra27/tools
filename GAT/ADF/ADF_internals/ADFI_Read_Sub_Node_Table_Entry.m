function [D,sub_node_table_entry,error_return] = ADFI_Read_Sub_Node_Table_Entry(file_index,block_offset,D);
%
% [D,sub_node_table_entry,error_return] = ADFI_Read_Sub_Node_Table_Entry(file_index,block_offset,D)
%
% Read a single sub-node-table entry
% No boundary checking is possible!
%
% D - Declaration space
% sub_node_table_entry - the result
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

% Check stack for subnode
[D,sub_node_entry_disk_data,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'GET_STK','SUBNODE_STK',(D.ADF_Name_Length + D.Disk_Pointer_Size),0,D);

if error_return ~= -1
    % Read entry from disk
    [D,sub_node_entry_disk_data,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,0,(D.ADF_Name_Length + D.Disk_Pointer_Size),D);
    if error_return ~= -1
        return
    end
    
    % Set the subnode on the stack
    [D,sub_node_entry_disk_data,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'SET_STK','SUBNODE_STK',(D.ADF_Name_Length + D.Disk_Pointer_Size),sub_node_entry_disk_data,D);
end

% Copy the name
sub_node_table_entry.child_name = char(sub_node_entry_disk_data(1:D.ADF_Name_Length));

% Convert the disk-pointer
[D,sub_node_table_entry.child_location,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(sub_node_entry_disk_data((D.ADF_Name_Length + 1):(D.ADF_Name_Length + 8)),sub_node_entry_disk_data((D.ADF_Name_Length + 9):(D.ADF_Name_Length + D.Disk_Pointer_Size)),D);
if error_return ~= -1
    return
end