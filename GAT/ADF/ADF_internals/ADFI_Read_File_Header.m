function [D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
%
% [D,file_header,error_return] = ADFI_Read_File_Header(file_index,D)
% 
% To read the header of an ADF file.
%
% file_header - a structure containing the headre info
% error_return - Error return
% file_index - The file index
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_POINTER, ADF_FILE_NOT_OPEN, ADF_MEMORY_TAG_ERROR

if D.File_in_Use(file_index) == 0
    error_return = 9;
    return
end

error_return = -1;

% Check the stack for header
[D,disk_header,error_return] = ADFI_Stack_Control(file_index,0,0,'GET_STK','FILE_STK',D.File_Header_Size,0,D);

% If not on stack, read from disk
if error_return ~= -1 
    [D,disk_header,error_return] = ADFI_Read_File(file_index,0,0,0,D.File_Header_Size,D);
    if error_return ~= -1
        return
    end
    
    % Check memory tags for proper data
    if strcmp(char(disk_header(33:33+D.Tag_Size-1)),D.File_Header_Tags(1,:)) ~= 1
        error_return = 16;
        return
    end
    
    if strcmp(char(disk_header(65:65+D.Tag_Size-1)),D.File_Header_Tags(2,:)) ~= 1
        error_return = 16;
        return
    end

    if strcmp(char(disk_header(97:97+D.Tag_Size-1)),D.File_Header_Tags(3,:)) ~= 1
        error_return = 16;
        return
    end
    
    if strcmp(char(disk_header(103:103+D.Tag_Size-1)),D.File_Header_Tags(4,:)) ~= 1
        error_return = 16;
        return
    end
    
    if strcmp(char(disk_header(131:131+D.Tag_Size-1)),D.File_Header_Tags(5,:)) ~= 1
        error_return = 16;
        return
    end
    
    if strcmp(char(disk_header(183:183+D.Tag_Size-1)),D.File_Header_Tags(6,:)) ~= 1
        error_return = 16;
        return
    end
    
    % Set the header onto the stack
    [D,stack_data,error_return] = ADFI_Stack_Control(file_index,0,0,'SET_STK','FILE_STK',D.File_Header_Size,disk_header,D);
    
end

% Memory tags look good, so convert disk-formatted header into memory
file_header.what = char(disk_header(1:32));
file_header.tag0 = char(disk_header(33:33+D.Tag_Size-1));
file_header.creation_date = char(disk_header(37:36+D.Date_Time_Size));
file_header.tag1 = char(disk_header(65:65+D.Tag_Size-1));
file_header.modification_date = char(disk_header(69:68+D.Date_Time_Size));
file_header.tag2 = char(disk_header(97:97+D.Tag_Size-1));
file_header.numeric_format = char(disk_header(101));
file_header.os_size = char(disk_header(102));
file_header.tag3 = char(disk_header(103:103+D.Tag_Size-1));
[D,file_header.sizeof_char,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(107:108),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_short,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(109:110),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_int,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(111:112),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_long,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(113:114),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_float,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(115:116),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_double,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(117:118),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_char_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(119:120),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_short_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(121:122),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_int_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(123:124),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_long_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(125:126),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_float_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(127:128),D);
if error_return ~= -1
    return
end
[D,file_header.sizeof_double_p,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(0,255,2,disk_header(129:130),D);
if error_return ~= -1
    return
end
file_header.tag4 = char(disk_header(131:131+D.Tag_Size-1));
[D,file_header.root_node,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_header(135:142),disk_header(143:146),D);
if error_return ~= -1
    return
end
[D,file_header.end_of_file,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_header(147:154),disk_header(155:158),D);
if error_return ~= -1
    return
end
[D,file_header.free_chunks,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_header(159:166),disk_header(167:170),D);
if error_return ~= -1
    return
end
[D,file_header.extra,error_return] = ADFI_Disk_Pointer_frm_ASCII_Hex(disk_header(171:178),disk_header(179:182),D);
if error_return ~= -1
    return
end
file_header.tag5 = char(disk_header(183:183+D.Tag_Size-1));
  
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