function [D,file_index,file_block,block_offset,error_return] = ADFI_ID_2_File_Block_Offset(ID,D);
% [file_index,file_block,block_offset,error_return] = ADFI_ID_2_File_Block_Offset(ID)
%
% The ID is a combination of the file-index, the block within the file, and an offset
% within the block.
%
% The file index is an unsigned 16-bit int
% The block pointer is a 32-bit unsigned int
% The block offset is a 16-bit unsgigned int
%
% file_index - File index from the ID
% file_block - File block from the ID
% block_offset - Block offset from the ID
% error_return - Error return
% ID - Given ADF ID
% D - Delaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, FILE_INDEX_OUT_OF_RANGE, BLOCK_OFFSET_OUT_OF_RANGE

if ID == 0.0
	error_return = 54;
	return
end

error_return = -1;

% Reformat
if exist('num2hex') ~= 2
    % Get the hex representation of the ID
    id = sprintf('%bx',ID);
    a = id(15:16);
    b(1:2) = id(13:14);
    b(3:4) = id(11:12);
    b(5:6) = id(9:10);
    c(1:2) = id(7:8);
    c(3:4) = id(5:6);
else
    % Get the hex representation of the ID
    id = num2hex(ID);
    a = id(1:2);
    b = id(3:8);
    c = id(9:12);
end
    
% Recover
file_index = hex2dec(a);
file_block = hex2dec(b);
block_offset = hex2dec(c);

if file_index >= D.Maximum_Files
	error_return = 10;
	return
end

if block_offset >= D.Disk_Block_Size
	error_return = 11;
	return
end
