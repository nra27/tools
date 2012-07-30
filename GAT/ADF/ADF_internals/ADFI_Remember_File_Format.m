function [D,error_return] = ADFI_Remember_File_Format(file_index,numeric_format,os_size,D);
%
% [D,error_return] = ADFI_Remember_File_Format(file_index,numeric_format,os_size,D)
%
% Track the file format used
%
% D - Declaration space
% error_return - Error_return
% file_index - Index for the file
% numeric_format - Format for the file
% os_size - Operating system size for the file
%
% Possible errors:
% NO_ERROR, FILE_INDEX_OUT_OF_RANGE

if file_index < 0 | file_index > D.Maximum_Files
    error_return = 10;
    return
end

error_return = -1;

D.ADF_File_Format{file_index} = numeric_format;
D.ADF_File_OS_Size{file_index} = os_size;