function [D,error_return] = ADF_Write_All_Data(ID,data,D);
%
% error_return = ADF_Write_All_Data(ID,data)
% Write the All the Data to a Node
% See ADF_USERGUIDE.pdf for details
%
%ADF Write All Data:
%
%Write all data to a Node.  Writes all the node's data from a contiguous 
%memory space.
%
%ADF_Write_All_Data( ID, data, error_return )
%input:  const double ID		The ID of the node to use.
%input:  const char *data	The start of the data in memory.
%output: int *error_return	Error return.

error_return = -1;

[D,LID,file_index,block_offset,node,error_return] = ADFI_Chase_Link(ID,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Get the datatype length
[D,file_bytes,memory_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Datatype(file_index,node.data_type,D);
[D,error_return] = Check_ADF_Abort(error_return,D);

% Calculate the total numebr of data bytes
total_bytes = file_bytes;
for j = 1:node.number_of_dimensions
    total_bytes = total_bytes*node.dimension_values(j);
end
if total_bytes == 0
    error_return = 27;
    [D,error_return] = Check_ADF_Abort(error_return,D);
end

% If there currently is NO data, allocate disk space for it
if node.number_of_data_chunks == 0
    [D,node.data_chunks,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Write the new data
    [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,data,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Record the modified node header
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
    data_start.offset = node.data_chunks.offset + D.Tag_Size + D.Disk_Pointer_Size;
    [D,data_start,error_return] = ADFI_Adjust_Disk_Pointer(data_start,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % See if the new data exceedes the existing data space
    chunk_total_bytes = end_of_chunk_tag.offset-data_start.offset+(end_of_chunk_tag.block-data_start.block)*D.Disk_Block_Size;
    
    % If Data grew: Write old size, then allocate more data-space and write the rest
    if total_bytes > chunk_total_bytes
        % Write the part of the new data to existing data-chunk
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,chunk_total_bytes,0,chunk_total_bytes,data(1:chunk_total_bytes),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Allocate a second data chunk
        total_bytes = total_bytes-chunk_total_bytes;
        [D,new_block_offset,error_return] = ADFI_File_Malloc(file_index,(total_bytes+2*D.Tag_Size+D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Write the rest of the data
        % Note: memory_bytes and file_bytes might be different (eg, if machine is 'IEEE_BIG' and 
        % the file is 'CRAY') in which case data pointers advance at different rates
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,new_block_offset,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,data(chunk_total_bytes+1:end),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Allocate a data chunk table for two entries
        [D,dct_block_offset,error_return] = ADFI_File_Malloc(file_index,(2*D.Tag_Size+5*D.Disk_Pointer_Size),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Write data-chunk-table to disk
        data_chunk_entry_table(1).start.block = node.data_chunks.block;
        data_chunk_entry_table(1).start.offset = node.data_chunks.offset;
        % Get the size of the data_chunk for the table end pointer
        [D,data_chunk_entry_table(1).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_entry_table(1).start.block,data_chunk_entry_table(1).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        data_chunk_entry_table(2).start.block = new_block_offset.block;
        data_chunk_entry_table(2).start.offset = new_block_offset.offset;
        % Get the size of the data_chunk for the table end pointer
        [D,data_chunk_entry_table(2).end,error_return] = ADFI_Read_Disk_Pointer_from_Disk(file_index,data_chunk_entry_table(2).start.block,data_chunk_entry_table(2).start.offset+D.Tag_Size,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        [D,error_return] = ADFI_Write_Data_Chunk_Table(file_index,dct_block_offset,2,data_chunk_entry_table,D);
        
        % Update node header with number of data-chunks = 2 and the pointer to the data-chunk-table
        node.data_chunks.block = dct_block_offset.block;
        node.data_chunks.offset = dct_block_offset.offset;
        node.number_of_data_chunks = 2;
        [D,error_return] = ADFI_Write_Node_Header(file_index,block_offset,node,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
    else
        % Write the new data to existing data-chunk
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,data,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
    end
else % Multiple data chunks
    % Read in the data chunk table
    [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Looping on the data-chunks, write the size of the current chunk
    for i = 1:node.number_of_data_chunks
        current_bytes = (data_chunk_table(i).end.block - data_chunk_table(i).start.block)*D.Disk_Block_Size+(data_chunk_table(i).end.offset-data_chunk_table(i).start.offset)-(D.Tag_Size+D.Disk_Pointer_Size);
        
        % Limit the number of bytes written by whats left to write
        current_bytes = min(current_bytes,total_bytes);
        
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(i).start,tokenized_data_type,file_bytes,current_bytes,0,current_bytes,data(1:current_bytes),D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        data = data(current_bytes+1:end);
        total_bytes = total_bytes - current_bytes;
        if total_bytes <= 0
            break
        end
    end
    
    % If we are out of data-chunks and have data left, allocate a new data-chunk in the file
    if total_bytes > 0
        % Write data-chunk-table to disk
        % Allocate data space in the file
        new_data_chunk = node.number_of_data_chunks+1;
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
        
        [D,error_return] = ADFI_Write_Data_Chunk(file_index,data_chunk_table(new_data_chunk).start,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,data,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Free the old data-chunk-table
        [D,error_return] = ADFI_File_Free(file_index,node.data_chunks,0,D);
        [D,error_return] = Check_ADF_Abort(error_return,D);
        
        % Update node header with number of data_chunks + 1 and the pointer to the new data-chunk-table
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