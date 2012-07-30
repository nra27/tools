function [D,block_offset,error_return] = ADFI_Disk_Pointer_from_ASCII_Hex(block,offset,D);
%
% [block_offset,error_return] = ADFI_Disk_Pointer_from_ASCII_Hex(block,offset,D)
%
% Convert and ASCII-Hex representation into a disk-pointer (for memory)
%
% block_offset - Disk pointer
% error_return - Error return
% block - 8 byte ASCII block number
% offset - 4 byte ASCII block number
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER

error_return = -1;

% Convert into numeric form
[D,tmp,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,D.Disk_Block_Size,4,offset,D);
if error_return ~= -1;
    return
end

block_offset.offset = tmp;

[D,tmp,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,D.Maximum_32_Bits,8,block,D);
if error_return ~= -1;
    return
end

block_offset.block = tmp;