function [D,error_return] = ADFI_Write_Data_Chunk_Table(file_index,block_offset,number_of_data_chunks,data_chunk_table,D);
%
% [D,data_chunk_table,error_return] = ADFI_Write_Data_Chunk_Table(file_index,block_offset,number_of_data_chunks,D)
%
% D - Declaration space
% error_return - Error return
% file_index - The file index
% block_offset - block and offset in the file
% number_of_data_chunks - Number of entries to write
% data_chunk_table - Array of entries
% 
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_File_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Write starting boundary tag
disk_pointer.block = block_offset.block;
disk_pointer.offset = block_offset.offset;
[D,error_return] = ADFI_Write_File(file_index,disk_pointer.block,disk_pointer.offset,D.Tag_Size,D.Data_Chunk_Table_Start_Tag,D);
if error_return ~= -1
    return
end

disk_pointer.offset = disk_pointer.offset + D.Tag_Size;
[D,disk_pointer,error_return] = ADFI_Adjust_Disk_Pointer(disk_pointer,D);
if error_return ~= -1
    return
end

% Calculate the end-of-chunk-tag location...
end_of_chunk_tag.block = disk_pointer.block;
end_of_chunk_tag.offset = disk_pointer.offset + D.Disk_Pointer_Size + 2*number_of_data_chunks*D.Disk_Pointer_Size;
[D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
if error_return ~= -1
    return
end
% ...and write it
[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,disk_pointer.block,disk_pointer.offset,end_of_chunk_tag,D);
if error_return ~= -1
    return
end

% Write data chunk table entries
disk_pointer.offset = disk_pointer.offset + D.Disk_Pointer_Size;
for i = 1:number_of_data_chunks
    [D,disk_pointer,error_return] = ADFI_Adjust_Disk_Pointer(disk_pointer,D);
    if error_return ~= -1
        return
    end
    [D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,disk_pointer.block,disk_pointer.offset,data_chunk_table(i).start,D);
    if error_return ~= -1
        return
    end
    disk_pointer.offset = disk_pointer.offset + D.Disk_Pointer_Size;
end

% Write ending boundary tag
[D,error_return] = ADFI_Write_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,D.Tag_Size,D.Data_Chunk_Table_End_Tag,D);
if error_return ~= -1
    return
end