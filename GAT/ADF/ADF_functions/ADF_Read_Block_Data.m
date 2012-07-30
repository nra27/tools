function [D,data,error_return] = ADF_Read_Block_Data(ID,b_start,b_end,D);
%
% [data,error_return] = ADF_Read_Block_Data(ID,bstart,b_end)
% Read a Contiguous Block of Data from a Node
% See ADF_USERGUIDE.pdf for details
%
%Read a continous block of data from a Node.  Reads a block the node's data
%and returns it into a contiguous memory space.
%
%ADF_Read_Block_Data( ID, data, error_return )
%input:  const double ID		The ID of the node to use.
%input:  const long b_start	The starting point in block in token space
%input:  const long b_end 	The ending point in block in token space
%output: char *data		The start of the data in memory.
%output: int *error_return	Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get datatype size
[D,file_bytes,memory_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if file_bytes == 0 | node.number_of_dimensions == 0
    error_return = 33;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Calculate total number of bytes in the data
total_bytes = file_bytes;
for j = 1:node.number_of_dimensions
    total_bytes = total_bytes*node.dimension_values(j);
end
if total_bytes == 0
    error_return = 27;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Calculate starting and ending range in the file
start_byte = file_bytes*(b_start-1);
end_byte = file_bytes*b_end;
if start_byte < 0 | start_byte > end_byte | end_byte > total_bytes
    error_return = 45;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end
block_bytes = end_byte - start_byte;

% If there is NO DATA, fill data space with zeros, returning error
if node.number_of_data_chunks == 0
    error_return = 33;
    data = zeros(1,block_bytes*memory_bytes.file_bytes);
    return % NO DATA is a warning, so don't check for error
    
% Read the data from disk
elseif node.number_of_data_chunks == 1
    [D,data,error_return] = ADFI_Read_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,start_byte,block_bytes,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
else % Read in the data chunk table
    [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Read data from each entry in the table
    bytes_read = 0;
    chunk_end_bytes = 0;
    data = [];
    for i = 1:node.number_of_data_chunks
        chunk_size = (data_chunk_table(i).end.block - data_chunk_table(i).start.block)*D.Disk_Block_Size + (data_chunk_table(i).end.offset - data_chunk_table(i).start.offset) - (D.Tag_Size + D.Disk_Pointer_Size);
        
        % Check to be sure we don't think the chunk is bigger that it is
        % (shrinking a data block can cause this)
        if chunk_end_byte + chunk_size > total_bytes
            chunk_size = total_bytes - chunk_end_byte;
        end
        if chunk_size == 0
            break
        end
        chunk_end_byte = chunk_end_byte + chunk_size;
        
        % If start of block not in this chunk then continue
        if start_byte > chunk_end_byte
            continue
        end
        % Set offset into the current chunk
        if start_byte > (chunk_end_byte - chunk_size)
            % The start of the block is inside the current chunk, so
            % adjust the offset to the begining of the block
            start_offset = start_byte - (chunk_end_byte - chunk_size);
        else
            start_offset = 0;
        end
        
        % Calculate the number of bytes needed in this chunk
        bytes_to_read = chunk_size - start_offset;
        if bytes_read + bytes_to_read > block_bytes
            bytes_to_read = block_bytes - bytes_read;
        end
        if bytes_to_read == 0 | (chunk_end_byte - chunk_size) > end_byte
            break
        end
        
        [D,data_pointer,error_return] = ADFI_Read_Data_Chunk(file_index,data_chunk_table(i).start,tokenized_data_type,file_bytes,chunk_size,start_offset,bytes_to_read,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % note: memory bytes and file bytes might be different (eg. if machine is 'IEEE BIG' and file is 'Cray')
        % in which case the data pointer advances at a different rate from the file pointer
        data = [data data_pointer];
        bytes_read = bytes_read + bytes_to_read;
    end
    
    clear data_chunk_table
    
    if bytes_read < block_bytes
        error_return = 55;
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
end