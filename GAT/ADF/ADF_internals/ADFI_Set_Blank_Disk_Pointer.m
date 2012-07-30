function [D,block_offset] = ADFI_Set_Blank_Disk_Pointer(D);
%
% [D,block_offset] = ADFI_Set_Blank_Disk_Pointer(D)
%
% Set the block and offset to the defined 'blank' or unused values
%
% D - Declaration space
% block_offset - Block and offset in the file
%
% Possible errors:
% none allowed

block_offset.block = D.Blank_File_Block;
block_offset.offset = D.Blank_Block_Offset;