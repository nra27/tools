function [D,free_chunk,next_chunk,error_return] = ADFI_Read_Free_Chunk(file_index,block_offset,D);
%
% [D,free_chunk,next_chunk,error_return] = ADFI_Read_Free_Chunk(file_index,block_offset,D)
%
% Read the free chunk
%
% D - Declaration space
% free_chunk - Free chunk tag
% next_chunk - Pointer to next free chunk
% error_return - Error return
% file_index - The file index
% block_offset - Block offset in the file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_DISK_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Get the tag and the length
[D,tag,free_chunk.end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D);
if error_return ~= -1
    return
end
    
% Compare the start tag
if strcmp(tag,D.Free_Chunk_Start_Tag) ~= 1
    error_return = 17;
    return
end

% Set block offset to the start of the chunk
chunk_block_offset = block_offset;
chunk_block_offset.offset = block_offset.offset + D.Tag_Size + D.Disk_Pointer_Size;
[D,chunk_block_offset,error_return] = ADFI_Adjust_Disk_Pointer(chunk_block_offset,D);
if error_return ~= -1
    return
end

% Read the data from disk
[D,next_chunk,error_return] = ADFI_Read_Disk_Pointer_frm_Disk(file_index,chunk_block_offset.block,chunk_block_offset.offset,D);
if error_return ~= -1
    return
end

% Read end of chunk tag
[D,tag,error_return] = ADFI_Read_File(file_index,free_chunk.end_of_chunk_tag.block,free_chunk.end_of_chunk_tag.offset,0,D.Tag_Size,D);
if error_return ~= -1
    return
end

% Compare the end tag
if strcmp(tag,D.Free_Chunk_End_Tag) ~= 1
    error_return = 17;
    return
end

free_chunk.start_tag = D.Free_Chunk_Start_Tag;
free_chunk.end_tag = D.Free_Chunk_End_Tag;