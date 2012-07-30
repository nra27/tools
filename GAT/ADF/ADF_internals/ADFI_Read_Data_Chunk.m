function [D,data,error_return] = ADFI_Read_Data_Chunk(file_index,block_offset,tokenized_data_type,data_size,chunk_bytes,start_offset,total_bytes,D);
%
% [D,Data,error_return] = ADFI_Read_Data_Chunk(file_index,block_offset,toeknized_data_type,data_size,chunk_bytes,start_offset,total_bytes,D);
%
% D - Declaration space
% data - read data
% error_return - Error return
% file_index - the file index
% block_offset - Pointer to data
% tokenized_data_type - Defined data type
% data_size - Size of data entity in bytes
% chunk_bytes - Number of bytes in data chunk
% start_offset - Starting offset into the data chunk
% total_bytes - total number of bytes to read
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPENED, ADF_TAG_ERROR, REQUESTED_DATA_TOO_LONG

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

if total_bytes+start_offset > chunk_bytes
    error_return = 35;
    return
end

error_return = -1;

% Get tag and chunk length
[D,tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D);
if error_return ~= -1
    return
end
% Check start tag
if strcmp(tag,D.Data_Chunk_Start_Tag) ~= 1
    error_return = 17;
    return
end
% Check end tag
[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,0,D.Tag_Size,D);
if error_return ~= -1
    return
end
if strcmp(tag,D.Data_Chunk_End_Tag) ~= 1
    error_return = 17;
    return
end

% Point to the start of the data
data_start.block = block_offset.block;
data_start.offset = block_offset.offset + start_offset + D.Disk_Pointer_Size + D.Tag_Size;

[D,data_start,error_return] = ADFI_Adjust_Disk_Pointer(data_start,D);
if error_return ~= -1
    return
end

% Calculate the total number of data bytes
chunk_total_bytes = end_of_chunk_tag.offset - data_start.offset + start_offset + (end_of_chunk_tag.block - data_start.block)*D.Disk_Block_Size;
if chunk_bytes > chunk_total_bytes
    error_return = 35;
    return
end

% Check the need for data translation
[D,format_compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
if error_return ~= -1
    return
end

% Force no translation! This should be ok until the translation routines are fixed
format_compare = 1; 

if format_compare
    % Read the data off the disk
    [D,data,error_return] = ADFI_Read_File(file_index,data_start.block,data_start.offset,tokenized_data_type.type,total_bytes,D);
    if error_return ~= -1
        return
    end
else
    [D,data,error_return] = ADFI_Read_Data_Translated(file_index,data_start.block,data_start.offset,tokenized_data_type,data_size,total_bytes,D);
    if error_return ~= -1
        return
    end
end