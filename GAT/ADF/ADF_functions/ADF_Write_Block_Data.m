function [D,error_return] = ADF_Write_Block_Data(ID,b_start,b_end,data,D);
%
% error_return = ADF_Write_Block_Data(ID,b_start,b_end,data)
% Write a Contiguous Block of Data to a Node
% See ADF_USERGUIDE.pdf for details
%ADF Write Block Data:
%
%Write all data to a Node.  Writes all the node's data from a contiguous 
%memory space.
%
%ADF_Write_All_Data( ID, data, error_return )
%input:  const double ID     The ID of the node to use.
%input:  const long b_start  The starting point in block in token space
%input:  const long b_end    The ending point in block in token space
%input:  const char *data    The start of the data in memory.
%output: int *error_return   Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get datatype length
[D,file_bytes,memory_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Calculate the total number of data bytes
total_bytes = file_bytes;
for j = 1:node.number_of_dimensions
    total_bytes = total_bytes*node.dimension_values(j);
end
if total_bytes == 0
    error_return = 27;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Calculate the starting and ending range in the file
start_byte = file_bytes*(b_start-1);
end_byte = file_bytes*b_end;
if start_byte < 0 | start_byte > end_byte | end_byte > total_bytes
    error_return = 45;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end
block_bytes = end_byte-start_byte

% If there currently is NO data, allocate disk space for it
if node.number_of_data_chunks == 0
    [D,node.data_chunks,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Write the new data
    [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,start_byte,block_bytes,data,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Record the modified node-header
    node.number_of_data_chunks = 1;
    [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
elseif node.number_of_data_chunks == 1
    % Get the data length
    [D,tag,end_of_chunk_tag,error_return] = ADFI_Read_Chunk_Length(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Check start-of-chunk tag
    if strcmp(tag,D.Data_Chunk_Start_Tag) ~= 1
        error_return = 17;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
    
    % Point to the start of the data
    data_start.block = node.data_chunks.block;
    data_start.offset = node.data_chunks.offset+D.Tag_Size+D.Disk_Pointer_Size;
    [D,data_start,error_return] = ADFI_Adjust_Disk_Pointer(data_start,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % See if the new data exceedes the existing data space
    chunk_size = end_of_chunk_tag.offset-data_start.offset+(end_of_chunk_tag.block-data_start.block)*D.Disk_Block_Size;
    
    % If Data grew; Write old size, then allocate more data space and write the rest
    if total_bytes > chunk_size
        % Write the part of the new data to existing data-chunk
        bytes_written = 0;
        if start_byte <= chunk_size
            bytes_to_write = min(block_bytes,chunk_size-start_byte);
            [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,chunk_size,start_byte,bytes_to_write,data(1:chunk_size),D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
            
            bytes_written = bytes_written+bytes_to_write;
        end
        
        % Allocate a second data-chunk
        total_bytes = total_bytes-chunk_size;
        [D,new_block_offset,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Write the rest of the data
        if bytes_to_write < block_bytes
            bytes_to_write = block_bytes-bytes_written;
            start_offset = max(0,start_byte-chunk_size);
            [D,error_return] = ADFI_Write_Data_Chunk(file_index,new_block_offset,tokenized_data_type,file_bytes,total_bytes,start_offset,bytes_to_write,data(chunk_size+1:end),D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
            
        else
            [D,error_return] = ADFI_Write_Data_Chunk(file_index,new_block_offset,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,0,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Allocate a data-chunk-table to disk
        data_chunk_entry_table(1).start.block = node.data_chunks.block;
        data_chunk_entry_table(1).start.offset = node.data_chunks.offset;
        % Get the size of the data-chunk foe the table end pointer
        [D,data_chunk_entry_table(1).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_entry_table(1).start.block,data_chunk_entry_table(1).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        data_chunk_entry_table(2).start.block = new_block_offset.block;
        data_chunk_entry_table(2).start.offset = new_block_offset.offset;
        % Get the size of the data chunk for the table end pointer
        [D,data_chunk_entry_table(2).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_entry_table(2).start.block,data_chunk_entry_table(2).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        [D,error_return] = ADFI_Write_Data_Chunk_Table(file_index,dct_block_offset,2,data_chunk_entry_table,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Update node header with number of data-chunks = 2 and the pointer to the data-chunk-table
        node.data_chunks.block = dct_block_offset.block;
        node.data_chunks.offset = dct_block_offset.offset;
        node.number_of_data_chunks = 2;
        [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
    else
        % Write the new data to existing data-chunk
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,toeknized_data_type,file_bytes,chunk_size,start_byte,block_bytes,data,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
    
else % Multiple data chunks
    % Read in existing data-chunk-table
    [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Looping on the data-chunks, write the size of the current chunk
    chunk_end_byte = 0;
    bytes_written = 0;
    for i = 1:node.number_of_data_chunks
        chunk_size = (data_chunk_table(i).end.block-data_chunk_table(i).start.block)*D.Disk_Block_Size+(data_chunk_table(i).end.offset-data_chunk_table(i).start.offset)-(D.Tag_Size+D.Disk_Pointer_Size);
        chunk_end_byte = chunk_end_byte+chunk_size;
        
        % If start of block not in this chunk then continue
        if start_byte > chunk_end_byte
            continue
        end
        
        % Set offset into the current chunk
        if start_byte > (chunk_end_byte-chunk_size)
            % The start of the block is inside the current chunk so adjust the offset to the
            % beginning of the block
            start_offset = start_byte-(chunk_end_byte-chunk_size);
        else
            start_offset = 0;
        end
        
        % Check to be sure we aren't writing too much data
        bytes_to_write = chunk_size-start_offset;
        if bytes_written+bytes_to_write > block_bytes
            bytes_to_write = block_bytes-bytes_written;
        end
        if bytes_to_write == 0 | chunk_end_bytes-chunk_size > end_byte
            continue
        end
        
        % Write chunk
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(i).start,tokenized_data_type,file_bytes,chunk_size,start_offset,bytes_to_write,data,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Note: memory_bytes and file_bytes might be different (eg if machine is 'IEEE_BIG' and file is 'CRAY') in which 
        % case the data pointer advances at a different rate from file pointer
        
        data = data(bytes_to_write+1:end);
        bytes_written = bytes_written+bytes_to_write;
    end
    
    % If we are out of data-chunks and have data left, allocate a new data-chunk in the file
    total_bytes = total_bytes-chunk_end_byte;
    if total_bytes > 0
        % Write data-chunk-table to disk
        new_data_chunk = node.number_of_data_chunks+1;
        % Allocate data space in the file
        [D,data_chunk_table(new_data_chunk).start,error_return] = ADFI_File_Malloc(file_index,(2*D.Tag_Size+D.Disk_Pointer_Size+total_bytes),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        data_chunk_table(new_data_chunk).end.block = data_chunk_table(new_data_chunk).start.block;
        data_chunk_table(new_data_chunk).end.offset = data_chunk_table(new_data_chunk).start.offset+D.Tag_Size+D.Disk_Pointer_Size+total_bytes;
        [D,data_chunk_table(new_data_chunk).end,error_return] = ADFI_Adjust_Disk_Pointer(data_chunk_table(new_data_chunk).end,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Allocate space for the new data-chunk-entry-table
        [D,dct_block_offset,error_return] = ADFI_File_Malloc(file_index,(2*D.Tag_Size+(2*new_data_chunk+1)*D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        [D,error_return] = ADFI_Write_Data_Chunk_Table(file_index,dct_block_offset,new_data_chunk,data_chunk_table,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        if bytes_written < block_bytes
            bytes_to_write = block_bytes-bytes_written;
            start_offset = max(0,start_byte-total_bytes);
            [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(new_data_chunk).start,tokenized_data_type,file_bytes,total_bytes,start_offset,bytes_to_write,data,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);    
        else
            [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(new_data_chunk).start,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,0,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Free old data chunk table
        [D,error_return] = ADFI_Free_File(file_index,node.data_chunks,0);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Update node header with number of data-chunks + 1 and the pointer
        % to the new data-chunk-table
        node.number_of_data_chunks = new_data_chunk;
        node.data_chunks.block = dct_block_offset.block;
        node.data_chunks.offset = dct_block_offset.offset;
        [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
    clear data_chunk_table
end

% Finally, update modification date
[D,error_return] = ADFI_Write_Modification_Date(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);