function [D,file_bytes,machine_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Data_Type(file_index,data_type,D);
%
% [D,file_bytes,machine_bytes,tokenized_data_type,file_format,machine_format,error_return] = ADFI_Evaluate_Data_Type(file_index,data_type,D)
%
% D - Declaration space
% file_bytes - Number of bytes used by the data size
% machine_bytes - Number of bytes used by the data size
% tokenized_data_type - Tokenized data type array
% file_format - The format of this file
% machine_format - The format of this machine
% error_return - Error_return
% file_index - The ADF file index
% data_type - Data type string
%
% Recognized data types:
%		Type			Notation
%		No data				MT
%		Integer 32			I4
%		Integer 64			I8
%		Unsigned 32			U4
%		Unsigned 64			U8
%		Real 32				R4
%		Real 64				R8
%		Complex 64			X4
%		Complex 128			X8
%		Character (u-byte)	C1
%		Link (same as C1)	LK
%		Byte (u-byte)		B1
%
%	A structure is represented as the string 'I4, I4, R8'.
%	An array of 25 integers is 'I4[25]'
%
% Possible errors:
% NO_ERROR, NULL_POINTER, NULL_STRING_POINTER, DATA_TYPE_TOO_LONG
% INVALID_DATA_TYPE

str_position = 1;
current_token = 1;
file_bytes = 0;
machine_bytes = 0;
error_return = 'NO_ERROR';

% Return the file and machine format information
if file_index > D.Maximum_Files
	error_return = 'FILE_INDEX_OUT_OF_RANGE';
end

file_format = D.ADF_File_Format(file_index);
machine_format = D.ADF_This_Machine_Format;

% Get the file header for the file variable sizes
[D,file_header,error_return] = ADFI_Read_File_Header(file_index,D);
if error_return ~= 'NO_ERROR'
	return
end

% Get the machine number
[D,machine_format,format_to_use,os_to_use,error_return] = ADFI_Figure_Machine_Format('NATIVE',D);
if error_return ~= 'NO_ERROR'
	return
end

switch [format_to_use,os_to_use]
	case 'BL'
		machine_number = 1;
	case 'LL'
		machine_number = 2;
	case 'BB'
		machine_number = 3;
	case 'BL'
		machine_number = 4;
	case {'CL' 'CB'}
		macine_number = 5;
	otherwise
		error_return = 'UNIDENTIFIED_MACHINE_TYPE';
		return
end

data_type_string = [upper(data_type) ' '];

% Loop to calculate the compound data-type length and validity
while strcmp(data_type_string(str_position),' ') ~= 0
	size_file = 0;
	size_machine = 0;
	
	% Look at the 2-byte datatype code
	switch data_type_string(str_position:str_position+1)
		case 'MT'
			tokenized_data_type(current_token).type = 'MT';
			if str_position == 1 & strcmp(data_type_string(3),' ')
				return
			else % Error; can't have MT with anyother data type
				error_return = 'INVALID_DATA_TYPE';
				return
			end
			
		case 'I4'
			size_file = file_header.sizeof_int;
			size_machine = D.Machine_Sizes(machine_number,3);
			tokenized_data_type(current_token).type = 'I4';
			
		case 'I8'
			size_file = file_header.sizeof_long;
			size_machine = D.Machine_Sizes(machine_number,4);
			tokenized_data_type(current_token).type = 'I8';
			
		case 'U4'
			size_file = file_header.sizeof_int;
			size_machine = D.Machine_Sizes(machine_number,3);
			tokenized_data_type(current_token).type = 'U4';
			
		case 'U8'
			size_file = file_header.sizeof_long;
			size_machine = D.Machine_Sizes(machine_number,4);
			tokenized_data_type(current_token).type = 'U4';
			
		case 'R4'
			size_file = file_header.sizeof_float;
			size_machine = D.Machine_Sizes(machine_number,6);
			tokenized_data_type(current_token).type = 'R4';
			
		case 'R8'
			size_file = file_header.sizeof_double;
			size_machine = D.Machine_Sizes(machine_number,7);
			tokenized_data_type(current_token).type = 'R8';
			
		case 'X4'
			size_file = file_header.sizeof_float;
			size_machine = D.Machine_Sizes(machine_number,6);
			tokenized_data_type(current_token).type = 'X4';
		
		case 'X8'
			size_file = file_header.sizeof_double;
			size_machine = D.Machine_Sizes(machine_number,7);
			tokenized_data_type(current_token).type = 'X8';
			
		case 'B1'
			size_file = 1;
			size_machine = 1;
			tokenized_data_type(current_token).type = 'B1';
			
		case {'C1' 'LK'}
			size_file = file_header.sizeof_char;
			size_machine = D.Machine_Sizes(machine_number,1);
			tokenized_data_type(current_token).type = 'C1';
			
		otherwise
			error_return = 'INVALID_DATA_TYPE';
			return
	end
	
	tokenized_data_type(current_token).file_type_size = size_file;
	tokenized_data_type(current_token).machine_type_size = machine_size;
	
	str_position = str_position + 2;
	% Look for arrays '[', commas ',' and end of string ' '
	switch data_type_string(str_position) 
		case ' '
			file_bytes = file_bytes+size_file;
			machine_bytes = machine_bytes+size_machine;
			tokenized_data_type(current_token+1).length = '1';
			
		case '['
			array_size = 0;
			str_position = str_position+1;
			while data_type_string(str_position) >= '0' & data_type_string(str_position) <= '9'
				array_size = array_size*10 + str2num(data_type_string(str_position));
				str_position = str_position + 1;
			end
			if strcmp(data_type_str(str_position),']') ~= 1
				error_return = 'INVALID_DATA_TYPE';
				return
			end
			str_position = str_position +1;
			
			% Check for comma between types
			if strcmp(data_type_string(str_position),',')
				str_position = str_position +1;
			end
			file_bytes = file_bytes + size_file*array_size;
			machine_bytes = machine_bytes + size_machine*array_size;
			tokenized_data_type(current_token +1).length = array_size;
			
		case ','
			str_position = str_position + 1;
			file_bytes = file_bytes + size_file;
			machine_bytes = machine_bytes + size_machine;
			
		otherwise %Invalid condition
			error_return = 'INVALID_DATA_TYPE';
			return
	end
end

tokenized_data_type(current_token).type = ' ';
tokenized_data_type(current_token).file_type_size = file_bytes;
tokenized_data_type(current_token).machine_type_size = machine_bytes;