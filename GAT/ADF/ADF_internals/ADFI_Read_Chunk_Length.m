function [D,tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D);
%
% [tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,block_offset,D)
%
% Read the header of the chunk.  If it is a variable sized chunk, then the first
% 2 things are:
%   Tag and pointer to end_of_chunk-tag
% If NOT variable, then determine what type of chunk it is and return a pointer to
% the end_of_chunk-tag:
%
% If the incoming pointers are 0 0, the we are looking at the file header.
%
% tag - The tag from the chunk
% end_of_chunk_tag - End of chunk pointer
% error_return - Error return
% file_index - the file index
% block_offset - block and offset in the file
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER, ADF_FILE_NOT_OPENED

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

end_of_chunk_tag.block = 0;
end_of_chunk_tag.offset = 0;

% File header
if block_offset.block == 0 & block_offset.offset == 0
    % Point to end-tag
    end_of_chunk_tag.offset = D.File_Header_Size - D.Tag_Size;
    tag = D.File_Header_Tags(1);

% Free-Chunk table
elseif block_offset.block == 0 & block_offset.offset == D.Free_Chunk_Table_Size
    % Point to end-tag
    end_of_chunk_tag.offset = D.Free_Chunks_Offset + D.Free_Chunk_Table_Size - D.Tag_Size;
    tag = D.Free_Chunk_Table_Start_Tag;
    
else
    % Check for 'z's in the file.  This is free-data, too small to include tags and pointers
    count = 0;
    [D,info,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,0,1,D);
    if error_return ~= -1
        return
    end
    
    if strcmp(info,'z')
        current_block_offset = block_offset;
        while strcmp(info,'z')
            count = count+1;
            current_block_offset.offset = current_block_offset.offset + 1;
            [D,current_block_offset,error_return] = ADFI_Adjust_Disk_Pointer(current_block_offset,D);
            if error_return ~= -1
                return
            end
            
            [D,info,error_return] = ADFI_Read_File(file_index,current_block_offset.block,current_block_offset.offset,0,1,D);
            if error_return == 13 | error_return == 15
                break
            end
            if error_return ~= -1
                return
            end
        end
        
        end_of_chunk_tag.block = block_offset.block;
        end_of_chunk_tag.offset = block_offset.offset + count - D.Tag_Size;
        [D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
        tag = 'zzzz';
        if error_return ~= -1
            return
        end
        
    else
        % Read TAG and disk_pointer
        [D,info,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,0,D.Tag_Size + D.Disk_Pointer_Size,D);
        if error_return ~= -1
            return
        end
        
        % Copy the tag
        tag = char(info(1:4));
        
        % Check for known tags
        if strcmp(tag,D.Node_Start_Tag) % Node
            end_of_chunk_tag.block = block_offset.block;
            end_of_chunk_tag.offset = block_offset.offset + D.Node_Header_Size - D.Tag.Size;
            [D,end_of_chunk_tag,error_return] = ADFI_Adjust_Disk_Pointer(end_of_chunk_tag,D);
            if error_return ~= -1
                return
            end
        else
            
            % Convert into numeric format
            [D,end_of_chunk_tag,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(info(5:12),info(13:16),D);
            if error_return ~= -1
                return
            end
        end
    end
end