function [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node_header,D);
%
% [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node_header,D)
% 
% Take information in the Node_Header structure and format it for disk, then write it.
%
% D - Declaration space
% error_return - Error return
% file_index - The file to write to
% block_offset - Block and offset in the file
% node_header - The node header to write
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

% Check memory tags for proper data
if strcmp(node_header.start_tag,D.Node_Start_Tag) ~= 1
	error_return = 16;
	return
end
if strcmp(node_header.end_tag,D.Node_End_Tag) ~= 1
	error_return = 16;
	return
end

% Memory tags are ok, so format the node header info into disk format and write it
disk_node_data(1:4) = node_header.start_tag;
disk_node_data(5:36) = node_header.name;
disk_node_data(37:68) = node_header.label;
[D,disk_node_data(69:76),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(node_header.num_sub_nodes,0,D.Maximum_32_Bits,8,D);
if error_return ~= -1
	return
end
[D,disk_node_data(77:84),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(node_header.entries_for_sub_nodes,0,D.Maximum_32_Bits,8,D);
if error_return ~= -1
    return
end
[D,disk_node_data(85:92),disk_node_data(93:96),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(node_header.sub_node_table,D);
if error_return ~= -1
	return
end
disk_node_data(97:128) = node_header.data_type;
[D,disk_node_data(129:130),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(node_header.number_of_dimensions,0,12,2,D);
if error_return ~= -1
	return
end
for i = 1:D.ADF_Max_Dimensions
	[D,disk_node_data(123+(i*8):130+(i*8)),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(node_header.dimension_values(i),0,D.Maximum_32_Bits,8,D);
	if error_return ~= -1
		return
	end
end
[D,disk_node_data(227:230),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(node_header.number_of_data_chunks,0,65535,4,D);
if error_return ~= -1
	return
end
[D,disk_node_data(231:238),disk_node_data(239:242),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(node_header.data_chunks,D);
if error_return ~= -1
	return
end
disk_node_data(243:246) = node_header.end_tag;

% Now write the node-header out to disk...
[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,D.Node_Header_Size,disk_node_data,D);
if error_return ~= -1
	return
end

% Set the header onto the stack
[D,disk_node_data,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'SET_STK','NODE_STK',D.Node_Header_Size,disk_node_data,D);
if error_return ~= -1
	return
end