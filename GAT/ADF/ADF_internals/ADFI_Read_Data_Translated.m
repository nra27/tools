function [D,data,error_return] = ADFI_Read_Data_Translated(file_index,file_block,block_offset,tokenized_data_type,data_size,total_bytes,D);
%
% [D,data,error_return] = ADFI_Read_Data_Translated(file_index,file_block,block_offset,data_type,tokenized_data_type,data_size,total_bytes,D)
%
% D - Declaration space
% data - Returned data
% error_return - Error return
% file_index - ADF file index
% file_block - Block within file
% block_offset - Offset within block
% tokenized_data_type - The defined data type
% data_size - Size of data entity in bytes
% total_bytes - Number of bytes expected
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPENED

if data_size <= 0
	error_return = 46;
	return
end

error_return = -1;
current_token = 1;
data = [];

% Get machine size of element stored in the NULL element
while tokenized_data_type(current_token).type(1) ~= 0
    machine_size = tokenized_data_type(current_token).machine_type_size;
    current_token = current_token + 1;
end

disk_pointer.block = file_block;
disk_pointer.offset = block_offset;
number_of_data_elements = total_bytes/data_size;
number_of_elements_read = 0;
chunk_size = D.Conversion_Buffer_Size/data_size
if chunk_size < 1
    error_return = 35;
    return
end

delta_from_bytes = chunk_size*data_size;
delta_to_bytes = chunk_size*machine_size;

while number_of_elements_read < number_of_data_elements
    % Limit the number to the end of the data
    number_of_elements_read = number_of_elements_read + chunk_size;
    if number_of_elements_read > number_of_data_elements
        chunk_size = chunk_size - (number_of_elements_read - number_of_data_elements);
        delta_from_bytes = chunk_size*data_size;
        delta_to_bytes = chunk_size*machine_size;
    end
    [D,from_data,error_return] = ADFI_Read_File(file_index,disk_pointer.block,disk_pointer.offset,tokenized_data_type.type,delta_from_bytes,D);
    if error_return ~= -1
        return
    end
    
    [D,to_data,error_return] = ADFI_Convert_Number_Format(D.ADF_File_Format(file_index), ... % from format
                                                            D.ADF_File_OS_Size(file_index), ... % from os size
                                                            D.ADF_This_Machien_Format, ... % to format
                                                            D.ADF_This_Machine_OS_Size, ... % to os size
                                                            'FROM_FILE_FORMAT',tokenized_data_type,chunk_size,from_data,D);
    if error_return ~= -1
        return
    end
    data = [data to_data];
    disk_pointer.offset = disk_pointer.offset+delta_from_bytes;
    if disk_pointer.offset > D.Disk_Block_Size
        [D,disk_pointer,error_return] = ADFI_Adjust_Disk_Pointer(disk_pointer,D);
        if error_return ~= -1
            return
        end
    end
end