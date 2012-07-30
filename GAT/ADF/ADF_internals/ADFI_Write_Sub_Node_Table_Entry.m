function [D,error_return] = ADFI_Write_Sub_Node_Table_Entry(file_index,block_offset,sub_node_table_entry,D);
%
% [D,error_return] = ADFI_Write_Sub_Node_Table_Entry(file_index,block_offset,sub_node_table_entry,D)
%
% D - Declaration space
% error_return - Error return
% file_index - The file to write to
% block_offset - The block and offset in the file
% sub_node_entry - The entry to write
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

% Format the tag and disk pointer in memory
sub_node_entry_data_disk = sub_node_table_entry.child_name;
[D,sub_node_entry_data_disk(D.ADF_Name_Length+1:D.ADF_Name_Length+8),sub_node_entry_data_disk(D.ADF_Name_Length+9:D.ADF_Name_Length+12),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(sub_node_table_entry.child_location,D);
if error_return ~= -1
	return
end

% Now write it out to disk
[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,D.ADF_Name_Length + D.Disk_Pointer_Size,sub_node_entry_data_disk,D);
if error_return ~= -1
	return
end

% Set the subnode onto the stack
[D,sub_node_entry_data_disk,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'SET_STK','SUBNODE_STK',D.ADF_Name_Length+D.Disk_Pointer_Size,sub_node_entry_data_disk,D);
if error_return ~= -1
	return
end