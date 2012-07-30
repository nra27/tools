function [D,error_return] = ADFI_Fseek_File(file_index,file_block,block_offset,D);
%
% [D,error_return] = ADFI_Fseek_File(file_index,file_block,block_offset,D)
%
% To position the current position for FREAD and FWRITE.  Need to allow
% for files larger than what a long int can represent (the offset for FSEEK).
%
% D - Declaration space
% file_index - The file index
% file_block - Block within the file
% block_offset - Offset within the block
% error_return - Error return
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPEN,FSEEK_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

offset = file_block*D.Disk_Block_Size + block_offset;
iret = fseek(D.ADF_File(file_index),offset,'bof');
if iret ~= 0
    error_return = 13;
    return
end