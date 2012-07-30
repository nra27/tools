function [D,error_return] = ADFI_Close_File(top_file_index,D);
%
% error_return = ADFI_Close_File(top_file_index)
%
% Closes the indicated ADF file and also all files with this file's
% index as their top index
%
% error_return - Error return
% top_file_index - Index of top ADF file
% D - Declaration space
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPENED

if D.File_in_Use(top_file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Close the file
if D.ADF_File(top_file_index) > 2
    [D,error_return] = ADFI_Flush_Buffers(top_file_index,'FLUSH_CLOSE',D);
    report = fclose(D.ADF_File(top_file_index));
    if report ~= 0
        error_return = 43;
        return
    end
end

% Clear this file's entry
[D,a,error_return] = ADFI_Stack_Control(top_file_index,0,0,'CLEAR_STK',0,0,0,D);
D.File_in_Use(top_file_index) = 0;
D.First_File_in_System(top_file_index) = -1;
D.ADF_File(top_file_index) = -1;
D.File_Update_Version{top_file_index} = [];

% If any other file uses this file as it's top-file, then also close it.
for index = 1:D.Maximum_Files
    if D.First_File_in_System(index) == top_file_index
        if D.ADF_File(index) > 2
            report = fclose(D.ADF_File(index))
            if report ~= 0
                error_return = 43;
                return
            end
        end
        [D,a,error_return] = ADFI_Stack_Control(index,0,0,'CLEAR_STK',0,0,0,D);
        D.File_in_Use(index) = 0;
        D.First_File_in_System(index) = -1;
        D.ADF_File(index) = -1;
        D.File_Version_Update{index} = [];
    end
end