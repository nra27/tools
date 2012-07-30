function [D,error_return] = ADFI_Write_Data_Translated(file_index,file_block,block_offset,tokenized_data_type,data_size,total_bytes,data,D);
%
% [D,error_return] = ADFI_Write_Data_Translated(file_index,file_block,block_offset,data_type,data_size,total_bytes,data,D)
%
% D - Declaration space
% error_return - Error return
% file_index - The ADF file index
% file_block - Block within the file
% block_offset - Offset within the block
% tokenized_data_type - Type of data being written
% data_size - The size of the data entity in bytes
% total_bytes - The number of bytes expected
% data - The data
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPENED, FSEEK_ERROR

error_return = -1;

if data_size <= 0
	error_return = 46;
	return
end

current_token = 1;
% Get machine size of element stored in the NULL element
while tokenized_data_type(current_token).type(0) ~= 0
    machine_size = tokenized_data_type(current_token).machine_type_size;
    current_token = current_token+1;
end

disk_pointer.block = file_block;
disk_pointer.offset = block_offset;
number_of_data_elements = total_bytes/data_size;
number_of_elements_written = 0;
chunk_size = D.Conversion_Buffer_Size/data_size;
if chunk_size < 1
    error_return = 35;
    return
end

delta_to_bytes = chunk_size*data_size;
delta_from_bytes = chunk_size*machine_size;

% Section data
starting = 1;
ending = delta_from_bytes

while number_of_elements_written < number_of_data_elements
    % Limit the number to the end of the data
    number_of_elements_written = number_of_elements_written + chunk_size;
    if number_of_elements_written > number_of_data_elements
        chunk_size = chunk_size - (number_of_elements_written - number_of_data_elements);
        delta_to_bytes = chunk_size*data_size;
        delta_from_bytes = chunk_size*machine_size;
    end
    
    from_data = data(starting:ending);
    
    [D,to_data,error_return] = ADFI_Convert_Number_Format(D.ADF_This_Machine_Format, ... % from format
                                                            D.ADF_This_Machine_OS_Size, ... % from os size
                                                            D.ADF_File_Format(file_index), ... % to format
                                                            D.ADF_File_OS_Size(file_index), ... % to os size
                                                            'TO_FILE_FORMAT',tokenized_data_type,chunk_size,from_data,D);
    if error_return ~= -1
        return
    end
    
    starting = starting+delta_from_bytes;
    ending = ending+delta_from_bytes;
    disk_pointer.offset = disk_pointer.offset + delta_to_bytes;
    if disk_pointer.offset > D.Disk_Block_Size
        [D,disk_pointer,error_return] = ADFI_Adjust_Disk_Pointer(disk_pointer,D);
        if error_return ~= -1
            return
        end
    end
end