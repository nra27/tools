function [D,error_return] = ADFI_Write_Data_Chunk(file_index,block_offset,tokenized_data_type,data_size,chunk_bytes,start_offset,total_bytes,data,D);
%
% [D,error_return] = ADFI_Write_Data_Chunk(file_index,block_offset,tokenized_data_type,data_size,chunk_bytes,start_offset,total_bytes,data,D)
%
% D - Declaration space
% error_return - Error_return
% file_index - The file index
% block_offset - Block and offset within the file
% tokenized_data_type - Array
% data_size - Size of data in bytes
% chunk_bytes - Number of bytes in data chunk
% start_offset - starting offset in data chunk
% total_bytes - Number of bytes to write in data chunk
% data - The data
%
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

if (total_bytes + start_offset) > chunk_bytes
    error_return = 35;
    return
end

error_return = -1;

% Write the tag
[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,D.Tag_Size,D.Data_Chunk_Start_Tag,D);
if error_return ~= -1
    return
end

% Calculate the end-of-chunk-tag pointer
end_of_chunk_tag.block = block_offset.block;
end_of_chunk_tag.offset = block_offset.offset + D.Tag_Size + D.Disk_Pointer_Size + chunk_bytes;
[D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
if error_return ~= -1
    return
end

% Adjust location and write end-of-chunk pointer
current_location.block = block_offset.block;
current_location.offset = block_offset.offset + D.Tag_Size;
[D,current_location,error_return] = ADFI_Adjust_Disk_Pointer(current_location,D);
if error_return ~= -1
    return
end

[D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,current_location.block,current_location.offset,end_of_chunk_tag,D);
if error_return ~= -1
    return
end

current_location.offset = current_location.offset + D.Disk_Pointer_Size;
[D,current_location,error_return] = ADFI_Adjust_Disk_Pointer(current_location,D);
if error_return ~= -1
    return
end

% Write the data
if data == 0
    % If the data-pointer is 0, write zeros to the file
    
    % Initialize the block of zeros
    if D.Block_of_00_Initialized == D.False
        block_of_00(1:D.Disk_Block_Size) = '0';
        D.Block_of_00 = D.True;
    end
    
    if total_bytes > D.Disk_Block_Size
        t_bytes = total_bytes;
        
        % If the number of bytes to write is larger that the block of zeros
        % we have, write out a series of zero blocks...
        
        % Write out the remainder of this block
        [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,0,(D.Disk_Block_Size-current_location.offset),block_of_00(1:(D.Disk_Block_Size-current_location.offset)),D);
        if error_return ~= -1
            return
        end
        
        current_location.block = current_location.block+1;
        current_location.offset = 0;
        t_bytes = t_bytes - (D.Disk_Block_Size - current_location.offset);
        
        % Write blocks of zeros, then a partial block
        while t_bytes > 0
            [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,0,min(D.Disk_Block_Size,t_bytes),block_of_00(1:min(D.Disk_Block_Size,t_bytes)),D);
            if error_return ~= -1
                return
            end
            t_bytes = t_bytes - min(D.Disk_Block_Size,t_bytes);
        end
    else
        % Write a partial block of zeros to disk
        [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,0,total_bytes,block_of_00(1:total_bytes),D);
        if error_return ~= -1
            return
        end
    end
else
    % Check for need of data translation
    [D,format_compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
    if error_return ~= -1
        return
    end
    
    if format_compare == 1
        % Write data to disk
        [D,error_return] = ADFI_Write_File(file_index,current_location.block,current_location.offset,tokenized_data_type.type,total_bytes,data,D);
        if error_return ~= -1
            return
        end
    else
        [D,error_return] = ADFI_Write_File_Translated(file_index,current_location.block,current_location.offset,tokenized_data_type,data_size,total_bytes,data,D);
        if error_return ~= -1
            return
        end
    end
end

% Write the ending tag to disk
[D,error_return] = ADFI_Write_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,0,D.Tag_Size,D.Data_Chunk_End_Tag,D);
if error_return ~= -1
    return
end