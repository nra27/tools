function [D,node_header,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D);
%
% [D,node_header,error_return] = ADFI_Read_Node_Header(file_index,block_offset,D)
%
% D - Declaration space
% node_header - the returned node header
% error_return - Error return
% file_index - ADF file index
% block_offset - Block and Offset within the file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_DISK_TAG_ERROR,
% ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check the stack for header
[D,disk_node_data,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'GET_STK','NODE_STK',D.Node_Header_Size,0,D);

if error_return ~= -1
    % Get the node header from disk
    [D,disk_node_data,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,0,D.Node_Header_Size,D);
    if error_return ~= -1
        return
    end
    
    % Check the disk tags
    if strcmp(disk_node_data(1:4),D.Node_Start_Tag) ~= 1
        error_return = 17;
        return
    end
    if strcmp(disk_node_data(D.Node_Header_Size-D.Tag_Size+1:D.Node_Header_Size),D.Node_End_Tag) ~= 1
        error_return = 17;
        return
    end
    
    % Set header onto the stack
    [D,node_header_data,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'SET_STK','NODE_STK',D.Node_Header_Size,disk_node_data,D);
end

% Convert into memory
node_header.start_tag = disk_node_data(1:D.Tag_Size);
node_header.end_tag = disk_node_data(D.Node_Header_Size-D.Tag_Size+1:D.Node_Header_Size);

node_header.name = disk_node_data(D.Tag_Size+1:36);
node_header.label = disk_node_data(37:68);

[D,node_header.num_sub_nodes,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,D.Maximum_32_Bits,8,disk_node_data(69:76),D);
if error_return ~= -1
    return
end
[D,node_header.entries_for_sub_nodes,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,D.Maximum_32_Bits,8,disk_node_data(77:84),D);
if error_return ~= -1
    return
end

[D,node_header.sub_node_table,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_node_data(85:92),disk_node_data(93:96),D);
if error_return ~= -1
    return
end

node_header.data_type = disk_node_data(97:128);

[D,node_header.number_of_dimensions,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,12,2,disk_node_data(129:130),D);
if error_return ~= -1
    return
end

for i = 1:D.ADF_Max_Dimensions
    [D,node_header.dimension_values(i),error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,D.Maximum_32_Bits,8,disk_node_data(131+((i-1)*8):130+(i*8)),D);
    if error_return ~= -1
        return
    end
end

[D,node_header.number_of_data_chunks,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,65535,4,disk_node_data(227:230),D);
if error_return ~= -1
    return
end

[D,node_header.data_chunks,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_node_data(231:238),disk_node_data(239:242),D);
if error_return ~= -1
    return
end

% Check memory tags
if strcmp(node_header.start_tag,D.Node_Start_Tag) ~= 1
    error_return = 16;
    return
end
if strcmp(node_header.end_tag,D.Node_End_Tag) ~= 1
    error_return = 16;
    return
end