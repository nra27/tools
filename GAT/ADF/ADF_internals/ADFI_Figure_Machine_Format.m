function [D,machine_format,format_to_use,os_to_use,error_return] = ADFI_Figure_Machine_Format(format,D);
%
% Determine if the host computer is IEEE_BIG, IEEE_LITTLE, CRAY or NATIVE.  Once
% this machine's format is determined, look at the requested format.  If NATIVE,
% use this machine's format, otherwise use the requested format.
% 
% Note: As Matlab has all of this coded, we use the matlab functions, via a temp file.
%
% D - Declaration space
% machine_format - 'B','L', 'C', 'N'
% format_to_use - 'B','L', 'C', 'N'
% os_to_use - 'B', 'L'
% error_return - Error return
% format - IEEE_BIG, IEEE_LITTLE, CRAY, NATIVE
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER

error_return = -1;

% Check requested format
if strcmp(format,' ')
	requested_format = D.Native_Format_Char;
	requested_os = D.OS_32_Bit;
elseif strcmp(format,D.IEEE_Big_32_Format_String)
	requested_format = D.IEEE_Big_Format_Char;
	requested_os = D.OS_32_Bit;
elseif strcmp(format,D.IEEE_Little_32_Format_String)
	requested_format = D.IEEE_Little_Format_Char;
	requested_os = D.OS_32_Bit;
elseif strcmp(format,D.IEEE_Big_64_Format_String)
	requested_format = D.IEEE_Big_Format_Char;
	requested_os = D.OS_64_Bit;
elseif strcmp(format,D.IEEE_Little_64_Format_String)
	requested_format = D.IEEE_Little_Format_Char;
	requested_os = D.OS_64_Bit;
elseif strcmp(format,D.Cray_Format_String)
	requested_format = D.Cray_Format_Char;
	requested_os = D.OS_64_Bit;
elseif strcmp(format,D.Native_Format_String)
	requested_format = D.Native_Format_Char;
	requested_os = D.OS_32_Bit;
else
	error_return = 19;
	return
end

% Determine this machine's numeric format
% As we are in Matlab, we will write a temp file and see what it is

fid = fopen('Determining_File.dft','w');
if fid < 0
	error_return = 62;
	return
end
[filename,permission,local_format] = fopen(fid);
status = fclose(fid);
if status ~= 0
	error_return = 43;
	return
end
delete('Determining_File.dft');

clear filename permission

% Assign strings
switch local_format
	case 'ieee-be'
		machine_format = D.IEEE_Big_Format_Char;
		machine_os_size = D.OS_32_Bit;
	case 'ieee-le'
		machine_format = D.IEEE_Little_Format_Char;
		machine_os_size = D.OS_32_Bit;
	case 'ieee-be.l64'
		machine_format = D.IEEE_Big_Format_Char;
		machine_os_size = D.OS_64_Bit;
	case 'ieee-le.l64'
		machine_format = D.IEEE_Little_Format_Char;
		machine_os_size = D.OS_64_Bit;
	case 'cray'
		machine_format = D.IEEE_Cray_Char;
		machine_os_size = D.OS_64_Bit;
	otherwise % some other format, call is NATIVE
		error_return = 39;
		return
end
		
if D.ADF_This_Machine_Format == D.Undefined_Format_Char
	D.ADF_This_Machine_Format = machine_format;
	D.ADF_This_Machine_OS_Size = machine_os_size;
end

if requested_format == D.Native_Format_Char
	format_to_use = machine_format;
	os_to_use = machine_os_size;
else
	format_to_use = requested_format;
	os_to_use = requested_os;
end