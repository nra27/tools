function [D,error_return] = ADFI_File_Free(file_index,block_offset,number_of_bytes,D);
%
% [D,error_return] = ADFI_File_Free(file_index,block_offset,number_of_bytes,D)
%
% To free up a chunk of file space
% 
% D - Declaration space
% error_return - Error return
% file_index - The ADF file index (0 to D.Maximum_Files)
% bock_offset - Block and offset in the file
% number_of_bytes - The number of bytes to free.  If 0, then look at the type of
%						chunk to get size
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED
% FREE_OF_ROOT_NODE, ADF_DISK_TAG_ERROR, FREE_OF_FREE_CHUNK_TABLE

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

if number_of_bytes == 0
	% Check the disk tag to see what kind of disk chunk we have.
	% We need this to determine the length of the chunk.
	[D,tag,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,0,D.Tag_Size,D);
	if error_return ~= -1
		return
	end
	
	end_of_chunk_tag.block = 0;
	end_of_chunk_tag.offset = 0;
	
	if strcmp(tag,D.Node_Start_Tag) == 1 % This is a node
		if block_offset.block == D.Root_Node_Block & block_offset.offset == D.Root_Node_Offset
			error_return = 20;
			return
		end
		
		end_of_chunk_tag.block = block_offset.block;
		end_of_chunk_tag.offset = block_offset.offset + D.Node_Header_Size - D.Tag_Size;
		if end_of_chunk_tag.offset > D.Disk_Block_Size
			[D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
			if error_return ~= -1
				return
			end
		end
		
		% Check disk-boundary tag
		[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,D.Tag_Size,D);
		if error_return == -1
			return
		end
		if strcmp(tag,D.Node_End_Tag) ~= 1
			error_return = 17;
			return
		end
		
	elseif strcmp(tag,D.Free_Chunk_Table_Start_Tag) == 1
		% Trying to free the free-chunk-table.  This is BAD
		error_return = 21;
		return
		
	elseif strcmp(tag,D.Free_Chunk_Start_Tag) == 1
		% Set a temporary block_offset to read disk pointer
		tmp_block_offset.block = block_offset.block;
		tmp_block_offset.offset = block_offset.offset + D.Tag_Size;
		if tmp_block_offset.offset > D.Disk_Block_Size
			[D,tmp_block_offset.error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
			if error_return ~= -1
				return
			end
		end
		
		% Get the end_of_chunk_tag block/offset from disk
		[D,end_of_chunk_tag,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
		if error_return ~= -1
            return
		end
		
		% Check the disk-boundary tag
		[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,D.Tag_Size,D);
		if error_return ~= -1
			return
		end
		if strcmp(tag,D.Free_Chunk_End_Tag) ~= 1
			error_return = 17;
			return
		end
		
	elseif strcmp(tag,D.Sub_Node_Start_Tag) == 1
		% Set a temporary block_offset to read disk pointer
		tmp_block_offset.block = block_offset.block;
		tmp_block_offset.offset = block_offset.offset + D.Tag_Size;
		if tmp_block_offset.offset > D.Disk_Block_Size
			[D,tmp_block_offset.error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
			if error_return ~= -1
				return
			end
		end
		
		% Get the end_of_chunk_tag block/offset from disk
		[D,end_of_chunk_tag,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
		if error_return ~= -1
			return
		end
		
		% Check the disk-boundary tag
		[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,D.Tag_Size,D);
		if error_return ~= -1
			return
		end
		if strcmp(tag,D.Sub_Node_End_Tag) ~= 1
			error_return = 17;
			return
		end
		
	elseif strcmp(tag,D.Data_Chunk_Table_Start_Tag) == 1
		% Set a temporary block_offset to read disk pointer
		tmp_block_offset.block = block_offset.block;
		tmp_block_offset.offset = block_offset.offset + D.Tag_Size;
		if tmp_block_offset.offset > D.Disk_Block_Size
			[D,tmp_block_offset.error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
			if error_return ~= -1
				return
			end
		end
		
		% Get the end_of_chunk_tag block/offset from disk
		[D,end_of_chunk_tag,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
		if error_return ~= -1
			return
		end
		
		% Check the disk-boundary tag
		[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,D.Tag_Size,D);
		if error_return ~= -1
			return
		end
		if strcmp(tag,D.Data_Chunk_Table_End_Tag) ~= 1
			error_return = 17;
			return
		end
		
	elseif strcmp(tag,D.Data_Chunk_Start_Tag) == 1
		% Set a temporary block_offset to read disk pointer
		tmp_block_offset.block = block_offset.block;
		tmp_block_offset.offset = block_offset.offset + D.Tag_Size;
		if tmp_block_offset.offset > D.Disk_Block_Size
			[D,tmp_block_offset.error_return] = ADFI_Adjust_Disk_Pointer(tmp_block_offset,D);
			if error_return ~= -1
				return
			end
		end
		
		% Get the end_of_chunk_tag block/offset from disk
		[D,end_of_chunk_tag,error_return] = ADFI_Read_Disk_Pointer_frm_Disk(file_index,tmp_block_offset.block,tmp_block_offset.offset,D);
		if error_return ~= -1
			return
		end
		
		% Check the disk-boundary tag
		[D,tag,error_return] = ADFI_Read_File(file_index,end_of_chunk_tag.block,end_of_chunk_tag.offset,0,D.Tag_Size,D);
		if error_return ~= -1
			return
		end
		if strcmp(tag,D.Data_Chunk_End_Tag) ~= 1
			error_return = 17;
			return
		end
		
	else
		error_return = 17;
		return
	end
	
	number_of_bytes = (end_of_chunk_tag.block - block_offset.block)*D.Disk_Block_Size + (end_of_chunk_tag.offset - block_offset.offset + D.Tag_Size);
	
else % Use the number of bytes passed in
	end_of_chunk_tag.block = block_offset.block;
	end_of_chunk_tag.offset = block_offset.offset + number_of_bytes - D.Tag_Size;
	[D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
	if error_return ~= -1
		return
	end
end

if number_of_bytes <= D.Smallest_Chunk_Size % Too small, z-gas
	% Initialize the block of 'Z's
	if D.Block_of_ZZ_Initialized == D.False;
		D.Block_of_ZZ = char(D.Block_of_ZZ+'z');
		D.Block_of_ZZ_Initialized = D.True;
	end
	
	[D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,0,number_of_bytes,D.Block_of_ZZ(1:number_of_bytes),D);
	if error_return ~= -1
		return
	end
	
else % Add ths chunk to the free table
	% Get the free chunk table
	[D,free_chunk_table,error_return] = ADFI_Read_Free_Chunk_Table(file_index,D);
	if error_return ~= -1
		return
	end
	
	if block_offset.block == end_of_chunk_tag.block % small or medium
		if end_of_chunk_tag.offset + D.Tag_Size - block_offset.offset <= D.Small_Chunk_Maximum % Small chunk
			free_chunk.end_of_chunk_tag.block = end_of_chunk_tag.block;
			free_chunk.end_of_chunk_tag.offset = end_of_chunk_tag.offset;
			free_chunk.next_chunk_tag.block = free_chunk_table.small_first_block.block;
			free_chunk.next_chunk_tag.offset = free_chunk_table.small_first_block.offset;
			free_chunk_table.small_first_block.block = block_offset.block;
			free_chunk_table.small_first_block.offset = block_offset.offset;
			
			% If linked-list was empty, also point to this as the last.
			if free_chunk.next_chunk_tag.offset == D.Blank_Block_Offset
				free_chunk_table.small_last_block.block = block_offset.block;
				free_chunk_table.small_last_block.offset = block_offset.offset;
			end
		else % Medium chunk
			free_chunk.end_of_chunk_tag.block = end_of_chunk_tag.block;
			free_chunk.end_of_chunk_tag.offset = end_of_chunk_tag.offset;
			free_chunk.next_chunk_tag.block = free_chunk_table.medium_first_block.block;
			free_chunk.next_chunk_tag.offset = free_chunk_table.medium_first_block.offset;
			free_chunk_table.medium_first_block.block = block_offset.block;
			free_chunk_table.medium_first_block.offset = block_offset.offset;
			
			% If linked-list was empty, also point to this as the last.
			if free_chunk.next_chunk_tag.offset == D.Blank_Block_Offset
				free_chunk_table.medium_last_block.block = block_offset.block;
				free_chunk_table.medium_last_block.offset = block_offset.offset;
			end
		end
	
	else % Large chunk
		free_chunk.end_of_chunk_tag.block = end_of_chunk_tag.block;
		free_chunk.end_of_chunk_tag.offset = end_of_chunk_tag.offset;
		free_chunk.next_chunk_tag.block = free_chunk_table.large_first_block.block;
		free_chunk.next_chunk_tag.offset = free_chunk_table.large_first_block.offset;
		free_chunk_table.large_first_block.block = block_offset.block;
		free_chunk_table.large_first_block.offset = block_offset.offset;
			
		% If linked-list was empty, also point to this as the last.
		if free_chunk.next_chunk.offset == D.Blank_Block_Offset
			free_chunk_table.large_last_block.block = block_offset.block;
			free_chunk_table.large_last_block.offset = block_offset.offset;
		end
	end
	
	% Put the free-chunks tags in place
	free_chunk.start_tag = D.Free_Chunk_Start_Tag;
	free_chunk.end_tag = D.Free_Chunk_End_Tag;
	
	% Write out the free chunk
	[D,error_return] = ADFI_Write_Free_Chunk(file_index,block_offset,free_chunk,D);
	if error_return ~= -1
		return
	end
	
	% Update the free-chunk table
	[D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D);
	if error_return ~= -1
		return
	end
end

% Delete the block/offset off the stack
[D,a,error_return] = ADFI_Stack_Control(file_index,block_offset.block,block_offset.offset,'DEL_STK_ENTRY',0,0,0,D);
if error_return ~= -1
	return
end