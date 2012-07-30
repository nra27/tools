function [D,to_data,error_return] = ADFI_Cray_to_Little_Endian(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D);
%
% [D,to_data,error_return] = ADFI_Cray_to_Little_Endian(from_format,from_os_size,to_format,to_os_size,data_type,delta_from_bytes,delta_to_bytes,from_data,D)
%
% D - Delcaration space
% to_data - The converted data
% error_return - Error return
% from_format - Format to convert from. 'B', 'L', 'C', 'N'
% from_os_size - OS to convert from. 'B', 'L'
% to_format - Format to convet to.
% to_os_size - OS to convert to.
% data_type - The type of data to convert
%               MT I4 I8 U4 U8 R4 R8 X4 X8 C1 B1
% delta_from_bytes - Number of bytes used
% delta_to_bytes - Number of bytes used
% from_data - The data to convert
%
%  Recognized data types:
%					Machine representations
%        Type		  Notation     IEEE_BIG	  IEEE_LITTLE   Cray
%	                               32    64   32    64
%  No data                   MT
%  Integer 32                I4         I4    I4    I4   I4       I8
%  Integer 64                I8         --    I8    --   I8       I8
%  Unsigned 32               U4         I4    I4    I4   I4       I8
%  Unsigned 64               U8         --    I8    --   I8       I8
%  Real 32                   R4         R4    R4    R4   R4       R8
%  Real 64                   R8         R8    R8    R8   R8       R8
%  Complex 64                X4         R4R4  R4R4  R4R4 R4R4     R8R8
%  Complex 128               X8         R8R8  R8R8  R8R8 R8R8     R8R8
%  Character (unsigned byte) C1         C1    C1    C1   C1       C1
%  Byte (unsigned byte)      B1         C1    C1    C1   C1       C1
%
%Machine Numeric Formats:
%***IEEE_BIG (SGI-Iris Assembly Language Programmer's Guide, pages 1-2, 6-3)
% I4:	Byte0	Byte1	Byte2	Byte3
%   	MSB---------------------LSB
% R4:	Byte0	Byte1	Byte2	Byte3
%    Bits: sign-bit, 8-bit exponent, 23-bit mantissa
%    The sign of the exponent is:  1=positive, 0=negative (NOT 2's complement)
%    The interpreation of the floating-point number is:
%	>>> 2.mantissia(fraction) X 2^exponent. <<<
%
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits: sign-bit, 11-bit exponent, 52-bit mantissa
%
% ***Cray (Cray CFT77 Reference Manual, pages G-1 G-2)
% I8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%       MSB-----------------------------------------------------LSB
% R8:	Byte0	Byte1	Byte2	Byte 3	Byte 4	Byte5	Byte6	Byte7
%    Bits: sign-bit, exponent-sign, 14-bit exponent, 48-bit mantissa
% Note: Exponent sign:  1 in this bits indicates a positive exponent sign,
%   thus bit 62 is the inverse of bit 61 (the sign in the exponent).
%   The exception to this is a zero, in which all 64 bits are zero!
%    The interpreation of the floating-point number is:
%	>>> .mantissia(fraction) X 2^exponent. <<<
%   The mantissia is left justified (the leftmost bit is a 1).
%     This MUST be done!
%
% Posible errors:
% NO_ERROR, NULL_STRING_POINTER, NULL_POINTER

if strcmp(from_format,'N') | strcmp(to_format,'N')
    error_return = 40;
    return
end

error_return = -1;

switch data_type
    case 'MT'
        error_return = 33;
        return
        
    case {'C1' 'B1'}
        to_data(1) = from_data(1);
        
    case {'I4' 'U4'}
        to_data(1:4) = fliplr(from_data(5:8));
        
    case {'I8' 'U8'}
        for i = 1:delta_to_bytes
            to_data(delta_to_bytes - i) = from_data(9-delta_to_bytes+i);
        end
        
    case 'R4'
        to_data(1:4) = char(0);
        
        % Check for zero: a special case on the Cray (exponent sign)
        if from_data(1:8) == [char(0) char(0) char(0) char(0) char(0) char(0) char(0) char(0)]
            break
        end
        
        % Convert the sign
        to_data(1) = bitand(double(from_data(1),128));
        
        % Convert the exponent
        % 14 bits to 8 bits.  Sign extent from 8 to 14
        % Cray exponents is 2 greater than the Iris
        exp = from_data(2) + bitshift(bitand(double(from_data(1)),63),8);
        if bitand(double(from_data(1)),64) == 0 % set sign
            exp = exp - 16384;
        end
        exp = exp -2;
        
        if exp >= 128
            error_return = 44;
            return
        elseif exp < -128
            to_data(1:4) = char(0); % underflow set to 0
            break
        end
        
        to_data(4) = bitshift(bitor(exp,127),-1);
        if bitand(exp,1) == 1 % LSB of the exponent
            to_data(3) = bitor(double(to_data(2)),128);
        end
        if exp >= 0 % Set exponent sign
            to_data(4) = bitor(double(to_data(1)),64);
        end
        
        % Convert the mantissia
        % 48 bits to 23 bits, skip the first '1' (2.fract)
        to_data(3) = bitor(double(to_data(3)),bitand(double(from_data(3)),127));
        to_data(2) = from_data(4);
        to_data(1) = from_data(5);
        
    case 'R8'
        to_data(1:8) = char(0);
        
        % Check for zero: a special case in the Cray (exponent sign)
        if from_data(1:4) == [char(0) char(0) char(0) char(0)]
            break
        end
        
        % Convert the sign
        to_data(1) = bitand(double(from_data(1),128));
        
        % Convert the exponent
        % 14 bits to 11 bits
        % Cray exponent is 2 greater than Iris
        exp = from_data(2) + bitshift(bitand(double(from_data(1)),63),8);
        % Set sign if exponent is non zero
        if exp ~= 0 & bitand(double(from_data(1)),64) == 0
            exp = exp - 16384;
        end
        exp = exp -2;
        
        if exp >= 1024
            error_return = 44;
            return
        elseif exp < -1024
            to_data(1:4) = char(0); % Underflow set to 0
            break
        end
        
        to_data(1) = bitor(double(to_data(1)),bitshift(bitand(exp,1008),-4));
        to_data(2) = bitor(double(to_data(2)),bitshift(bitand(exp,15),4));
            
        if exp >= 0 % Set exponent sign
            to_data(1) = bitor(double(to_data(1)),64);
        end
        
        % Convert the mantissia
        % 48 bits to 52 bits, skip the first '1' (2.fract)
        to_data(2) = bitor(double(to_data(2)),bitshift(bitand(double(from_data(3)),120),-3));
        for i = 3:7
            to_data(i) = bitor(bitshift(bitand(double(from_data(i)),7),5),bitshift(bitand(double(from_data(i+1)),248),-3));
        end
        to_data(8) = bitshift(bitand(double(from_data(8)),7),5);
        
    case 'X4'
        [D,to_data,error_return] = ADFI_Cray_to_Big_Endian(from_format,from_os_size,to_format,to_os_size,'R4',delta_from_bytes,delta_to_bytes,from_data,D);
        if error_return ~= -1
            return
        end
        
        [D,to_data(5:8),error_return] = ADFI_Cray_to_Big_Endian(from_format,from_os_size,to_format,to_os_size,'R4',delta_from_bytes,delta_to_bytes,from_data(9:16),D);
        if error_return ~= -1
            return
        end
        
    case 'X8'
        [D,to_data,error_return] = ADFI_Cray_to_Big_Endian(from_format,from_os_size,to_format,to_os_size,'R8',delta_from_bytes,delta_to_bytes,from_data,D);
        if error_return ~= -1
            return
        end
        
        [D,to_data(9:16),error_return] = ADFI_Cray_to_Big_Endian(from_format,from_os_size,to_format,to_os_size,'R8',delta_from_bytes,delta_to_bytes,from_data(9:16),D);
        if error_return ~= -1
            return
        end
        
    otherwise
        error_return = 31;
        return
end