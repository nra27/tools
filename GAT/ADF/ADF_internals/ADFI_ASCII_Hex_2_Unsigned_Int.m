function [D,number,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(minimum,maximum,string_length,string,D);
%
% [D,number,error_return] = ADFI_ASCII_Hex_2_Unsigned_Int(minimum,maximum,string,D)
% Convert a number of ASCII-Hex into an unsigned integer.
%
% minimum - Expected minimum number
% maximum - Expected maximum number
% string_length - The length (bytes) of the input string
% string - The input string
% D - Defined variables
% number - The output number
% error_return - Error return
%
% Possible errors:
% No_Error, Null_String_Pointer, String_Length_Zero, String_Length_Too_Big, Minimum_Gt_Maximum
% String_Not_A_Hex_String, Number_Less_Than_A_Minimum, Number_Less_Than_A_Maximum

% Define variables
number = 0;

% Check for errors
if isempty(string)
    error_return = 12;
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

if minimum > maximum
    error_return = 38;
    return
end

error_return = -1;

% Convert the ASCII-Hex string into decimal
num = 0;
i = 1;
ir = string_length;
while i<string_length+1
    switch string(i)
        case{'0'}
        case{'1' '2' '3' '4' '5' '6' '7' '8' '9'}
            j = (double(string(i))-double('0'))*D.Pows(ir);
            num = num+j;
        case{'A' 'B' 'C' 'D' 'E' 'F'}
            j = (double(string(i))-double('A')+10)*D.Pows(ir); 
            num = num+j;
        case{'a' 'b' 'c' 'd' 'e' 'f'}
            j =(double(string(i))-double('a')+10)*D.Pows(ir);
            num = num+j;
        otherwise
            error_return = 5;
            return
        end
    i = i+1;
    ir = ir-1;
end

if num < minimum
    error_return = 1;
    return
end

if num > maximum
    error_return = 2;
    return
end

number = num;