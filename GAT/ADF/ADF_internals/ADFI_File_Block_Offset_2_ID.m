function [D,ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,file_block,block_offset,D);
%
% [D,ID,error_return] = ADFI_File_Block_Offset_2_ID(file_index,file_block,block_offset,D)
%
% Convert an ADF file, block and offset to an ADF ID.
%
% D - Declaration space
% ID - The resulting ADF id
% error_return - Error return
% file_index - The file index (0 to D.Maximum_Files)
% file_block - The block within the file
% block_offset - The offset within the block
%
% Possible errors:
% NO_ERROR, NULL_POINTER, FILE_INDEX_OUT_OF_RANGE, BLOCK_OFFSET_OUT_OF_RANGE

error_return = -1;

if file_index >= D.Maximum_Files
    error_return = 10;
    return
end

if block_offset >= D.Disk_Block_Size
    error_return = 11;
    return
end

% Form the ID from the bytes
a = dec2hex(file_index,2);
b = dec2hex(file_block,6);
c = dec2hex(block_offset,4);

ID = hex2num([a b c]);