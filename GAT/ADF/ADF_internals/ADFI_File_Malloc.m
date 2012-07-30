function [D,block_offset,error_return] = ADFI_File_Malloc(file_index,size_bytes,D);
%
% [D,block_offset,error_return] = ADFI_File_Malloc(file_index,size_bytes,D)
%
% To allocate a chunk of disk space
%
% D - Declaration space
% block_offset - Pointer to the new disk space
% error_return - Error return
% file_index - ADF file to work on
% size_bytes - The size in bytes to allocate
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;
memory_found = D.False;

% Get the free chunk table
[D,free_chunk_table,error_return] = ADFI_Read_Free_Chunk_Table(file_index,D);
if error_return ~= -1
	return
end

% Look for needed space in the 3 free lists.  Note that all file control
% headers are smaller that the D.Smallest_Chunk_Size and so will be fit
% later into a block at the end of the file.  This greatly improves node
% cretion efficiency.
for i = 1:3
	if memory_found == D.True | size_bytes <= D.Smallest_Chunk_Size
		break
	end
	[D,previous_disk_pointer] = ADFI_Set_Blank_Disk_Pointer(D);
	switch i
		case 1 % Small chunks
			if size_bytes > D.Small_Chunk_Maximum
				continue % Next in the for loop
			end
			first_free_block = free_chunk_table.small_first_block;
			last_free_block = free_chunk_table.small_last_block;
			
		case 2 % Medium chunks
			if size_bytes > D.Medium_Chunk_Maximum
				continue % Next in the for loop
			end
			first_free_block = free_chunk_table.medium_first_block;
			last_free_block = free_chunk_table.medium_last_block;
			
		case 3 % Large chunks
			first_free_block = free_chunk_table.large_first_block;
			last_free_block = free_chunk_table.large_last_block;
	end

    disk_pointer = first_free_block;
    while memory_found ~= D.True & (disk_pointer.block ~= D.Blank_File_Block | disk_pointer.offset ~= D.Blank_Block_Offset)
	    [D,free_chunk,next_chunk,error] = ADFI_Read_Free_Chunk(file_index,disk_pointer,D);
	    if error_return ~= -1
		    return
	    end
	    size = (free_chunk.end_of_chunk_tag.block - disk_pointer.block)*D.Disk_Block_Size + (free_chunk.end_of_chunk_tag.offset - disk_pointer.offset) + D.Tag_Size;
	    if size >= size_bytes
		    block_offset = disk_pointer;
		    if previous_disk_pointer.block ~= D.Blank_File_Block | previous_disk_pointer.offset ~= D.Blank_Block_Offset
			    % Link previous free-chunk to the next free-chunk,
			    % removing this free chunk from the list
			    [D,previous_free_chunk,next_chunk,error_return] = ADFI_Read_Free_Chunk(file_index,previous_disk_pointer,D);
			    if error_return ~= -1
                    return
			    end
			    previous_free_chunk.next_chunk_tag = next_chunk;
			    [D,error_return] = ADFI_Write_Free_Chunk(file_index,previous_disk_pointer,previous_free_chunk,D);
			    if error_return ~= -1
				    return
			    end
			
		    else
			    % Free chunk was the first one, change entry in the free-chunk-header
			    first_free_block = next_chunk;
			    [D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D);
			    if error_return ~= -1
				    return
			    end
		    end
		
		    if last_free_block.block == disk_pointer.block & last_free_block.offset == disk_pointer.offset
			    if previous_disk_pointer.block ~= D.Blank_File_Block | previous_disk_pointer.offset ~= D.Blank_File_Offset
				    last_free_block = previous_disk_pointer;
			    else
				    [D,last_free_block] = ADFI_Set_Blank_Disk_Pointer(D);
			    end
			    [D,error_return] = ADFI_Write_Free_Chunk_Table(file_index,free_chunk_table,D);
			    if error_return ~= -1
				    return
			    end
		    end
		
		    size = size - size_bytes;
		    if size > 0
			    disk_pointer.offset = disk_pointer.offset + size_bytes;
			    [D,disk_pointer,error_return] = ADFI_Adjust_Disk_Pointer(disk_pointer,D);
			    if error_return ~= -1
				    return
			    end
			    [D,error_return] = ADFI_File_Free(file_index,disk_pointer,size,D);
			    if error_return ~= -1
				    return
			    end
			    memory_found = D.True;
            end
		else
		    previous_disk_pointer = disk_pointer;
		    disk_pointer = next_chunk;
        end
    end
end

% The end of file pointer points to the last byte USED, NOT the next byte to USE
if memory_found ~= D.True % Append memory at end of file
	[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
	if error_return ~= -1
		return
	end
	% If the end_of_file is NOT at a block boundary, then see if the new allocated
	% chunk will span a block boundary.  If it will, then start at the new block if
	% if it will fit within the block.  This helps efficiency to have file control
	% headers located within a block boundry.
	if file_header.end_of_file.offset ~= D.Disk_Block_Size
		if file_header.end_of_file.offset+size_bytes >= D.Disk_Block_Size & size_bytes <= D.Disk_Block_Size
			% Free the rest of the block, allocate from next block
			file_header.end_of_file.offset = file_header.end_of_file.offset + 1;
			[D,error_return] = ADFI_File_Free(file_index,file_header.end_of_file,(D.Disk_Block_Size - file_header.end_of_file.offset),D);
			if error_return ~= -1
				return
			end
			block_offset.block = file_header.end_of_file.block + 1;
			block_offset.offset = 0;
			file_header.end_of_file.block = file_header.end_of_file.block + 1;
			file_header.end_of_file.offset = size_bytes - 1;
			[D,file_header.end_of_file,error_return] = ADFI_Adjust_Disk_Pointer(file_header.end_of_file,D);
			if error_return ~= -1
				return
			end
		else % Use the remaining block
			block_offset.block = file_header.end_of_file.block;
			block_offset.offset = file_header.end_of_file.offset + 1;
			file_header.end_of_file.offset = file_header.end_of_file.offset + size_bytes;
			[D,file_header.end_of_file,error_return] = ADFI_Adjust_Disk_Pointer(file_header.end_of_file,D);
			if error_return ~= -1
				return
			end
		end
	else
		% Already pointing to start of block
		block_offset.block = file_header.end_of_file.block + 1;
		block_offset.offset = 0;
		file_header.end_of_file.block = file_header.end_of_file.block + 1;
		file_header.end_of_file.offset = size_bytes - 1;
		[D,file_header.end_of_file,error_return] = ADFI_Adjust_Disk_Pointer(file_header.end_of_file,D);
		if error_return ~= -1
			return
		end
	end

    % Write out the modified file header
    [D,error_return] = ADFI_Write_File_Header(file_index,file_header,D);
    if error_return ~= -1
        return
    end
end