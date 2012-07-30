function [D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D);
%
% [D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D)
%
% To take the information in the Free_Chunk_Table structure and format it for
% disk, and write it out.
%
% D - Declaration space
% error_return - Error return
% file_index - The index of the ADF file to write to
% free_chunk_table - The free chunk header structure
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check memory tags for proper data
if strcmp(free_chunk_table.start_tag,D.Free_Chunk_Table_Start_Tag) ~= 1
    error_return = 16;
    return
end
if strcmp(free_chunk_table.end_tag,D.Free_Chunk_Table_End_Tag) ~= 1
    error_return = 16;
    return
end

% OK the memory tags look good, so let's format the free_chunk_header
% information into disk format and write it out.
disk_free_chunk_data = free_chunk_table.start_tag;
[D,disk_free_chunk_data(5:12),disk_free_chunk_data(13:16),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.small_first_block,D);
if error_return ~= -1
    return
end

[D,disk_free_chunk_data(17:24),disk_free_chunk_data(25:28),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.small_last_block,D);
if error_return ~= -1
    return
end

[D,disk_free_chunk_data(29:36),disk_free_chunk_data(37:40),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.medium_first_block,D);
if error_return ~= -1
    return
end

[D,disk_free_chunk_data(41:48),disk_free_chunk_data(49:52),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.medium_last_block,D);
if error_return ~= -1
    return
end

[D,disk_free_chunk_data(53:60),disk_free_chunk_data(61:64),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.large_first_block,D);
if error_return ~= -1
    return
end

[D,disk_free_chunk_data(65:72),disk_free_chunk_data(73:76),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(free_chunk_table.large_last_block,D);
if error_return ~= -1
    return
end

disk_free_chunk_data(77:80) = free_chunk_table.end_tag;

% Now write the free_chunk header out to disk...
[D,error_return] = ADFI_Write_File(file_index,D.Free_Chunk_Block,D.Free_Chunk_Offset,0,D.Free_Chunk_Table_Size,disk_free_chunk_data,D);

% Set the free chunk onto the stack
[D,disk_free_chunk_data,error_return] = ADFI_Stack_Control(file_index,D.Free_Chunk_Block,D.Free_Chunk_Offset,'SET_STK','FREE_CHUNK_STK',D.Free_Chunk_Table_Size,disk_free_chunk_data,D);