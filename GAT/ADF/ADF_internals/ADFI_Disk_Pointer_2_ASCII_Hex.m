function [D,block,offset,error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(block_offset,D);
%
% [block,offset,error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(block_offset,D)
%
% Convert a disk pointer into an ASCII-Hex representation (for disk)
%
% block - 8 byte ASCII block number
% offset - 4 byte ASCII offset number
% error_return - Error return
% block_offset - Disk pointer
% D - Declaration space
% 
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER

error_return = -1;

% Convert into ASCII-Hex form
[D,block,error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(block_offset.block,0,D.Maximum_32_Bits,8,D);
if error_return ~= -1
    return
end

[D,offset,error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(block_offset.offset,0,D.Disk_Block_Size,4,D);
if error_return ~= -1
    return
end