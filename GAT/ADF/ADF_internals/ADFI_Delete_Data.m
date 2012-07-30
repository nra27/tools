function [D,error_return] = ADFI_Delete_Data(file_index,node_header,D);
%
% [D,error_return] = ADFI_Delete_Data(file_index,node_header,D)#
%
% Deletes all data from the file for a node.
%
% D - Declaration space
% error_return - Error return
% file_index - The index of the ADF file
% node_header - Node header information

error_return = -1;

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

switch node_header.number_of_data_chunks
    case 0 % No data to free, do nothing
        return
    
    case 1 % A single data-chunk to free, so do it
        [D,error_return] = ADFI_File_Free(file_index,node_header.data_chunks,0,D);
        if error_return ~= -1
            return
        end
    
    otherwise % multiple data-chunks to free.  Free them and also the data_chunk table
        % Read in the table
        [D,data_chunk_table,error_return] = ADFI_Read_Data_Chunk_Table(file_index,node_header.data_chunks,D);
        if error_return ~= -1
            return
        end
    
        % Free each entry in the table
        for i = 1:node_header.number_of_data_chunks
            [D,error_return] = ADFI_File_Free(file_index,data_chunk_table(i).start,0,D);
            if error_return ~= -1
                return
            end
        end
    
        clear data_chunk_table
    
        [D,error_return] = ADFI_Free_File(file_index,node_header.data_chunks,0,D);
        if error_return ~= -1
            return
        end
end

% Clear all disk entries off the priority stack for file
[D,a,error_return] = ADFI_Stack_Control(file_index,0,0,'CLEAR_STK','DISK_PTR_STK',0,0,D);
if error_return ~= -1
    return
end