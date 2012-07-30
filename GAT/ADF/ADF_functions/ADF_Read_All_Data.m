function [D,data,error_return] = ADF_Read_All_Data(ID,D);
%
% [data,error_return] = ADF_Read_All_Data(ID)
% Read All the Data from a Node
% See ADF_USERGUIDE.pdf for details

error_return = -1;
data = [];

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

% If there is NO DATA, fill data space with zeros, return error
if node.number_of_data_chunks == 0
    error_return = 33;
    data = zeros(1,total_bytes*memory_bytes/file_bytes);
    return % NO DATA is really a warning, so don't check and abort...
    
elseif node.number_of_data_chunks == 1 % Read the data from disk
    [D,data,error_return] = ADFI_Read_Data_Chunk(file_index,node.data_chunks,tokenized_data_type,file_bytes,total_bytes,0,total_bytes,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
else % Read in the data chunk table
    [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node.data_chunks,D);
    [D,error_return] = Check_ADF_Abort(error_return,D);
    
    % Read data from each entry in the table
    bytes_read = 0;
    for i = 1:node.number_of_data_chunks
        bytes_to_read = (data_chunk_table(i).end.block - data_chunk_table(i).start.block)*D.Disk_Block_Size + (data_chunk_table(i).end.offset - data_chunk_table(i).start.offset) - (D.Tag_Size + D.Disk_Pointer_Size);
        
        % Check to be sure we aren't reading too much data
        % (shrinking a data block can cause this)
       if bytes_read+bytes_to_read > total_bytes
           bytes_to_read = total_bytes - bytes_read;
       end
       
       if bytes_to_read == 0
           break
       end
       [D,data_pointer,error_return] = ADFI_Read_Data_Chunk(file_index,data_chunk_table(i).start,tokenized_data_type,file_bytes,bytes_to_read,0,bytes_to_read,D);
       [D,error_return] = Check_ADF_Abort(error_return,D);
       data = [data data_pointer];
       
       % Note: memory bytes and file bytes might be different (eg. if machine is 'IEEE BIG' and file is 'Cray')
       % in which case data pointer advaces at a different rate from file pointer
       bytes_read = bytes_read + bytes_to_read;
   end
   clear data_chunk_table
   if bytes_read < total_bytes
       error_return = 55;
   end
end       