function [D,string,error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(number,minimum,maximum,string_length,D);
%
% [string,error_return] = ADFI_Unsigned_Int_2_ASCII_Hex(number,minimum,maximum,string_length,D)
%
% Convert an unsigned integer to an ASCII-Hex string
%
% string - The string
% error_return - Error_return
% number - Integer to be converted
% minimum - Expected minimum
% maximum - Expected maximum
% string_length - Length of the returned string
% D - Declaration space
%
% Possible errors:
% NO_ERROR, NULL_STRING_POINTER, NUMBER_LESS_THAN_MINIMUM, NUMBER_GREATER_THAN_MAXIMUM,
% STRING_LENGTH_ZERO, STRING_LENGTH_TOO_BIG

if number < minimum
    error_return = 1;
    return
end

if number > maximum
    error_return = 2;
    return
end

if string_length == 0
    error_return = 3;
    return
end

if string_length > 8
    error_return = 4;
    return
end

error_return = -1;

% Convert the number using power-of-2-table
num = number;
i = 1;
ir = string_length;
string = '';

while i < string_length+1
    if num >= D.Pows(ir)
        j = floor(num / D.Pows(ir));
        num = num - j * D.Pows(ir);
    else
        j = 0;
    end
    string = [string D.ASCII_Hex{j+1}];
    i = i+1;
    ir = ir-1;
end