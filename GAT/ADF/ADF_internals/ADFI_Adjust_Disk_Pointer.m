function [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
%
% error_return = ADFI_Adjust_Disk_Pointer(block_offset,D)
% Adjust the dsik pointer so that the offset is in a legal
% range; from 0 and < D.Disk_Block_Size
%
% error_return = Error return
% block_offset = Disk pointer
% D = Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, BLOCK_OFFSET_OUT_OF_RANGE

if isempty(block_offset)
	error_return = 12;
	return
end

error_return = -1;

temp.block = block_offset.block;

% Do this incrementaly to avoid numerical oddities....
while block_offset.offset >= D.Disk_Block_Size
	block_offset.block = block_offset.block + 1;
	if block_offset.block < temp.block % check for roll over
		error_return = 11;
		return
	end
	temp.block = block_offset.block;
	block_offset.offset = block_offset.offset - D.Disk_Block_Size;
end