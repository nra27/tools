function [D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,file_block,block_offset,block_and_offset,D);
% 
% [D,error_return] = ADFI_Write_Disk_Pointer_2_Disk(file_index,file_block,block_offset,block_and_offset,D)
%
% Given a pointer to a disk pointer, convert it to ASCII Hex and write it to disk
%
% D - Declaration space
% error_return - Error return
% file_index - The file to write to
% file_block - Block within the file
% block_offset - Offset within the block
% block_and_offset - Disk pointer to write
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Convert into ASCII Hex form
[D,disk_block_offset(1:8),disk_block_offset(9:12),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(block_and_offset,D);
if error_return ~= -1
    return
end

% Put the block/offset to disk
[D,error_return] = ADFI_Write_File(file_index,file_block,block_offset,0,D.Disk_Pointer_Size,disk_block_offset,D);
if error_return ~= -1
    return
end

% Set the block/offset onto the stack
[D,disk_block_offset,error_return] = ADFI_Stack_Control(file_index,file_block,block_offset,'SET_STK','DISK_PTR_STK',D.Disk_Pointer_Size,disk_block_offset,D);
