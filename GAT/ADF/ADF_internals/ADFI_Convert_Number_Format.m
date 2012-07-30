function [D,to_data,error_return] = ADFI_Convert_Number_Format(from_format,from_os_size,to_format,to_os_size,convert_dir,tokenized_data_type,length,from_data,D);
%
% [D,to_data,error_return] = ADFI_Convert_Number_Format(from_format,from_os_size,to_format,to_os_size,convert_dir,tokenized_data_type,length,from_data,D)
%
% D - Declaration space
% to_data - The translated data
% error_return - Error_return
% from_format - Format to convert from. 'B', 'L', 'C', 'N'
% from_os_size - OS size to convert from. 'B', 'L'
% to_format - Format to covert to.
% to_os_size - OS size to convert to.
% convert_dir - Convert direction from/to file format
% tokenized_data_type - Tokenized data type 'MT', 'I4', 'I8', 'U4', 'U8', 'R4', 'R8', 'X4', 'X8', 'C1', 'B1'
% length - The number of tokens to convert
% from_data - The data to convert from.
%
% Recognized data types:
%									Machine representations
%		Type				Notation	IEEE_BIG		IEEE_LITTLE		CRAY
%										32		64		32		64		
%	No data					MT
%	Integer 32				I4			I4		I4		I4		I4		I8
%	Integer 64				I8			--		I8		--		I8		I8
%	Unsigned 32				U4			I4		I4		I4		I4		I8
%	Unsigned 64				U8			--		I8		--		I8		I8
%	Real 32					R4			R4		R4		R4		R4		R8
%	Real 64					R8			R8		R8		R8		R8		R8
%	Complex 64				X4			R4R4	R4R4	R4R4	R4R4	R8R8
%	Complex 128				X8			R8R8	R8R8	R8R8	R8R8	R8R8
%	Character (unsign byte)	C1			C1		C1		C1		C1		C1
%	Byte (usign byte)		B1			C1		C1		C1		C1		C1
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, NULL_POINTER

if length == 0
	error_return = 1;
	return
end

if strcmp(from_format,'N') | strcmp(to_format,'N')
	error_return = 40;
	return
end

switch [from_format,to_format,from_os_size,to_os_size]
	case {'BBBB' 'CCBB' 'LLBB' 'BBLL' 'CCLL' 'LLLL'}
		error_return = 41;
		return
end

error_return = -1;
% Loop over each element
for l = 1:length
	current_token = 1;
	f_start = 1;
	t_start = 1;
	while tokenized_data_type(current_token).type(1) ~= 0
		data_type = tokenized_data_type(currnet_token).type;
		array_size = tokenized_data_type(current_token).length;
		if strcomp(convert_dir,'FROM_FILE_FORMAT')
			delta_from_bytes = tokenized_data_type(current_token).file_type_size;
			delta_to_bytes = tokenized_data_type(current_token).machine_type_size;
		else
			delta_to_bytes = tokenized_data_type(current_token).file_type_size;
			delta_from_bytes = tokenized_data_type(current_token).machine_type_size;
		end
		
		for s = 1:array_size
			f_end = delta_from_bytes;
			t_end = delta_to_bytes;
			switch [from_format,to_format,from_os_size,to_os_size]
				
				case {'BBLB' 'BBBL'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'LLLB' 'LLBL'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Little_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'BCLB' 'BCBB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'CBBL' 'CBBB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Cray_to_Big_Endian(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'BLBL' 'BLLB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Little_Endian_Swap(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'LBBL' 'LBLB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Little_Endian_32_Swap_64(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Little_Endian_Swap(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'BLLL' 'LBLL' 'BLBB' 'LBBB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Big_Little_Endian_Swap(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				case {'LCLB' 'LCBB'}
					[D,to_data(t_start:t_end),error_return] = ADFI_Little_Endian_to_Cray(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data(f_start:f_end),D);
					
				otherwise
					error_return = 39;
					return
			end
			
			if error_return ~= -1
				return
			end
			
			% Increment the data pointer
			f_start = f_start + delta_from_bytes;
			f_end = f_end + delta_from_bytes;
			t_start = t_start + delta_to_bytes;
			t_end = t_end + delta_to_bytes;
		end
		
		% Increment the token pointer
		current_token = current_token + 1;
	end
end	