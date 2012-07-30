function [D,free_chunk_table,error_return] = ADFI_Read_Free_Chunk_Table(file_index,D);
%
% D - Declaration space
% free_chunk_table - Pointer to table
% error_return - Error return
% file_index - The file index
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_DISK_TAG_ERROR, ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check the stack for free chunk
[D,disk_free_chunk_data,error_return] = ADFI_Stack_Control(file_index,D.Free_Chunk_Block,D.Free_Chunk_Offset,'GET_STK','FREE_CHUNK_STK',D.Free_Chunk_Table_Size,0,D);

% If not on stack, get data from disk
if error_return ~= -1
    [D,disk_free_chunk_data,error_return] = ADFI_Read_File(file_index,D.Free_Chunk_Block,D.Free_Chunk_Offset,0,D.Free_Chunk_Table_Size,D);
    if error_return ~= -1
        return
    end
    
    % Check the disk tags
    if strcmp(disk_free_chunk_data(1:4),D.Free_Chunk_Table_Start_Tag) ~= 1
        error_return = 17;
        return
    end
    if strcmp(disk_free_chunk_data((D.Free_Chunk_Table_Size - D.Tag_Size + 1):D.Free_Chunk_Table_Size),D.Free_Chunk_Table_End_Tag) ~= 1
        error_return = 17;
        return
    end
    
    % Set the free chunk onto the stack
    [D,disk_free_chunk_data,error_return] = ADFI_Stack_Control(file_index,D.Free_Chunk_Block,D.Free_Chunk_Offset,'SET_STK','FREE_CHUNK_STK',D.Free_Chunk_Table_Size,disk_free_chunk_data,D);
end

% Convert into memory
free_chunk_table.start_tag = char(disk_free_chunk_data(1:4));
free_chunk_table.end_tag = char(disk_free_chunk_data((D.Free_Chunk_Table_Size - D.Tag_Size + 1):D.Free_Chunk_Table_Size));
[D,free_chunk_table.small_first_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(5:12),disk_free_chunk_data(13:16),D);
if error_return ~= -1
    return
end
[D,free_chunk_table.small_last_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(17:24),disk_free_chunk_data(25:28),D);
if error_return ~= -1
    return
end
[D,free_chunk_table.medium_first_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(29:36),disk_free_chunk_data(37:40),D);
if error_return ~= -1
    return
end
[D,free_chunk_table.medium_last_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(41:48),disk_free_chunk_data(49:52),D);
if error_return ~= -1
    return
end
[D,free_chunk_table.large_first_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(53:60),disk_free_chunk_data(61:64),D);
if error_return ~= -1
    return
end
[D,free_chunk_table.large_last_block,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_free_chunk_data(65:72),disk_free_chunk_data(73:76),D);
if error_return ~= -1
    return
end

% Check memory tags
if strcmp(free_chunk_table.start_tag,D.Free_Chunk_Table_Start_Tag) ~= 1
    error_return = 16;
    return
end
if strcmp(free_chunk_table.end_tag,D.Free_Chunk_Table_End_Tag) ~= 1
    error_return = 16;
    return
end