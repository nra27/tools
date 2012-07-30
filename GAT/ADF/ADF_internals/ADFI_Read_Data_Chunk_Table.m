function [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,block_offset,D);
%
% [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,block_offset,D)
%
% D - Declaration set
% data_chunk_table - Data chunk table entries
% error_return - Error return
% file_index - The file index
% block_offset - Block and offset in the file
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPEN

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Get the tag and the length
[D,tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D);
if error_return ~= -1
    return
end

% Compare the start tag
if strcmp(tag,D.Data_Chunk_Table_Start_Tag) ~= 1
    error_return = 17;
    return
end

number_of_bytes_to_read = (end_of_chunk_tag.block - block_offset.block)*D.Disk_Block_Size + (end_of_chunk_tag.offset - block_offset.offset) - (D.Tag_Size + D.Disk_Pointer_Size);

% Read data from disk
tmp_block_offset.block = block_offset.block;
tmp_block_offset.offset = block_offset.offset + D.Tag_Size;

for i = 1:(number_of_bytes_to_read/(2*D.Disk_Pointer_Size))
    tmp_block_offset.offset = tmp_block_offset.offset + D.Disk_Pointer_Size;
    [D,temp_block_offset,error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
    if error_return ~= -1
        return
    end
    [D,data_chunk_table(i).start,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
    if error_return ~= -1
        return
    end
    tmp_block_offset.offset = tmp_block_offset.offset + D.Disk_Pointer_Size;
    [D,temp_block_offset,error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
    if error_return ~= -1
        return
    end
    [D,data_chunk_table(i).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
    if error_return ~= -1
        return
    end
end

[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,0,D.Tag_Size,D);
if error_return ~= -1
    retunr
end

% Compare the end tag
if strcmp(tag,D.Data_Chunk_Table_End_Tag) ~= 1
    error_return = 'ADF_DISK_TAG_ERROR';
    return
end
