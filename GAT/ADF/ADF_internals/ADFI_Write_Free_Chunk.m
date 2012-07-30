function [D,error_return] = ADFI_Write_Free_Chunk(file_index,block_offset,free_chunk,D);
%
% [D,error_return] = ADFI_Write_Free_Chunk(file_index,block_offset,free_chunk,D)
%
% D - Declaration space
% error_return - Error return
% file_index - The ADF file index
% block_offset - Block and offset in the file
% free_chunk - Pointer to free-chunk
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Initialise the block of 'X's
if D.Block_of_XX_Initialized == D.False;
    D.Block_of_XX = char(D.Block_of_XX+'x');
    D.Block_of_XX_Initialized = D.True;
end

% Check memory tags for proper data
if strcmp(free_chunk.start_tag,D.Free_Chunk_Start_Tag) ~= 1
    error_return = 16;
    return
end
if strcmp(free_chunk.end_tag,D.Free_Chunk_End_Tag) ~= 1
    error_return = 16;
    return
end

% Write start tag
[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,D.Tag_Size,free_chunk.start_tag,D);
if error_return ~= -1
    return
end

% Write disk pointers
current_location.block = block_offset.block;
current_location.offset = block_offset.offset + D.Tag_Size;
[D,current_location,error_return] = ADFI_Adjust_Disk_Pointer(current_location,D);
if error_return ~= -1
    return
end

[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,current_location.block,current_location.offset,free_chunk.end_of_chunk_tag,D);
if error_return ~= -1
    return
end

current_location.offset = current_location.offset + D.Disk_Pointer_Size;
[D,current_location,error_return] = ADFI_Adjust_Disk_Pointer(current_location,D);
if error_return ~= -1
    return
end

[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,current_location.block,current_location.offset,free_chunk.next_chunk_tag,D);
if error_return ~= -1
    return
end

% Write out a bunch of 'x's in the free chunk's empty space
current_location.offset = current_location.offset + D.Disk_Pointer_Size;
[D,current_location,error_return] = ADFI_Adjust_Disk_Pointer(current_location,D);
if error_return ~= -1
    return
end

% Fill in partial end of a block
if current_location.block ~= free_chunk.end_of_chunk_tag.block & current_location.offset ~= 0
    [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,0,(D.Disk_Block_Size - current_location.offset),D.Block_of_XX(1:(D.Disk_Block_Size - current_location.offset)),D);
    if error_return ~= -1
        return
    end
    current_location.block = current_location.block + 1;
    current_location.offfset = 0;
end

% Fill in intermediate whole blocks
while current_location.block < free_chunk.end_of_chunk_tag.block
    [D,error_return] = ADFI_Write_File(file_index,current_location.block,0,0,D.Disk_Block_Size,D.Block_of_XX,D);
    if error_return ~= -1
        return
    end
    current_location.block = current_location.block + 1;
end

% Fill in partial block to end_of_free-chunk
if current_location.offset < free_chunk.end_of_chunk_tag.offset
    [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,0,(free_chunk.end_of_chunk_tag.offset-current_location.offset),D.Block_of_XX(1:(free_chunk.end_of_chunk_tag.offset-current_location.offset)),D);
    if error_return ~= -1
        return
    end
end

% Now (finally) write out the free_chunk-end tag
[D,error_return] = ADFI_Write_File(file_index,current_location.block,free_chunk.end_of_chunk_tag.offset,0,D.Tag_Size,free_chunk.end_tag,D);
if error_return ~= -1
    return
end