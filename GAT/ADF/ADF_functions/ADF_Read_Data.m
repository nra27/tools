function [data,error_return] = ADF_Read_Data(ID,s_start,s_end,s_stride,m_num_dims,m_dims,m_start,m_end,m_stride,D)
%
% [data,error_return] = ADF_Read_Data(ID,s_start,s_end,s_stride,m_num_dims,m_dims,m_start,m_end,m_stride,D)
% Read the Data from a Node having Stride Capabilities
% See ADF_USERGUIDE.pdf for details
%
%Read data from a node, with partial capabilities.  The partial 
%capabilities are both in the node's data and also in memory.  
%Vectors of integers are used to indicate the data to be accessed 
%from the node, and another set of integer vectors is used to 
%describe the memory location for the data.  
%	Note:  If the data-type of the node is a compound data-type ("I4[3],R8") 
%for example, the partial capabilities will access one or more of 
%these 20-byte data entities.  You cannot access a subset of an 
%occurrence of the data-type.
%
%ADF_Read_Data( ID, s_start[], s_end[], s_stride[], m_num_dims, 
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
%output: char *data		The start of the data in memory.
%output: int *error_return	Error return.

file_bytes = 0;
memory_bytes = 0;
no_data = D.False;

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get datatype length
[D,file_bytes,memory_bytes,tokenized_data_type,disk_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if file_bytes == 0 | node.number_of_dimensions == 0
    error_return = 33;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

%node.number_of_dimensions
%node.dimension_values

[D,total_disk_elements,disk_offset,error_return] = ADFI_Count_Total_Array_Points(node.number_of_dimensions,node.dimension_values,s_start,s_end,s_stride,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

[D,total_memory_elements,memory_offset,error_return] = ADFI_Count_Total_Array_Points(m_num_dims,m_dims,m_start,m_end,m_stride,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

if total_disk_elements ~= total_memory_elements
    error_return = 49;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

[D,formats_compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Check to see if there is actual data to use
if node.number_of_data_chunks == 0
    no_data = D.True;

% Check for multiple data-chunks
elseif node.number_of_data_chunks == 1 % A single data chunk
    % Point to the start of the data
    block_offset.block = node.data_chunks.block;
    block_offset.offset = node.data_chunks.offset + D.Tag_Size + D.Disk_Pointer_Size + disk_offset*file_bytes;
    
    [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
elseif node.number_of_data_chunks > 1 % Multiple data chunks
    current_chunk = 0;
    past_chunk_sizes = 0;
    relative_offset = disk_offset*file_bytes;
    
    % Read in the data chunk table
    [D,node.data_chunk,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    current_chunk_size = (data_chunk_table(current_chunk).end.block - data_chunk_table(current_chunk).start.block)*D.Disk_Block_Size + (data_chunk_table(current_chunk).end.offset - data_chunk_table(current_chunk).start.offset) - (D.Tag_Size + D.Disk_Pointer_Size);
end

% Setup initial indexing
current_disk = s_start;
current_memory = m_start;

% Adjust disk pointer

if memory_offset ~= 0
    data = data+memory_offset*memory_bytes;
end
for i = 1:total_disk_elements
    % If there is no data on disk, return zeros
    if no_data == D.True
        data = zeros(1,memory_bytes);
    elseif node.number_of_data_chunks == 1 % a single data chunk
        % Get the data off the disk
        if block_offset.offset > D.Disk_Block_Size
            [D,block_offset,error_return] = ADFI_Adjust_Disk_Pointer(block_offset,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        if formats_compare
            % Read the data off the disk directly
            [D,data_pointer,error_return] = ADFI_Read_File(file_index,block_offset.block,block_offset.offset,file_bytes,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        else % Read and translate data
            [D,data_pointer,error_return] = ADFI_Read_Data_Translated(file_index,block_offset.block,block_offset.offset,file_bytes,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Increment disk pointers, for the special case of one dimensional data we will use a
        % simple increment to maximise the throughput.  Thus for block reads you can temporarily
        % change to 1D for the read to improve efficiency.  Note total size shouldn't change!!
        if i < total_disk_elements -1
            if node.number_of_dimensions == 1
                disk_offset = s_stride(1);
                current_disk(1) = current_disk(1)+disk_offset;
                if current_disk(1) > s_end(1)
                    current_disk(1) = s_end(1);
                end
            else
                [D,current_disk,disk_offset,error_return] = ADFI_Increment_Array(node.number_of_dimensions,node.dimension_values,s_start,s_end,s_stride,current_disk,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            block_offset.offset = block_offset.offset + disk_offset*file_bytes;
            if block_offset.offset > D.Disk_Block_Size
                [D,block_offset] = ADFI_Adjust_Disk_Pointer(block_offset,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
        end
    elseif node.number_of_data_chunks > 1 % Multiple data chunks
        while relative_offset >= past_chunk_size+current_chunk_size
            if current_chunk+1 >= node.number_of_data_chunks
                error_return = 55;
                [D,error_return] = Check_ADF_Abort(error_return,D);
            else
                past_chunk_sizes = past_chunk_sizes+current_chunk_size;
                current_chunk_size = (data_chunk_table(current_chunk).end.block-data_chunk_table(current_chunk).start.block)*D.Disk_Block_Size+(data_chunk_table(current_chunk).end.offset-data_chunk_table(current_chunk).start.offset)-(D.Tag_Size+D.Disk_Pointer_Size);
            end
        end
        
        % Get the data off the disk
        relative_block.block = data_chunk_table(current_chunk).start.block;
        relative_block.offset = data_chunk_table(current_chunk).start.offset+(D.Tag_Size+D.Disk_Pointer_Size)+(relative_offset-past_chunk_size);
        if relative_block.offset > D.Disk_Block_Size
            [D,relative_block,error_return] = ADFI_Adjust_Disk_Pointer(relative_block,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        if formats_compare
            % Read the data off disk directly
            [D,data_pointer,error_return] = ADFI_Read_File(file_index,relative_block.block,relative_block.offset,file_bytes,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        else
            % Read the data translated
            [D,data_pointer,error_return] = ADFI_Read_Data_Translated(file_index,relative_block.block,relative_block.offset,tokenized_data_type,file_bytes,file_bytes,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
        
        % Increment disk pointers
        if i < total_disk_elements-1
            if node.number_of_dimensions == 1
                disk_offset = s_stride(1);
                current_disk(1) = current_disk(1) + disk_offset;
                if current_disk(1) > s_end(1)
                    current_disk = s_end(1);
                end
            else
                [D,current_disk,disk_offset,error_return] = ADFI_Increment_Array(node.number_of_dimensions,node.dimension_values,s_start,s_end,s_stride,current_disk,D);
                [D,error_return] = Check_ADF_Abort(error_return,D);
            end
            
            relative_offset = relative_offset + disk_offset*file_bytes;
        end
    end
    data = [data data_pointer];
    
    if i < total_disk_elements -1
        % Increment memory pointers
        if m_num_dims == 1
            memory_offset = m_stride(1);
            current_memory(1) = current_memory(1)+disk_offset;
            if current_memory(1) > m_end(1)
                current_memory(1) = m_end(1);
            end
        else
            [D,current_memory,memory_offset,error_return] = ADFI_Increment_Array(m_num_dims,m_dims,s_start,m_end,m_stride,current_memory,D);
            [D,error_return] = Check_ADF_Abort(error_return,D);
        end
    end
end

if node.number_of_data_chunks > 1 % Multiple data chunks
    free(data_chunk_table)
end        