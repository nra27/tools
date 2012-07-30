function [D,file_header,error_return] = ADFI_Fill_Initial_File_Header(format,os_size,what_string,D);
%
% [D,file_header,error_return] = ADFI_Fill_Initial_File_Header(format,os_size,what_string,D)
%
% To determine the file header information...
%
% D - Declaration space
% file_header - The resulting file header information
% error_return - Error return
% format - 'B', 'L', 'C' or 'N'
% os_size - 'B' or 'L'
% what_string - the UNIX 'what' identifier
%
% Possible errors:
% NO_ERROR, NULL_POINER, NULL_STRING_POINTER, ADF_FILE_FORMAT_NOT_RECOGNIZED

error_return = -1;

if format ~= D.IEEE_Big_Format_Char & format ~= D.IEEE_Little_Format_Char & format ~= D.Cray_Format_Char & format ~= D.Native_Format_Char
    error_return = 19;
    return
end

% Put the boundary tags in first.  If we then overwrite them, we'll know
file_header.tag0 = D.File_Header_Tags(1,:);
file_header.tag1 = D.File_Header_Tags(2,:);
file_header.tag2 = D.File_Header_Tags(3,:);
file_header.tag3 = D.File_Header_Tags(4,:);
file_header.tag4 = D.File_Header_Tags(5,:);
file_header.tag5 = D.File_Header_Tags(6,:);

% The UNIX 'what' string - blank filled
if length(what_string) < D.What_String_Size
    what_string = ADFI_Blank_Fill_String(what_string,D.What_String_Length);
end
file_header.what = what_string;

% File creation date/time - blank filled
[D,file_header.creation_date] = ADFI_Get_Current_Date(D);

% File modifiaction date/time - same as creation date
file_header.modification_date = file_header.creation_date;

file_header.numeric_format = format;
file_header.os_size = os_size;

% Set sizeof() information for file data
% Establish with machine number we are (1-5)
if D.ADF_This_Machine_Format == 'B' & D.ADF_This_Machine_OS_Size == 'L'
    machine = 1; % IEEE Big 32
elseif D.ADF_This_Machine_Format == 'L' & D.ADF_This_Machine_OS_Size == 'L'
    machine = 2; % IEEE Little 32
elseif D.ADF_This_Machine_Format == 'B' & D.ADF_This_Machine_OS_Size == 'B'
    machine = 3; % IEEE Big 64
elseif D.ADF_This_Machine_Format == 'L' & D.ADF_This_Machine_OS_Size == 'B'
    machine = 4; % IEEE Little 64
elseif D.ADF_This_Machine_Format == 'C'
    machine = 5; % CRAY
else
    error_return = 39;
    return
end
    
file_header.sizeof_char = D.Machine_Sizes(machine,1);
file_header.sizeof_short = D.Machine_Sizes(machine,2);
file_header.sizeof_int = D.Machine_Sizes(machine,6);
file_header.sizeof_long = D.Machine_Sizes(machine,8);
file_header.sizeof_float = D.Machine_Sizes(machine,10);
file_header.sizeof_double = D.Machine_Sizes(machine,11);
file_header.sizeof_char_p = D.Machine_Sizes(machine,8);
file_header.sizeof_short_p = D.Machine_Sizes(machine,9);
file_header.sizeof_int_p = D.Machine_Sizes(machine,10);
file_header.sizeof_long_p = D.Machine_Sizes(machine,11);
file_header.sizeof_float_p = D.Machine_Sizes(machine,12);
file_header.sizeof_double_p = D.Machine_Sizes(machine,13);

% Set root node table pointers
file_header.root_node.block = D.Root_Node_Block;
file_header.root_node.offset = D.Root_Node_Offset;
file_header.end_of_file.block = D.Root_Node_Block;
file_header.end_of_file.offset = D.Root_Node_Offset + D.Node_Header_Size -1;
file_header.free_chunks.block = D.Free_Chunk_Block;
file_header.free_chunks.offset = D.Free_Chunk_Offset;
[D,file_header.extra] = ADFI_Set_Blank_Disk_Pointer(D); 