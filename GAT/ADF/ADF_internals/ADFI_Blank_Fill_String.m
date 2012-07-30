function str = ADFI_Blank_Fill_String(str,length);
%
% str = ADFI_Blank_Fill_String(str,length)
% Blank fill a string
%
% str - String to fill with blanks
% length - Total length of the string to fill

[j,i] = size(str);

while i < length
	i = i+1;
	str(i) = ' ';
end