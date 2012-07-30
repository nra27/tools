function [D,compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D);
%
% [D,compare,error_return] = ADFI_File_and_Machine_Compare(file_index,D)
%
% Compares the file and the machine formats
%
% D - Declarations space
% compare - 1 = formats compare, 0 = do not
% error_return - Error_return
% file_index - The ADF index of the file
%
% Possible errors:
% FILE_INDEX_OUT_OF_RANGE

compare = 0;
error_return = -1;

if file_index < 1 | file_index > D.Maximum_Files
	error_return = 10;
	return
end

if strcmp(D.ADF_This_Machine_Format,D.Native_Format_Char) | strcmp(D.ADF_File_Format(file_index),D.Native_Format_Char)
	% Get the file_header for the file variable sizes
	[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
	if error_return ~= -1
		return
	end
    
    % Establish with machine number we are (1-5)
    if strcmp(D.ADF_This_Machine_Format,'B') & strcmp(D.ADF_This_Machine_OS_Size,'L')
        machine = 1; % IEEE Big 32
    elseif strcmp(D.ADF_This_Machine_Format,'L') & strcmp(D.ADF_This_Machine_OS_Size,'L')
        machine = 2; % IEEE Little 32
    elseif strcmp(D.ADF_This_Machine_Format,'B') & strcmp(D.ADF_This_Machine_OS_Size,'B')
        machine = 3; % IEEE Big 64
    elseif strcmp(D.ADF_This_Machine_Format,'L') & strcmp(D.ADF_This_Machine_OS_Size,'B')
        machine = 4; % IEEE Little 64
    elseif strcmp(D.ADF_This_Machine_Format,'C')
        machine = 5; % CRAY
    else
        error_return = 39;
        return
    end
    
	% If the machine isn't the same, then check the data sizes are compatible or we are in trouble!
	if strcmp(D.ADF_File_Format(file_index),D.Native_Format_Char) ~= 1 | ...
			file_header.sizeof_char ~= D.Machine_Sizes(machine,1) | ...
			file_header.sizeof_short ~= D.Machine_Sizes(machine,2) | ...
			file_header.sizeof_int ~= D.Machine_Sizes(machine,6) | ...
			file_header.sizeof_long ~= D.Machine_Sizes(machine,8) | ...
			file_header.sizeof_float ~= D.Machine_Sizes(machine,10) | ...
			file_header.sizeof_double ~= D.Machine_Sizes(machine,11) | ...
			file_header.sizeof_char_p ~= D.Machine_Sizes(machine,8) | ...
			file_header.sizeof_short_p ~= D.Machine_Sizes(machine,9) | ...
			file_header.sizeof_int_p ~= D.Machine_Sizes(machine,10) | ...
			file_header.sizeof_long_p ~= D.Machine_Sizes(machine,11) | ...
			file_header.sizeof_float_p ~= D.Machine_Sizes(machine,12) | ...
			file_header.sizeof_double_p ~= D.Machine_Sizes(machine,13)
        error_return = 60;
        return
    end
end

if strcmp(D.ADF_File_Format(file_index),D.ADF_This_Machine_Format) & strcmp(D.ADF_File_OS_Size(file_index),D.ADF_This_Machine_OS_Size)
    compare = 1;
end