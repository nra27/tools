function [D,error_return] = ADFI_Remember_Version_Update(file_index,what_string,D);
%
% [D,error_return] = ADFI_Remember_Version_Update(file_index,what_string,D)
%
% Stores the what-string (which contains the file version number) so that it
% can be written after the first successful update.  After the file has been
% updated once, the remembered what-string is 'forgotten'.
%
% D - Declaration space
% error_return - Error return
% file_index - File index to write to
% what_string - What-string to remember
%
% Possible errors:
% NO_ERROR, FILE_INDEX_OUT_OF_RANGE, NULL_STRING_POINTER, STRING_LENGTH_ZERO
% STRING_LENGTH_TOO_BIG

error_return = -1;

if file_index < 0 | file_index > D.Maxiumum_Files
    error_return = 10;
    return
end

if isempty(what_string)
    error_return = 3;
    return
end

if length(what_string) > D.What_String_Size
    error_return = 4;
    return
end

D.File_Version_Update(file_index) = what_string;