function [D,block_and_offset,error_return] = ADFI_Read_Disk_Pointer_frm_Disk(file_index,file_block,block_offset,D);
%
% [block_offset,error_return] = ADFI_Read_Disk_Pointer_frm_Disk(file_index,file_block,file_offset,D)
%
% Given a pointer to a disk pointer, read it from disk and convert it into numeric form.
%
% block_and_offset - Resulting disk pointer
% error_return - Error return
% file_index - File to read from
% file_block - Target block
% block_offset - Target offset
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if block_offset > D.Disk_Block_Size
    error_return = 11;
    return
end

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check the stack for block/offset
[D,disk_block_offset,error_return] = ADFI_Stack_Control(file_index,file_block,block_offset,'GET_STK','DISK_PTR_STK',D.Disk_Pointer_Size,0,D);
if error_return ~= -1
    
    % Get the block/offset from disk
    [D,disk_block_offset,error_return] = ADFI_Read_File(file_index,file_block,block_offset,0,D.Disk_Pointer_Size,D);
    if error_return ~= -1
        return
    end
    
    % Set the block/offset onto the stack
    [D,disk_block_offset,error_return] = ADFI_Stack_Control(file_index,file_block,block_offset,'SET_STK','DISK_PTR_STK',D.Disk_Pointer_Size,disk_block_offset,D);
end

% Convert into numeric form
[D,block_and_offset,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_block_offset(1:8),disk_block_offset(9:12),D);
if error_return ~= -1
    return
end