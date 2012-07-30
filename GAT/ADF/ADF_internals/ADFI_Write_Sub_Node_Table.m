function [D,error_return] = ADFI_Write_Sub_Node_Table(file_index,block_offset,number_of_sub_nodes,sub_node_table,D);
%
% [D,error_return] = ADFI_Write_Sub_Node_Table(file_index,block_offset,number_of_sub_nodes,sub_node_table,D)
%
% D - Declaration space
% error_return - Error_return
% file_index - The file to write to
% block_offset - Block and offset in the file
% number_of_sub_nodes - Number of sub-node entries
% sub_node_table - Array of sub_node_entries
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

% Calculate the end-of-chunk-tag pointer
end_of_chunk_tag.block = block_offset.block;
end_of_chunk_tag.offset = block_offset.offset + D.Tag_Size + D.Disk_Pointer_Size + number_of_sub_nodes*(D.ADF_Name_Length + D.Disk_Pointer_Size);
[D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
if error_return ~= -1
	return
end

% Write start tag
[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,D.Tag_Size,D.Sub_Node_Start_Tag,D);
if error_return ~= -1
	return
end

% Write disk pointer
current_child.block = block_offset.block;
current_child.offset = block_offset.offset + D.Tag_Size;
[D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
if error_return ~= -1
	return
end
[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,current_child.block,current_child.offset,end_of_chunk_tag,D);
if error_return ~= -1
	return
end

% Format and write out the table entries
current_child.offset = current_child.offset + D.Disk_Pointer_Size;
for i = 1:number_of_sub_nodes
	[D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
	if error_return ~= -1
		return
	end
	
	[D,error_return] = ADFI_Write_File(file_index,current_child.block,current_child.offset,0,D.ADF_Name_Length,sub_node_table(i).child_name,D);
	if error_return ~= -1
		return
	end
	
	current_child.offset = current_child.offset + D.ADF_Name_Length;
	[D,current_child,error_return] = ADFI_Adjust_Disk_Pointer(current_child,D);
	if error_return ~= -1
		return
	end
	
	[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,current_child.block,current_child.offset,sub_node_table(i).child_location,D);
	if error_return ~= -1
		return
	end
	
	current_child.offset = current_child.offset + D.Disk_Pointer_Size;
end

% Write closing tag
[D,error_return] = ADFI_Write_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,0,D.Tag_Size,D.Sub_Node_End_Tag,D);
if error_return ~= -1
	return
end