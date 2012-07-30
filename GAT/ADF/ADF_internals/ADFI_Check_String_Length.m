function error_return = ADFI_Check_String_Length(str,max_length);
%
% error_return = ADFI_Check_String_Length(str,maxlength)
%
% Check a character string for:
% 	being a NULL pointer
%	being too long
%	being zero length
%
% error_return - Error return
% max_length - Maximum allowable length of the string
% str - The input string
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, STRING_LENGTH_ZERO, STRING_LENGTH_TOO_BIG

if exist('str') == 0
	error_return = 12;
	return
end

str_length = length(str);
if str_length == 0
	error_return = 3;
	return
end

if str_length > max_length
	error_return = 4;
	return
end

% Check for blank string
error_return = 3;
for i = 1:str_length
	if str(i) ~= ' '
		error_return = -1;
		break
	end
end