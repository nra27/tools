function [D,error_return] = ADFI_Write_Modification_Date(file_index,D);
%
% [D,error_return] = ADFI_Write_Modification_Date(file_index,D)
%
% Writes the current date/time into the modification date field of
% the file header.  Also updates the file version (what string) in
% the header if the file version global variable has been set - after
% writing, the file version global variable is unset so that it is
% only written once.
%
% D - Declaration space
% error_return - Error return
% file_index - The file to write to
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, ADF_FILE_NOT_OPENED, FWRITE_ERROR

if D.File_in_Use(file_index) == 0
	error_return = 9;
	return
end

error_return = -1;

[D,mod_date] = ADFI_Get_Current_Date(D);

% Block offset depends on the location of the modification date in the
% File_Header structure
i_block_offset = D.What_String_Size + D.Tag_Size + D.Date_Time_Size + D.Tag_Size;
[D,error_return] = ADFI_Write_File(file_index,0,i_block_offset,0,D.Date_Time_Size,mod_date,D);
if error_return ~= -1
	return
end

% Flush the write buffer to ensure the file is current!!
[D,error_return] = ADFI_Flush_Buffers(file_index,'FLUSH',D);
if error_return ~= -1
    return
end

if ~isempty(D.File_Version_Update{file_index})
	i_block_offset = 0; % what-string is the first field in header
	[D,error_return] = ADFI_Write_File(file_index,0,i_block_offset,0,D.What_String_Size,D.File_Version_Update{file_index},D);
	if error_return ~= -1
		return
	end
	
	% Reset the version to default so that it only gets updated once
	D.File_Version_Update{file_index} = [];
end