function [D,error_return] = ADF_Write_Data(ID,s_start,s_end,s_stride,m_num_dims,m_dims,m_start,m_end,m_stride,data,D);
%
% error_return = ADF_Write_Data(ID,s_start,s_end,s_stride,m_num_dims,m_dims,m_start,m_end,m_stride,data)
% Write the Data to a Node having Stride Capabilities
% See ADF_USERGUIDE.pdf for details
%
%Write data to a Node, with partial capabilities.  See ADF_Read_Data for 
%description.
%
%ADF_Write_Data( ID, s_start[], s_end[], s_stride[], m_num_dims, 
%	m_dims[], m_start[], m_end[], m_stride[], data, error_return )
%input:  const double ID		The ID of the node to use.
%input:  const int s_start[]	The starting dimension values to use in 
%				the database (node).
%input:  const int s_end[]	The ending dimension values to use in 
%				the database (node).
%input:  const int s_stride[]	The stride values to use in the database (node).
%input:  const int m_num_dims	The number of dimensions to use in memory.
%input:  const int m_dims[]	The dimensionality to use in memory.
%input:  const int m_start[]	The starting dimension values to use in memory.
%input:  const int m_end[]	The ending dimension values to use in memory.
%input:  const int m_stride[]	The stride values to use in memory.
%input:  const char *data	The start of the data in memory.
%output: int *error_return	Error return.

error_return = -1;
data_chunk_table = 0;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get data_type length
[D,file_bytes,memory_bytes,tokenized_data_type,disk_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if file_bytes == 0 | node.number_of_dimensions == 0
    error_return = 33;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

[D,total_disk_elements,disk_offset,error_return] = ADFI_Count_Total_Array_Points(node.number_of_dimensions,node.dimensions_values,s_start,s_end.s_stride,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,total_memory_elements,memory_offset,error_return] = ADFI_Count_Total_Array_Points(m_num_dims,m_dims,m_start,m_end,m_stride,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if total_disk_elements ~= total_memory_elements
    error_return = 49;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Calculate the total number of data bytes
total_bytes = file_bytes;
for i = 1:node.number_of_dimensions
    total_bytes = total_bytes*node.dimension_values(i);
end
if total_bytes == 0
    error_return = 27;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% Check for need of data translation
[D,formats_compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% If there currently is NO data, allocate disk space for it
if node.number_of_data_chunks == 0
    [D,node.data_chunks,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Initialise the new disk_space with zero's, then we'll write the partial data
    [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,0,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Record the modified node-header
    node.number_of_data_chunks = 1;
    [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);

% If one data chunk, check to see if we need to add a second
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
    data_start.block = node.data_chunks.block
    data_start.offset = node.data_chunks.offset+D.Tag_Size+D.Disk_Pointer_Size;
    [D,data_start,error_return] = ADFI_Adjust_Disk_Pointer(data_start,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % See if the new data exceedes the existing data space
    chunk_total_bytes = end_of_chunk_tag.offset-data_start.offset+(end_of_chunk_tag.block-data_start.block)*D.Disk_Block_Size;
    
    % If data grew: Allocate more data-space and initialize to zero
    if total_bytes > chunk_total_bytes
        % Allocate a second data chunk
        total_bytes = total_bytes - chunk_total_bytes;
        [D,new_block_offset,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Initialize the new data with zeros
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,new_block_offset,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,0,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Allocate a data-chunk-table for 2 entries
        [D,dct_block_offset,error_return] = ADFI_File_Malloc(file_index,(2*D.Tag_Size+5*D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Write data-chunk-table to disk
        data_chunk_table(1).start.block = node.data_chunks.block;
        data_chunk_table(1).start.offset = node.data_chunks.offset;
        % Get the size of the data_chunk for the table and pointer
        [D,data_chunk_table(1).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_table(1).start.block,data_chunk_table(1).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        data_chunk_table(2).start.block = node.data_chunks.block;
        data_chunk_table(2).start.offset = node.data_chunks.offset;
        % Get the size of the data_chunk for the table and pointer
        [D,data_chunk_table(2).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_table(2).start.block,data_chunk_table(2).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        [D,error_return] = ADFI_Write_Data_Chunk_Table(file_index,sct_block_offset,2,data_chunk_table,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Update node header with number of data-chunks = 2and the pointer to the new data-chunk table
        node.data_chunks.block = dct_block_offset.block;
        node.data_chunks.offset = dct_block_offset.offset;
        node.number_of_data_chunks = 2;
        [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
else % Multiple data chunks, check to see if we need to add one more.
    % Read in data-chunk-table
    [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % looping on the data-chunks, look at the size of the chunks
    for i = 1:node.number_of_data_chunks
        current_bytes = (data_chunk_table(i).end.block-data_chunk_table(i).start.block)*D.Disk_Block_Size + (data_chunk_table(i).end.offset-data_chunk_table(i).start.offset) - (D.Tag_Size+D.Disk_Pointer_Size);
        total_bytes = total_bytes-current_bytes;
        
        if total_bytes <= 0
            break
        end
    end
    
    % If we are out of data-chunks and have data left, allocate a new data-chunk in the file
    if total_bytes > 0
        % Write data-chunk table to disk
        new_data_chunk = node.number_of_data_chunks+1;
        % Allocate space in the file
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
        
        % Initialize the new data chunk to zeros
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(new_data_chunk).start,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,0,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Free the old data-chunk-table
        [D,error_return] = ADFI_File_Free(file_index,node.data_chunks,0,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Update the node header with number of data-chunks+1 and the pointer to the data-chunk-table
        node.number_of_data_chunks = new_data_chunk;
        node.data_chunks.block = dct_block_offset.block;
        node.data_chunks.offset = dct_block_offset.offset;
        [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
    end
end

% Do single data chunks here
if node.number_of_data_chunks == 1
    % Point to the start of the data
    block_offset.block = node.data_chunks.block;
    block_offset.offset = node.data_chunks.offset+D.Tag_Size+D.Disk_Pointer_Size+disk_offset*file_bytes;
    [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Set up initial indexing
    current_disk = s_start;
    current_memory = m_start;
    
    % Adjust data pointer
    if memory_offset ~= 0
        data = data+memory_offset*memory_bytes;
    end
    
    for i = 1:total_disk_elements
        % Put the data to disk
        if block_offset.offset > D.Disk_Block_Size
            [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Here is where we need to check for spanning multiple data-chunks
        % Put the data out to disk
        if formats_compare % Directly
            [D,error_return] = ADFI_Write_File(file_index,block_offset.block,block_offset.offset,file_bytes,data,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        else % Translated
            [D,error_return] = ADFI_Write_Data_Translated(file_index,block_offset.block,block_offset.offset,tokenized_data_type,file_bytes,file_bytes,data,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Increment disk/memory pointers, for the special case of one dimensional data we will
        % use a simple increment to maximize the throughput.  Thus for block writes
        % you can temporarily change to 1D for the read to improve efficiency.  Note total size
        % shouldn't change.
        if i < total_disk_elements
            if node.number_of_dimensions == 1
                disk_offset = s_stride(1);
                current_disk(1) = current_disk(1)+disk_offset;
                if current_disk(1) > s_end(1)
                    current_disk(1) = s_end(1);
                end
            else
                [D,current_disk,disk_offset,error_return] = ADFI_Increment_Array(node.number_of_dimensions,node.dimensions_values,s_start,s_end,s_stride,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            if m_num_dims == 1
                memory_offset = m_stride(1);
                current_memory(1) = current_memory(1)+disk_offset;
                if current_memory(1) > m_end(1)
                    current_memory(1) = m_end(1);
                end
            else
                [D,current_memory,memory_offset,error_return] = ADFI_Increment_Array(m_num_dims,m_dims,m_start,m_end,m_stride,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            block_offset.offset = block_offset.offset+disk_offset*file_bytes;
            if block_offset.offset > D.Disk_Block_Size
                [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            data = data+memory_offset*memory_bytes;
        end
    end
else
    % Point to the start of the data
    current_chunk = 1;
    past_chunk_sizes = 0;
    relative_offset = disk_offset*file_bytes;
    current_chunk_size = (data_chunk_table(current_chunk).end.block-data_chunk_table(current_chunk).start.block)*D.Disk_Block_Size+(data_chunk_table(current_chunk).end.offset-data_chunk_table(current_chunk).start.offset)-(D.Tag_Size+D.Disk_Pointer_Size);
    
    % Setup initial indexing
    current_disk = s_start;
    current_memory = m_start;
    
    % Adjust the data pointer
    if memory_offset ~= 0
        data = data+memory_offset*memory_bytes;
    end
    
    for i = 1:total_disk_elements
        while relative_offset >= past_chunk_sizes+current_chunk_size
            if current_chunk+1 >= node.number_of_data_chunks
                error_return = 55;
                [D,error_return] = Check_ADF_Abort(error_return,D);
            else
                past_chunk_sizes = past_chunk_sizes+current_chunk_size;
                current_chunk_size = (data_chunk_table(current_chunk).end.block-data_chunk_table(current_chunk).start.block)*D.Disk_Block_Size+(data_chunk_table(current_chunk).end.offset-data_chunk_table(current_chunk).start.offset)-(D.Tag_Size+D.Disk_Pointer_Size);
            end
        end
        
        % Put the data to disk
        relative_block.block = data_chunk_table(current_chunk).start.block;
        relative_block.offset = data_chunk_table(current_chunk).start.offset+(D.Tag_Size+D.Disk_Pointer_Size)+(relative_offset-past_chunk_sizes);
        if relative_block.offset > D.Disk_Block_Size
            [D,relative_block,error_return] = ADFI_Adjust_Disk_Pointer(relative_block,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Put the data out to disk
        if formats_compare % Directly
            [D,error_return] = ADFI_Write_File(file_index,relative_block.block,relative_block.offset,file_bytes,data,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        else % Translated
            [D,error_return] = ADFI_Write_Data_Translated(file_index,relative_block.block,relative_block.offset,tokenized_data_type,file_bytes,file_bytes,data,D);
        end
        
        % Increment disk and memory pointers
        if i < total_disk_elements
            if node.number_of_dimensions == 1
                disk_offset = s_stride(1);
                current_disk(1) = current_disk(1)+disk_offset;
                if current_disk(1) > s_end(1)
                    current_disk(1) = s_end(1);
                end
            else
                [D,current_disk,disk_offset,error_return] = ADFI_Increment_Array(node.number_of_dimensions,node.dimensions_values,s_start,s_end,s_stride,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            relative_offset = relative_offset+disk_offset*file_bytes;
            
            if m_num_dims == 1
                memory_offet = m_stride(1);
                current_memory(1) = current_memory(1)+disk_offset;
                if current_memory(1) > m_end(1)
                    current_memory(1) = m_end(1);
                end
            else
                [D,current_memory,memory_offset,error_return] = ADFI_Increment_Array(m_num_dims,m_dims,m_start,m_end,m_stride,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            % Adjust the data pointer
            data = data+memory_offset*memory_bytes;
        end
    end
end

if data_chunk_table ~= 0
    clear data_chunk_table
end

% Finally, updata modification data
[D,error_return] = ADFI_Write_Modification_Data(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);