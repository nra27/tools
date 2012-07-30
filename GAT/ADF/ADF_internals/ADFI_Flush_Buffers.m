function [D,error_return] = ADFI_Flush_Buffers(file_index,flush_mode,D);
%
% [D,error_return] = ADFI_Flush_Buffers(file_index,flush_mode,D)
%
% D - Declaration space
% error_return - Error_return
% file_index - The file index
% flush_mode - String giving flush mode
%
% Possible errors:
% NO_ERROR, ADF_FILE_NOT_OPENED, FWRITE_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = 1;
data = 0;

if file_index == D.Last_Wr_File
    % Flush any active write buffer, file block is set to a nonsense value
    % so that the buffer flags are not reset
    [D,error_return] = ADFI_Write_File(file_index,D.Maximum_32_Bits,0,0,0,data,D);
    
    % Reset control flags
    if strcmp(flush_mode,'FLUSH_CLOSE')
        D.Last_Wr_Block = -1;
        D.Last_Wr_File = -1;
        D.Flush_Wr_Block = -1;
    end
end

if file_index == D.Last_Rd_File & strcmp(flush_mode,'FLUSH_CLOSE')
    % Reset control flags
    D.Last_Rd_Block = 0;
    D.Last_Rd_File = 0;
    D.Num_in_Rd_Block = 0;
end
