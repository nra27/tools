function [D,error_return] = ADFI_Write_File_Header(file_index,file_header,D);
%
% [D,error_return] = ADFI_Write_File_Header(file_index,file_header,D)
%
% To take the information in the File_Header structure and format it
% for disk, and write it out.
%
% D - Declaration set
% error_return - Error return
% file_index - The file index to write to
% file_header - The file header structure
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPENED, ADF_MEMORY_TAG_ERROR, ADF_DISK_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check memory tags for proper data
if strcmp(file_header.tag0,D.File_Header_Tags(1,:)) ~= 1
    error_return = 16;
    return
end
if strcmp(file_header.tag1,D.File_Header_Tags(2,:)) ~= 1
    error_return = 16;
    return
end
if strcmp(file_header.tag2,D.File_Header_Tags(3,:)) ~= 1
    error_return = 16;
    return
end
if strcmp(file_header.tag3,D.File_Header_Tags(4,:)) ~= 1
    error_return = 16;
    return
end
if strcmp(file_header.tag4,D.File_Header_Tags(5,:)) ~= 1
    error_return = 16;
    return
end
if strcmp(file_header.tag5,D.File_Header_Tags(6,:)) ~= 1
    error_return = 16;
    return
end

% OK the memory tags look good, let's format the file header information
% into the disk format and write it out.
disk_header = file_header.what;
disk_header(33:36) = file_header.tag0;
disk_header(37:64) = file_header.creation_date;
disk_header(65:68) = file_header.tag1;
disk_header(69:96) = file_header.modification_date;
disk_header(97:100) = file_header.tag2;
disk_header(101) = file_header.numeric_format;
disk_header(102) = file_header.os_size;
disk_header(103:106) = file_header.tag3;
[D,disk_header(107:108),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_char,0,255,2,D);
[D,disk_header(109:110),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_short,0,255,2,D);
[D,disk_header(111:112),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_int,0,255,2,D);
[D,disk_header(113:114),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_long,0,255,2,D);
[D,disk_header(115:116),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_float,0,255,2,D);
[D,disk_header(117:118),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_double,0,255,2,D);
[D,disk_header(119:120),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_char_p,0,255,2,D);
[D,disk_header(121:122),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_short_p,0,255,2,D);
[D,disk_header(123:124),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_int_p,0,255,2,D);
[D,disk_header(125:126),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_long_p,0,255,2,D);
[D,disk_header(127:128),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_float_p,0,255,2,D);
[D,disk_header(129:130),error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(file_header.sizeof_double_p,0,255,2,D);
disk_header(131:134) = file_header.tag4;
[D,disk_header(135:142),disk_header(143:146),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(file_header.root_node,D);
[D,disk_header(147:154),disk_header(155:158),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(file_header.end_of_file,D);
[D,disk_header(159:166),disk_header(167:170),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(file_header.free_chunks,D);
[D,disk_header(171:178),disk_header(179:182),error_return] = ADFI_Disk_Pointer_2_ASCII_Hex(file_header.extra,D);
disk_header(183:186) = file_header.tag5;

% Now write the disk header out
[D,error_return] = ADFI_Write_File(file_index,0,0,0,D.File_Header_Size,disk_header,D);
if error_return ~= -1
    return
end

% Set the header onto the stack
[D,disk_header,error_return] = ADFI_Stack_Control(file_index,0,0,'SET_STK','FILE_STK',D.File_Header_Size,disk_header,D);
if error_return ~= -1
    return
end